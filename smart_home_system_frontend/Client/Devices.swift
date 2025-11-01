//
//  Devices.swift
//  smart_home_system_frontend
//
//  Created by Emmanuel Bastidas on 7/29/25.
//

import Foundation
import CocoaMQTT
//
struct LightDto: Codable, Hashable{
    var deviceID: String
    var deviceName: String
    var deviceType:  String
    var serviceType: String
    var manufactor:  String
    var setTopic:    String
    var getTopic:    String
    var endPoint:    String
    var roomID:      Int?
    var isDimmable: Bool
    var isRgb: Bool
    
    // 
    enum CodingKeys: String, CodingKey {
        case deviceID = "DeviceID"
        case deviceName = "DeviceName"
        case deviceType = "DeviceType"
        case serviceType = "ServiceType"
        case manufactor = "Manufactor"
        case setTopic = "SetTopic"
        case getTopic = "GetTopic"
        case endPoint = "EndPoint"
        case roomID = "RoomID"
        case isDimmable = "IsDimmable"
        case isRgb = "IsRgb"
    }
}

struct IotDevice: Hashable, Codable{
    var deviceID: String
    var deviceName: String
    var deviceType:  String
    var serviceType: String
    var manufactor:  String
    var setTopic:    String
    var getTopic:    String
    var endPoint:    String
    var roomID:      Int?
    
    enum CodingKeys: String, CodingKey {
        case deviceID = "DeviceID"
        case deviceName = "DeviceName"
        case deviceType = "DeviceType"
        case serviceType = "ServiceType"
        case manufactor = "Manufactor"
        case setTopic = "SetTopic"
        case getTopic = "GetTopic"
        case endPoint = "EndPoint"
        case roomID = "RoomID"
    }
}


enum DeviceDto: Codable{
    case lightDto(lightDto: LightDto)
    
    enum CodingKeys: String, CodingKey{
        case deviceType = "DeviceType"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(DeviceType.self, forKey: CodingKeys.deviceType)
        
        switch type{
        case .light:
            self = .lightDto(lightDto: try LightDto(from: decoder))
        }
    }
    
    func encode(to encoder: any Encoder) throws {
        switch self {
        case .lightDto(let lightDto):
            try lightDto.encode(to: encoder)
        }
    }
}


