//
//  BetterHome.swift
//  smart_home_system_frontend
//
//  Created by Emmanuel Bastidas on 8/4/25.
//

import Foundation
import CocoaMQTT
class BetterHome{
    let mqttClient: CocoaMQTT5
    
    
    init(mqttClient: CocoaMQTT5) {
        self.mqttClient = mqttClient
    }
    
    func AddDevice(device: LightDto){
        
    }
    
    func EditDevice(deviceId: String, newName: String){
        
    }
    
    
    func DeleteDevice(deviceId: String){
        
    }
    
    
    
    func GetDevices() -> [Device]?{
        return nil
    }
}

enum Device: Hashable {
    case light(light: LightDto)
}
