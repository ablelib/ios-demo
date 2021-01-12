//
//  ServerSocketView.swift
//  AbleLib iOS demo
//
//  Created by Gordan Glavaš on 12.01.2021..
//

import SwiftUI
import Able

struct ServerSocketView: View {
    @ObservedObject var vm: PeripheralVm
    @State private var publish = false
    
    var body: some View {
        VStack {
            Button("Turn server: \(publish ? "OFF" : "ON")") {
                publish.toggle()
                vm.handleServer(publish)
            }
            if publish {
                HStack {
                    TextField("Input", text: $vm.textToSend)
                    Spacer()
                    Button("Send to client sockets") {
                        vm.send()
                    }
                }.padding(.bottom, 10)
            }
            HStack {
                Text("Received from client socket:")
                    .padding(.horizontal, 20)
                Text(vm.receivedText)
                    .font(.system(size: 11))
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(20)
                    .multilineTextAlignment(.leading)
            }
            Text("Server log:")
            ScrollView {
                Text(vm.serverLog)
                    .font(.system(size: 10))
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
            }
        }
    }
}

struct ServerSocketView_Previews: PreviewProvider {
    static var previews: some View {
        ServerSocketView(vm: PeripheralVm())
    }
}

class PeripheralVm: ObservableObject {
    @Published var receivedText = ""
    @Published var textToSend = ""
    @Published var serverLog = ""
    var server: IAbleGATTServer? = nil
    var char: AbleCharacteristic? = nil
    var socket = L2CAPServerSocket(secure: false)
    var socketConn: IAbleSocketConnection? = nil
    
    func handleServer(_ open: Bool) {
        if open {
            server = AbleManager.shared.openGATTServer {
                AbleService(uuid: serviceId, type: .primary) {
                    AbleCharacteristic(uuid: charId, properties: [.read, .indicate], permissions: .readable, assign: &self.char)
                }
                AbleOnStateChange { isOpen in
                    self.log("server open?: \(isOpen)")
                    if isOpen {
                        AbleManager.shared.startAdvertising(data: .init(localName: nil, services: [serviceId])) { result in
                            self.log("server started advertising?: \(result)")
                            self.socket.open { result in
                                result.onSuccess { psm in
                                    self.log("Socket open with psm: \(psm)")
                                    if let char = self.char {
                                        let data = UInt16(psm.value).data
                                        char.value = data
                                        self.server?.notifyCharacteristicChanged(char, value: data)
                                        self.log("Notifying characteristics")
                                    }
                                    self.socket.accept { result in
                                        result.onSuccess { connection in
                                            self.log("socket connection open: \(connection)")
                                            self.socketConn = connection
                                            connection.onSend = { [self] result in
                                                result.onSuccess { data in
                                                    log("Sent data \(data)")
                                                }.onFailure { error in
                                                    log("Error sending data \(error)")
                                                }
                                            }
                                            connection.onReceive = { [self] result in
                                                result.onSuccess { data in
                                                    let text = String(data: data, encoding: .utf8)!
                                                    log("Received data: \(text)")
                                                    DispatchQueue.main.async {
                                                        self.receivedText += "\n\(text)"
                                                    }
                                                }.onFailure { error in
                                                    log("Error receiving data \(error)")
                                                }
                                            }
                                        }.onFailure { error in
                                            self.log("socket connection error: \(error)")
                                        }
                                    }
                                }.onFailure { error in
                                    self.log("socket open error: \(error)")
                                }
                            }
                        }
                    }
                }
                AbleOnRead([charId]) { server, request in
                    self.log("server read request")
                    if let char = self.char {
                        self.log("Responding with value: \(String(describing: char.value))")
                        request.value = char.value
                        server.respond(to: request, status: .success)
                    } else {
                        self.log("Invalid request")
                        server.respond(to: request, status: .unlikelyError)
                    }
                }
            }
        } else {
            AbleManager.shared.stopAdvertising()
            socket.close { result in
                self.log("socket closed: \(result)")
            }
            server?.close()
            self.log("Server closed")
            server = nil
        }
    }
    
    func send() {
        if let data = textToSend.data(using: .utf8) {
            self.socketConn?.send(data: data)
        }
    }
    
    private func log(_ message: String) {
        DispatchQueue.main.async {
            self.serverLog += "\n\(message)"
        }
    }
}

extension UInt16 {
    var data: Data {
        var int = self
        return Data(bytes: &int, count: MemoryLayout<UInt16>.size)
    }
}
