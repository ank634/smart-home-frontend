//
//  MessageFormat.swift
//  smart_home_system_frontend
//
//  Created by Emmanuel Bastidas on 8/13/25.
//

struct MqttLightMessageFormat: Codable{
    var id: String
    var type: DeviceType
    var isOn: Bool
    var brightness: Int
    var r: Int
    var g: Int
    var b: Int
    
    init(id: String, type: DeviceType, isOn: Bool, brightness: Int, r: Int, g: Int, b: Int) {
        self.id = id
        self.type = type
        self.isOn = isOn
        
        // clamp to make sure we only have values 0 - 255
        self.brightness = max(0, min(255, brightness))
        self.r = max(0, min(255, r))
        self.g = max(0, min(255, g))
        self.b = max(0, min(255, b))
    }
}
