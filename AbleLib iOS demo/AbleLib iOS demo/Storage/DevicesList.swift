//
//  DevicesList.swift
//  AbleLib iOS demo
//
//  Created by Gordan Glavaš on 02/11/2020.
//

import SwiftUI
import Able

struct DevicesList<ButtonView: View>: View {
    @Binding var devices: [AbleDevice]
    let button: (AbleDevice) -> ButtonView
    
    var body: some View {
        List(devices, id: \.identifier) { device in
            HStack {
                Text("\(device.name ?? "") \(device.identifier)")
                Spacer()
                button(device)
            }
        }
    }
}

struct DevicesList_Previews: PreviewProvider {
    static var previews: some View {
        DevicesList(devices: .constant([]), button: { _ in Button("Button") { } })
    }
}
