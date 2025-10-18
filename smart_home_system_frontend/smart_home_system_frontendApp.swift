//
//  smart_home_system_frontendApp.swift
//  smart_home_system_frontend
//
//  Created by Emmanuel Bastidas on 6/5/25.
//

import SwiftUI
import CocoaMQTT

@main
struct smart_home_system_frontendApp: App {
    init() {
        MqttManager.shared.subscribe(topic: "gigity")
        //MqttManager.shared.publish(topic: "gigity", data: "hi guhys")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
