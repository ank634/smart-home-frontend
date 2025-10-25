//
//  ContentView.swift
//  smart_home_system_frontend
//
//  Created by Emmanuel Bastidas on 6/5/25.
//

import SwiftUI
import CocoaMQTT

struct ContentView: View {
    @StateObject var test1 = testSub(topic: "gigity")
    @StateObject var test2 = testSub(topic: "wigity")
    var body: some View{
        
        TabView{
            Tab("Home", systemImage: "house.fill"){
                Text(test1.x)
            }
            
            Tab("Add Device", systemImage: "plus.circle"){
                Text(test2.x)
            }
            
            Tab("Favorites", systemImage: "heart.fill"){
                FavoritesView()
            }
        }
    }
}

#Preview {
    ContentView()
}

class testSub: MqttSubscriber, ObservableObject{
    @Published var x: String = ""
    init(topic: String) {
        MqttManager.shared.subscribe(topic: topic)
        MqttManager.shared.attach(topic: topic, subscriber: self)
    }
    func update(data: String) {
        DispatchQueue.main.async {
            self.x = data
        }
    }
}
