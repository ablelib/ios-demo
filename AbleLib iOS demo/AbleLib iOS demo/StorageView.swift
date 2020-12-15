//
//  StorageView.swift
//  AbleLib iOS demo
//
//  Created by Gordan Glavaš on 02/11/2020.
//

import SwiftUI
import Able

struct StorageView: View {
    @State private var devices = [AbleDevice]()
    
    var body: some View {
        VStack {
            if devices.isEmpty {
                Text("Scan for devices and then add them to the storage")
            } else {
                DevicesList(devices: $devices) { device in
                    Button {
                        AbleDeviceStorage.default.remove(device: device)
                        refresh()
                    } label: {
                        Text("Delete")
                            .foregroundColor(.white)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 5)
                                            .foregroundColor(.red))
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
        devices = Array(AbleDeviceStorage.default.devices)
    }
}

struct StorageView_Previews: PreviewProvider {
    static var previews: some View {
        StorageView()
    }
}
