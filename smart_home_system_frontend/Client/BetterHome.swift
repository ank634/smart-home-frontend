//
//  BetterHome.swift
//  smart_home_system_frontend
//
//  Created by Emmanuel Bastidas on 8/4/25.
//

import Foundation
import CocoaMQTT
struct ProblemDetails: Codable{
    var errorType: BetterHomeError
    var title: String
    var status: Int
    var detail: String
    
    enum CodingKeys: String, CodingKey{
        case errorType = "ErrorType"
        case title = "Title"
        case status = "Status"
        case detail = "Detail"
    }
}

class BetterHome{
    let mqttClient: CocoaMQTT5
    
    
    init(mqttClient: CocoaMQTT5) {
        self.mqttClient = mqttClient
    }
    
    func AddDevice(device: LightDto) async throws{
        guard let url = URL(string: "http://localhost:8080/iot-devices") else{
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try JSONEncoder().encode(device)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else{
            throw URLError(.badServerResponse)
        }
        
        if httpResponse.statusCode == 500{
            throw URLError(.badServerResponse)
        }
        
        if httpResponse.statusCode == 400{
            var problemDetails = try JSONDecoder().decode(ProblemDetails.self, from: data)
            throw problemDetails.errorType
        }
        
    }
    
    func EditDevice(deviceId: String, newName: String) async throws{
        guard let url = URL(string: "http://localhost:8080/iot-devices/\(deviceId)") else{
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let body = ["DeviceName": newName]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else{
            throw URLError(.badServerResponse)
        }
        
        if httpResponse.statusCode == 500{
            throw URLError(.badServerResponse)
        }
        
        if httpResponse.statusCode == 400{
            var problemDetails = try JSONDecoder().decode(ProblemDetails.self, from: data)
            throw problemDetails.errorType
        }
    }
    
    
    func DeleteDevice(deviceId: String) async throws{
        guard let url = URL(string: "http://localhost:8080/iot-devices/\(deviceId)") else{
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else{
            throw URLError(.badServerResponse)
        }
        
        if httpResponse.statusCode == 500{
            throw URLError(.badServerResponse)
        }
        
        if httpResponse.statusCode == 404{
            throw URLError(.fileDoesNotExist)
        }
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
        
        if httpResponse.statusCode == 500{
            throw URLError(.badServerResponse)
        }
        
        let results = try JSONDecoder().decode([DeviceDto].self, from: data)
        
        for resultDto in results{
            switch resultDto{
                case .lightDto(let lightDto):
                fetchedDevices.append(.light(light: Light(mqttClient: mqttClient, lightDto: lightDto)))
                default:
                    print("Not implemented all switch cases")
            }
        }
        return fetchedDevices
    }
}
