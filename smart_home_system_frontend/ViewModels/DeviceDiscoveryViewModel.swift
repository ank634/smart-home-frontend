//
//  DeviceDiscoveryViewModel.swift
//  smart_home_system_frontend
//
//  Created by Emmanuel Bastidas on 10/30/25.
//


import Observation
import Foundation
enum DeviceDiscoveryViewState{
    case IDLE
    case FETCHING_SAVED_DEVICES
    case FETCHING_SAVED_DEVICES_COMPLETE
    case SAVING_DEVICE
    case SAVING_DEVICE_COMPLETE
    case SAVING_DEVICE_COMPLETE_ERROR
}


@Observable class DeviceDiscoveryViewModel: ObservableObject {
    var discoveredDevices: [IotDevice] = []
    var savedDevices: [IotDevice] = []
    var isScanning: Bool = false
    var errorMessage: String? = nil
    var screenState: DeviceDiscoveryViewState = .FETCHING_SAVED_DEVICES
    
    private var scanner: Scanner
    
    // Computed: devices discovered but not saved yet
    var newDevices: [IotDevice] {
        discoveredDevices.filter { !savedDevices.contains($0) }
    }
    
    init() {
        // Initialize scanner with your strategy
        self.scanner = Scanner(scanningStrategy: CustomLightScanner(serviceType: .mqtt))
        
        // Assign closure to handle scanner results
        scanner.updateHandler = { [weak self] results, _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.discoveredDevices = Array(results)
            }
        }
        
        // Fetch saved devices on init
        Task {
            await fetchSavedDevices()
        }
    }
    
    func startScanning() {
        isScanning = true
        scanner.start()
    }
    
    func stopScanning() {
        isScanning = false
        scanner.cancel()
    }
    
    func fetchSavedDevices() async {
        guard let url = URL(string: "http://localhost:8080/iot-devices") else {
            errorMessage = "Invalid URL"
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            let devices = try decoder.decode([IotDevice].self, from: data)
            savedDevices = devices
            screenState = .FETCHING_SAVED_DEVICES_COMPLETE
        } catch {
            errorMessage = "Failed to fetch saved devices: \(error.localizedDescription)"
        }
    }
    
    func saveDevice(_ device: IotDevice) async {
        screenState = .SAVING_DEVICE
        
        guard let url = URL(string: "http://localhost:8080/iot-devices") else{
            screenState = .SAVING_DEVICE_COMPLETE_ERROR
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        do {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(device)
            print(String(data: request.httpBody!, encoding: .utf8))
            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                savedDevices.append(device)
                screenState  = .SAVING_DEVICE_COMPLETE
            } else {
                errorMessage = "Failed to save device"
                screenState = .SAVING_DEVICE_COMPLETE_ERROR
            }
        } catch {
            errorMessage = "Failed to save device: \(error.localizedDescription)"
            screenState = .SAVING_DEVICE_COMPLETE_ERROR
        }
    }
}

