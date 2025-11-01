import SwiftUI

struct DeviceDiscoveryView: View {
    var viewModel = DeviceDiscoveryViewModel()
    
    var body: some View {
        VStack(spacing: 16) {
            
            // Scanning indicator
            if viewModel.isScanning {
                ProgressView("Scanning for devices…")
            }
            
            if viewModel.screenState == .FETCHING_SAVED_DEVICES{
                ProgressView("Loading Saved Devices")
            }
            
            else if viewModel.screenState == .FETCHING_SAVED_DEVICES_COMPLETE{
                List {
                    // New devices (not saved yet)
                    if !viewModel.newDevices.isEmpty {
                        Section("New Devices") {
                            ForEach(viewModel.newDevices, id: \.deviceID) { device in
                                DeviceRowView(device: device) { updatedDevice in
                                    viewModel.isScanning = false
                                    await viewModel.saveDevice(updatedDevice)
                                }
                            }
                        }
                    }
                }
                .onAppear(){
                    viewModel.startScanning()
                    viewModel.isScanning = true
                }
                .onDisappear(){
                    viewModel.stopScanning()
                    viewModel.isScanning = false
                }
                
            }
            
            else if viewModel.screenState == .SAVING_DEVICE{
                ProgressView("saving device")
            }
            
            else if viewModel.screenState == .SAVING_DEVICE_COMPLETE{
                Text("Succesfully added device")
            }
            
            else if viewModel.screenState == .SAVING_DEVICE_COMPLETE_ERROR{
                DeviceFailure()
            }
                
                
            
            
        }
        .navigationTitle("Discover Devices")
        .task {
            viewModel.screenState = .FETCHING_SAVED_DEVICES
            viewModel.savedDevices = []
            await viewModel.fetchSavedDevices()
            viewModel.screenState = .FETCHING_SAVED_DEVICES_COMPLETE
        }
    }
}

struct DeviceRowView: View {
    @State private var deviceName: String
    let device: IotDevice
    let onSave: (IotDevice) async -> Void

    init(device: IotDevice, onSave: @escaping (IotDevice) async -> Void) {
        self.device = device
        self._deviceName = State(initialValue: device.deviceName)
        self.onSave = onSave
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            TextField("Enter device name", text: $deviceName)
                .textFieldStyle(.roundedBorder)
            
            Button(action: {
                var updatedDevice = device
                updatedDevice.deviceName = deviceName
                Task {
                    await onSave(updatedDevice)
                }
            }) {
                Text("Add Device")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.vertical, 4)
    }
}


struct DeviceFailure: View {
    var body: some View {
        Text("Failed to add")
    }
}

struct DeviceSuccess: View {
    var body: some View {
        Text("Successfully added device")
    }
}
