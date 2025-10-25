//
//  DeviceDisplayCard.swift
//  smart_home_system_frontend
//
//  Created by Emmanuel Bastidas on 10/22/25.
//

import SwiftUI
import Observation

// TODO: make it so I can pass in width and height then it scales it correctly
struct DeviceDisplayCard: View {
    var width: CGFloat
    var height: CGFloat
    var vm: DeviceDisplayViewModel
    /*
     MARK: this view is rebuilt everytime and so is the object however since this is passed in we are ok
     MARK: for now at least this could cause issues in the future but at least here we should be good in the upper
     MARK: levels though we need to make it state so we don't lose it...
     */
    init(vmStrategy: any DeviceDisplayViewModelStrategy, width: CGFloat, height: CGFloat) {
        self.vm = DeviceDisplayViewModel(viewModelStrategy: vmStrategy)
        self.width = width
        self.height = height
    }
    
    var body: some View {
        ZStack {
            // Card background with subtle shadow
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .gray.opacity(0.15), radius: 4, x: 0, y: 2)
            
            VStack(spacing: 8) {
                // Top Row: connection indicator + room name
                HStack {
                    Spacer()
                    Circle()
                        .fill(vm.viewModelStrategy.deviceConnectionStatusObserver.isConnected == false
                              ? Color.red.opacity(0.6)
                              : Color.green.opacity(0.6))
                        .frame(width: 10, height: 10)
                    
                    
                }
                .padding(.horizontal, 10)
                .padding(.top, 8)
                
                Spacer()
                
                // Device image
                Image(systemName: vm.viewModelStrategy.image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: width * 0.4, height: height * 0.25)
                    .foregroundStyle(vm.viewModelStrategy.imageColor)
                    .padding(.vertical, 6)
                
                // Device name
                Text(vm.viewModelStrategy.deviceName)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .padding(.horizontal, 8)
                
                // State label (ON / OFF)
                Text(vm.viewModelStrategy.state)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding(.bottom, 10)
                    .foregroundStyle(vm.viewModelStrategy.stateStringColor)
                
                Spacer()
            }
        }
        .frame(width: width, height: height)
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
    var imageColor: Color {get set}
    var deviceName: String {get}
    var state: String {get set}
    var topic: String {get}
    var stateStringColor: Color {get set}
    var deviceConnectionStatusObserver: DeviceConnectionStatusEventListener {get set}
}

@Observable class LightDisplayViewModelStrategy: DeviceDisplayViewModelStrategy{
    var topic: String
    var image: String
    var room: String
    var deviceName: String
    var state: String
    var imageColor: Color
    var stateStringColor: Color
    var deviceConnectionStatusObserver: DeviceConnectionStatusEventListener
    
    init(topic: String, room: String, deviceName: String) {
        self.topic = topic
        self.image = "light.max"
        self.state = ""
        self.room = room
        self.deviceName = deviceName
        self.imageColor = .yellow
        self.stateStringColor = .blue
        self.deviceConnectionStatusObserver = DeviceConnectionStatusEventListener()
        // MARK: this may have to be moved to the onappear of the view
        MqttManager.shared.subscribe(topic: topic)
        MqttManager.shared.attach(topic: topic, subscriber: self)
        MqttManager.shared.subscribe(topic: "connectionstatus/\(topic)")
        MqttManager.shared.attach(topic: "connectionstatus/\(topic)", subscriber: deviceConnectionStatusObserver)
    }
    
    
    func update(data: String) {
        do{
            let light = try JSONDecoder().decode(MqttLightMessageFormat.self, from: data.data(using: .utf8)!)
            if light.isOn{
                DispatchQueue.main.async {
                    self.state = "ON"
                    self.imageColor = .yellow
                    self.stateStringColor = .black
                }
            }
            else{
                DispatchQueue.main.async {
                    self.state = "OFF"
                    self.imageColor = .gray
                    self.stateStringColor = .gray
                }
            }
        }
        catch{
            print("could not decode data")
        }
    }
}

/**
 Subscribes to the topic of connectionStatus/deviceId to determine if smarthome device is currently connected to the broker.
 To use in a view model must do owningclassObject.DeviceConnectionStatusEventListenerObject.isConnected in the view
 DONT forget to detach to prevent memory leaks
 */
@Observable class DeviceConnectionStatusEventListener: MqttSubscriber{
    var isConnected: Bool
    init() {
        isConnected = false
    }
    
    func update(data: String) {
        do{
            let connectionStatus = try JSONDecoder().decode(MqttConnectionStatusFormat.self, from: data.data(using: .utf8)!)
            DispatchQueue.main.async {
                self.isConnected = connectionStatus.isConnected
            }
        }
        catch{
            print("could not decode data hi")
        }
        
    }
}

#Preview {
    var strat = LightDisplayViewModelStrategy(topic: "light", room: "my room", deviceName: "living room light")
}
