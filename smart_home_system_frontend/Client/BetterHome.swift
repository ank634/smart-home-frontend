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
        let URL = ""
    }
    
    
    
    func GetDevices() async throws -> [Device]{
        var fetchedDevices: [Device] = []
        guard let url = URL(string: "http://localhost:8080/iot-devices") else{
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse else{
            throw URLError(.badServerResponse)
        }
        
        let results = try JSONDecoder().decode([DeviceDto].self, from: data)
        
        for resultDto in results{
            switch resultDto{
                case .lightDto(let lightDto):
                fetchedDevices.append(.light(light: Light(mqttClient: mqttClient, lightDto: lightDto)))
            }
        }
        return fetchedDevices
    }
}

enum Device: Hashable, Identifiable, Observable {
    case light(light: Light)
    
    var id: Self{
        self
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
