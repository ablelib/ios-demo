//
//  AbleLib_iOS_demoApp.swift
//  AbleLib iOS demo
//
//  Created by Gordan Glavaš on 02/11/2020.
//

import SwiftUI
import Able

@main
struct AbleLib_iOS_demoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        AbleLib.licenceKey = "b1684ac6-07ec-43ca-ab0b-da9c0d371631" // this licence is only valid for this demo
        AbleManager.shared.initialize()
        return true
    }
}
