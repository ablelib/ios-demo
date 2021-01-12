//
//  ClientSocketView.swift
//  AbleLib iOS demo
//
//  Created by Gordan Glavaš on 12.01.2021..
//

import SwiftUI
import Able

struct ClientSocketView: View {
    @ObservedObject var vm: CentralVm
    
    var body: some View {
        VStack {
            Button("Scan\(vm.isScanning ? "ning" : "")") {
                vm.scan()
            }
            if vm.socketConn != nil {
                HStack {
                    TextField("Input", text: $vm.textToSend)
                    Spacer()
                    Button("Send to server socket") {
                        if let data = vm.textToSend.data(using: .utf8) {
                            vm.socket?.connection?.send(data: data)
                        }
                    }
                }
                HStack {
                    Text("Received from server socket:")
                        .padding(.horizontal, 20)
                    Text(vm.receivedText)
                        .font(.system(size: 11))
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(20)
                        .multilineTextAlignment(.leading)
                }
                Button("Disconnect") {
                    vm.doComm(nil)
                }
            } else {
                List(vm.devices, id: \.self) { device in
                    Button(device.identifier.uuidString) {
                        vm.doComm(device)
                    }
                }
            }
            Text("Client log:")
            ScrollView {
                Text(vm.clientLog)
                    .font(.system(size: 10))
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
            }
        }
    }
}

struct ClientSocketView_Previews: PreviewProvider {
    static var previews: some View {
        ClientSocketView(vm: CentralVm())
    }
}

class CentralVm: ObservableObject {
    let ableManager: AbleManager = AbleManager.shared
    @Published var devices = [AbleDevice]()
    @Published var isScanning = false
    @Published var clientLog = ""
    @Published var textToSend = ""
    @Published var receivedText = ""
    private var comm: IAbleComm?
    private var psm: AblePSM?
    var socket: IAbleSocket?
    @Published var socketConn: IAbleSocketConnection?
    
    func scan() {
        if isScanning {
            ableManager.stopScan()
        } else {
            devices.removeAll()
            ableManager.startScan { result in
                result.onSuccess { info in
                    self.devices.append(info.device)
                }.onFailure { error in
                    self.log("\nError scanning: \(error)")
                }
            }
        }
        isScanning.toggle()
    }
    
    func doComm(_ device: AbleDevice?) {
        if socket != nil {
            socketConn?.close { result in
                log("Socket closed: \(result)")
                comm?.disconnect { _ in
                    self.log("disconnected")
                    self.comm = nil
                }
            }
            socket = nil
        } else if let device = device {
            comm = ableManager.comm(with: device)
            comm?.actions
                .connect()
                .discoverServices([serviceId])
                .discoverCharacteristics([charId])
                .setNotifyValue(true)
                .readCharacteristic { char in
                    if let data = char.value {
                        self.psm = AblePSM(data: data)
                    } else {
                        throw AbleCommActionsError(message: "Unable to decode PSM!")
                    }
                }
                .run { [self] result in
                    result.onSuccess { _ in
                        log("Connecting to L2CAP socket with psm: \(psm!.value)")
                        socket = L2CAPSocket(secure: false, device: device, psm: psm!)
                        socket?.connect { result in
                            result.onSuccess { connection in
                                self.socketConn = connection
                                log("Success opening socket")
                                connection.onSend = { result in
                                    result.onSuccess { data in
                                        log("Sent data \(data)")
                                    }.onFailure { error in
                                        log("Error sending data \(error)")
                                    }
                                }
                                connection.onReceive = { result in
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
                                log("Error opening socket: \(error)")
                            }
                        }
                    }.onFailure { error in
                        log("ERROR: \(error)")
                    }
                }
        }
    }
    
    private func log(_ message: String) {
        DispatchQueue.main.async {
            self.clientLog += "\n\(message)"
        }
    }
}
