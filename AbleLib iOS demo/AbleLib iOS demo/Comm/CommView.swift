//
//  CommView.swift
//  AbleLib iOS demo
//
//  Created by Gordan Glavaš on 02/11/2020.
//

import SwiftUI
import Able

struct CommView: View {
    @State private var phase = Phase.disconnected(Array(AbleDeviceStorage.default.devices))
    @State private var errorMessage: String? = nil
    
    var body: some View {
        VStack {
            errorView
            if case let .disconnected(devices) = phase {
                deviceList(devices)
            } else if case let .connected(comm) = phase {
                connectedPanel(comm)
            } else if case let .discoveredServices(comm, services) = phase {
                servicesList(comm, services)
            } else if case let .discoveredCharacteristics(comm, characteristics) = phase {
                characteristicsList(comm, characteristics)
            }
            Spacer()
        }.onAppear(perform: refresh)
    }
    
    private var errorView: some View {
        Group {
            if errorMessage != nil {
                Text(errorMessage!)
                    .padding()
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .foregroundColor(.white)
                    .background(Color.red)
            }
        }
    }
    
    private func deviceList(_ devices: [AbleDevice]) -> some View {
        Group {
            if devices.isEmpty {
                Text("Scan for devices and then add them to the storage")
            } else {
                DevicesList(devices: .constant(devices)) { device in
                    Button {
                        let comm = device.comm
                        comm.connect { result in
                            result.onSuccess { device in
                                phase = .connected(comm)
                            }.onFailure { error in
                                errorMessage = error.localizedDescription
                            }
                        }
                    } label: {
                        Text("Connect")
                            .foregroundColor(.white)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 5)
                                            .foregroundColor(.green))
                    }
                }
            }
            HStack {
                Button("Refresh") {
                    refresh()
                }
            }.padding(.vertical, 10)
        }
    }
    
    private func refresh() {
        phase = .disconnected(Array(AbleDeviceStorage.default.devices))
    }
    
    private func connectedPanel(_ comm: AbleComm) -> some View {
        Group {
            Text("Connected!")
            HStack {
                disconnectButton(comm)
                Spacer()
                Button("Discover services") {
                    comm.discoverServices(nil) { result in
                        result.onSuccess { services in
                            phase = .discoveredServices(comm, services)
                        }.onFailure { error in
                            errorMessage = error.localizedDescription
                        }
                    }
                }
            }
        }
    }
    
    private func servicesList(_ comm: AbleComm, _ services: [AbleService]) -> some View {
        Group {
            disconnectButton(comm)
            List(services, id: \.self) { service in
                HStack {
                    Text(service.uuid.uuidString)
                    Spacer()
                    Button("Discover characteristics") {
                        comm.discoverCharacteristics(nil, for: service) { result in
                            result.onSuccess { chars in
                                phase = .discoveredCharacteristics(comm, chars)
                            }.onFailure { error in
                                errorMessage = error.localizedDescription
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func characteristicsList(_ comm: AbleComm, _ characteristics: [AbleCharacteristic]) -> some View {
        Group {
            disconnectButton(comm)
            List(characteristics, id: \.self) { char in
                Text(char.description)
            }
        }
    }
    
    private func disconnectButton(_ comm: AbleComm) -> some View {
        Button("Disconnect") {
            comm.disconnect { result in
                result.onSuccess { device in
                    refresh()
                }.onFailure { error in
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private enum Phase {
        case disconnected([AbleDevice]),
             connected(AbleComm),
             discoveredServices(AbleComm, [AbleService]),
             discoveredCharacteristics(AbleComm, [AbleCharacteristic]),
             communicate(AbleComm)
    }
}

struct CommView_Previews: PreviewProvider {
    static var previews: some View {
        CommView()
    }
}
