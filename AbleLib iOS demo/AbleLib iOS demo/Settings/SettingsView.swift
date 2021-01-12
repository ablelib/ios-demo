//
//  SettingsView.swift
//  AbleLib iOS demo
//
//  Created by Gordan Glavaš on 02/11/2020.
//

import SwiftUI
import Able

struct SettingsView: View {
    private let QOS = [QualityOfService.LOW_ENERGY, QualityOfService.DEFAULT, QualityOfService.INTENSIVE]
    @State private var refresh = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if refresh {
                EmptyView()
            }
            Text("Quality of Service")
            ForEach(0..<QOS.count) { i in
                HStack {
                    Button(String(describing: QOS[i])) {
                        AbleManager.shared.qualityOfService = QOS[i]
                        refresh.toggle()
                    }
                    Spacer()
                    if QOS[i] == AbleManager.shared.qualityOfService {
                        Image(systemName: "checkmark")
                    }
                }
            }
            Spacer()
        }.padding()
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
