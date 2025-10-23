//
//  DeviceDisplayCard.swift
//  smart_home_system_frontend
//
//  Created by Emmanuel Bastidas on 10/22/25.
//

import SwiftUI
import Observation

struct DeviceDisplayCard: View {
    var vm: DeviceDisplayViewModel
    init(vmStrategy: any DeviceDisplayViewModelStrategy) {
        self.vm = DeviceDisplayViewModel(viewModelStrategy: vmStrategy)
    }
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 12.00)
                .fill(.white)
            VStack{
                Image(systemName: vm.viewModelStrategy.image)
                    .resizable()
                    .frame(width: 50, height: 35)
                Text(vm.viewModelStrategy.room)
                Text(vm.viewModelStrategy.deviceName)
                Text(vm.viewModelStrategy.state)
            }
            .padding(20)
        }
        .frame(width: 175, height: 175)
        .shadow(radius: 10)
    }
}

class DeviceDisplayViewModel{
    var viewModelStrategy: any DeviceDisplayViewModelStrategy
    init(viewModelStrategy: any DeviceDisplayViewModelStrategy) {
        self.viewModelStrategy = viewModelStrategy
    }
}


protocol DeviceDisplayViewModelStrategy: MqttSubscriber{
    var image: String {get}
    var room: String {get}
    var deviceName: String {get}
    var state: String {get set}
    var topic: String {get}
}

@Observable class LightDisplayViewModelStrategy: DeviceDisplayViewModelStrategy{
    var topic: String
    var image: String
    var room: String
    var deviceName: String
    var state: String
    
    init(topic: String, room: String, deviceName: String) {
        self.topic = topic
        self.image = "light.max"
        self.state = ""
        self.room = room
        self.deviceName = deviceName
        // MARK: this may have to be moved to the onappear of the view
        MqttManager.shared.subscribe(topic: topic)
        MqttManager.shared.attach(topic: topic, subscriber: self)
    }
    
    
    func update(data: String) {
        do{
            let light = try JSONDecoder().decode(MqttLightMessageFormat.self, from: data.data(using: .utf8)!)
            if light.isOn{
                DispatchQueue.main.async {
                    self.state = "ON"
                }
            }
            else{
                DispatchQueue.main.async {
                    self.state = "OFF"
                }
            }
        }
        catch{
            print("could not decode data")
        }
    }
}

#Preview {
    var strat = LightDisplayViewModelStrategy(topic: "light", room: "my room", deviceName: "living room light")
    DeviceDisplayCard(vmStrategy: strat)
}
