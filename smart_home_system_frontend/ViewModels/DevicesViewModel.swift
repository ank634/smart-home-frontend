//
//  DevicesViewModel.swift
//  smart_home_system_frontend
//
//  Created by Emmanuel Bastidas on 10/30/25.
//

import Foundation
import Observation
@Observable class DevicesViewModel{
    var screenState = ScreenState.loading
    var devices: [IotDevice] = []
    var deviceViewModels: [DeviceDisplayViewModelStrategy] = []
    
    func GetDevices() async throws {//-> [IotDevice]{
        guard let url = URL(string: "http://127.0.0.1:8080/iot-devices") else{
            screenState = .errorLoading
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse else{
            screenState = .errorLoading
            throw URLError(.badServerResponse)
        }
        
        if httpResponse.statusCode == 500{
            screenState = .errorLoading
            throw URLError(.badServerResponse)
        }
        
        let results = try JSONDecoder().decode([IotDevice].self, from: data)
        screenState = .loadedSuccefully
        devices = results
        print(devices)
    }
}
