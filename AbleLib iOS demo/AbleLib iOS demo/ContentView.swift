//
//  ContentView.swift
//  AbleLib iOS demo
//
//  Created by Gordan Glavaš on 02/11/2020.
//

import SwiftUI
import Able

struct ContentView: View {
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        TabView {
            ScanView()
                .tabItem {
                    Image(systemName: "antenna.radiowaves.left.and.right")
                    Text("Scan")
                }
            StorageView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Storage")
                }
            CommView()
                .tabItem {
                    Image(systemName: "paperplane")
                    Text("Comm")
                }
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }.onAppear {
            checkState()
        }.alert(isPresented: $showError) {
            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("Retry"), action: {
                checkState()
            }))
        }
    }
    
    private func checkState() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // Add a slight delay to let everything come online
            if !AbleManager.shared.isAuthorized {
                showError(message: "Please grant Bluetooth permissions to the app!")
            } else if !AbleManager.shared.isBluetoothOn {
                showError(message: "Please turn Bluetooth on!")
            }
        }
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
