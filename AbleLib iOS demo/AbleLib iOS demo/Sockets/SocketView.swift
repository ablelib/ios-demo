//
//  SocketView.swift
//  AbleLib iOS demo
//
//  Created by Gordan Glavaš on 12.01.2021..
//

import SwiftUI
import Able

let serviceId = AbleUUID(with: "12E61727-B41A-436F-B64D-4777B35F2294")
let charId = AbleUUID(with: "ABDD3056-28FA-441D-A470-55A75A52553A")

struct SocketView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("This screen demonstrates two concepts:\n1. Starting a server socket with an associated GATT server.\n2. Starting a client socket that connects to that server.\nYou need two devices to demo full communication. This example is compatible with its Android counterpart.")
                    .padding()
                    .padding(.bottom, 30)
                NavigationLink(destination: ClientSocketView(vm: CentralVm())) {
                    Text("Demo client socket")
                }.padding(.bottom, 15)
                NavigationLink(destination: ServerSocketView(vm: PeripheralVm())) {
                    Text("Demo server socket")
                }
            }
        }
    }
}

struct SocketView_Previews: PreviewProvider {
    static var previews: some View {
        SocketView()
    }
}
