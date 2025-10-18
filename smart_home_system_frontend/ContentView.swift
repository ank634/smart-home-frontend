//
//  ContentView.swift
//  smart_home_system_frontend
//
//  Created by Emmanuel Bastidas on 6/5/25.
//

import SwiftUI
import CocoaMQTT

struct ContentView: View {
    @StateObject var test = testSub()
    var body: some View{
        
        TabView{
            Tab("Home", systemImage: "house.fill"){
                Text(test.x)
            }
            
            Tab("Add Device", systemImage: "plus.circle"){
               
            }
            
            Tab("Favorites", systemImage: "heart.fill"){
                
            }
        }
    }
}

#Preview {
    ContentView()
}

class testSub: Subscriber, ObservableObject{
    @Published var x: String = ""
    init() {
        MqttManager.shared.subscribe(topic: "gigity")
        MqttManager.shared.attach(topic: "gigity", subscriber: self)
    }
    func update(data: String) {
        DispatchQueue.main.async {
            self.x = data
        }
    }
}
