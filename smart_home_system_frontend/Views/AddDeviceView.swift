//
//  AddDeviceView.swift
//  smart_home_system_frontend
//
//  Created by Emmanuel Bastidas on 6/29/25.
//

import SwiftUI

struct AddDeviceView: View {
    var deviceType: DeviceType
    var device: MDNService
    var body: some View {
        Text(device.name)
        Button("Add device"){
            Task{
                try await addDevice()
            }
        }
    }
    func addDevice() async throws{
        let deviceToAdd: Device = Device(DeviceID: device.name, DeviceName: device.name,
                                         DeviceType: deviceType.rawValue, ServiceType: device.serviceType.rawValue,
                                         SetTopic: "set" + device.name, GetTopic: "get" + device.name,
                                         DeviceUrl: device.endpoint)
        
        
        let URL_ENDPOINT: String = "http://localhost:8080/iot-devices"
        guard let url = URL(string: URL_ENDPOINT) else{print("error "); throw URLError(.badURL);}
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let encoder = JSONEncoder()
         do{
             let jsonEncodedDevice = try encoder.encode(deviceToAdd)
             request.httpBody = jsonEncodedDevice
             let (data, _) = try await URLSession.shared.data(for: request)
         }
         catch{
          print("could not add device ecinder issue or network issue")
         }
    }
}
