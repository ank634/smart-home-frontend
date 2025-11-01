//
//  LightDetailViewModel.swift
//  smart_home_system_frontend
//
//  Created by Emmanuel Bastidas on 10/29/25.
//
import Observation
import Foundation

@Observable class DeviceDetailViewModel: MqttSubscriber{
    var device: IotDevice
    var isOn: Bool
    var deviceConnectionStatusObserver: DeviceConnectionStatusEventListener
    
    init(device: IotDevice) {
        self.device = device
        self.isOn = false
        self.deviceConnectionStatusObserver = DeviceConnectionStatusEventListener()
        MqttManager.shared.subscribe(topic: device.setTopic)
        MqttManager.shared.attach(topic: device.setTopic, subscriber: self)
        MqttManager.shared.subscribe(topic: "connectionstatus/\(device.deviceID)")
        MqttManager.shared.attach(topic: "connectionstatus/\(device.deviceID)", subscriber: deviceConnectionStatusObserver)
    }
    
    func togglePower(){
        var message = MqttLightMessageFormat(id: device.deviceID,
                                             type: DeviceType(rawValue: device.deviceType)!,
                                             isOn: !isOn,
                                             brightness: 100, r: 255, g: 255, b: 255)
        
        do{
            var data = try JSONEncoder().encode(message)
            MqttManager.shared.publish(topic: device.getTopic, data: String(data: data, encoding: .utf8)!)
        }
        catch{
            print("could not decode message going outward")
        }
        
        
    }
    
    func update(data: String) {
        do{
            let light = try JSONDecoder().decode(MqttLightMessageFormat.self, from: data.data(using: .utf8)!)
            DispatchQueue.main.async{
                self.isOn = light.isOn
            }
        }
        catch{
            print("Could not decode data on detailed page")
        }
    }
}
