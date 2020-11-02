//
//  CommView.swift
//  AbleLib iOS demo
//
//  Created by Gordan Glavaš on 02/11/2020.
//

import SwiftUI
import Able

struct CommView: View {
    @State private var devices = [AbleDevice]()
    @State private var comm: AbleComm? = nil
    
    var body: some View {
        VStack {
            if comm != nil {
                HStack {
                    Button("Disconnect") {
                        comm?.disconnect { _, error in
                            if let error = error {
                                print("Error disconnecting \(error)")
                            } else {
                                comm = nil
                            }
                        }
                    }
                }
            } else {
                if devices.isEmpty {
                    Text("Scan for devices and then add them to the storage")
                } else {
                    DevicesList(devices: $devices) { device in
                        Button {
                            comm = device.comm
                            comm?.connect(onSuccess: { device in
                                
                            }, onFailure: { (device, error) in
                                
                            })
                        } label: {
                            Text("Connect")
                                .foregroundColor(.white)
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 5)
                                                .foregroundColor(.green))
                        }
                    }
                }
            }
            HStack {
                Button("Refresh") {
                    refresh()
                }
            }.padding(.vertical, 10)
        }.onAppear(perform: refresh)
    }
    
    private func refresh() {
        devices = Array(AbleDeviceStorage.devices)
    }
}

struct CommView_Previews: PreviewProvider {
    static var previews: some View {
        CommView()
    }
}
