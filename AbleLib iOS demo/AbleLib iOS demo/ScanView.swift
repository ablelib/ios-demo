//
//  ScanView.swift
//  AbleLib iOS demo
//
//  Created by Gordan Glavaš on 02/11/2020.
//

import SwiftUI
import Able

struct ScanView: View {
    @State private var isScanning = false
    @State private var devices = [AbleDevice]()
    @State private var refresh = false
    
    var body: some View {
        VStack {
            if isScanning {
                ProgressView()
                Button("Stop scanning") {
                    AbleManager.shared.stopScan()
                    isScanning = false
                }.padding(.vertical, 10)
            } else {
                if devices.isEmpty {
                    Text("Find nearby devices")
                } else {
                    DevicesList(devices: $devices) { device in
                        Group {
                            if AbleDeviceStorage.find(device: device) == nil {
                                Button {
                                    AbleDeviceStorage.add(device: device)
                                    refresh.toggle()
                                } label: {
                                    Text("Store")
                                        .padding()
                                        .background(RoundedRectangle(cornerRadius: 5)
                                                        .foregroundColor(.gray))
                                }
                            }
                        }
                    }
                }
                Button("Scan") {
                    isScanning = true
                    AbleManager.shared.scan { result in
                        isScanning = false
                        switch result {
                        case .success(let infos):
                            devices = Array(infos.devices)
                        case .failure(let error):
                            print("Error while scanning: \(error)")
                        }
                    }
                }.padding(.vertical, 10)
            }
        }
    }
}

struct ScanView_Previews: PreviewProvider {
    static var previews: some View {
        ScanView()
    }
}
