//
//  DetailedLightView.swift
//  smart_home_system_frontend
//
//  Created by Emmanuel Bastidas on 10/29/25.
//

import SwiftUI

struct DeviceDetailView: View {
    var device: IotDevice
    var viewModel: DeviceDetailViewModel
    
    init(device: IotDevice) {
        self.device = device
        viewModel = DeviceDetailViewModel(device: device)
    }
    
    var body: some View {
        VStack(spacing: 24) {
            
            // Header Title + Connection Status Dot
            HStack {
                Text(viewModel.device.deviceName)
                    .font(.title2)
                    .bold()
                
                Spacer()
                
                Circle()
                    .fill(viewModel.deviceConnectionStatusObserver.isConnected ? .green : .red)
                    .frame(width: 14, height: 14)
            }
            
            // Power State Text
            Text(viewModel.isOn ? "Device is ON" : "Device is OFF")
                .font(.headline)
                .foregroundColor(viewModel.isOn ? .green : .red)
            
            // Toggle Button
            Button(action: {
                viewModel.togglePower()
            }) {
                Text(viewModel.isOn ? "Turn Off" : "Turn On")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.isOn ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            
            Spacer()
        }
        .padding(20)
        .navigationTitle("Device Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
}
