//
//  DevicesViewModel.swift
//  smart_home_system_frontend
//
//  Created by Emmanuel Bastidas on 10/30/25.
//

import SwiftUI

struct DevicesView: View {
    var vm = DevicesViewModel()
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    

    var body: some View {
        NavigationStack{
            VStack{
                if vm.screenState == .loading{
                    VStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                        Text("Loading favorites...")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
                }
                else if vm.screenState == .loadedSuccefully{
                    ScrollView{
                        LazyVGrid(columns: columns, spacing: 20){
                            ForEach(vm.deviceViewModels, id: \.self.deviceName){strategy in
                                NavigationLink(destination: DeviceDetailView(device: strategy.device)){
                                    DeviceDisplayCard(vmStrategy: strategy, width: .infinity, height: 100.0)
                                }
                                .padding(20)
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    
                }
                else{
                    // TODO: add view for if can't load from the endpoint
                }
            }
            .navigationTitle("Main")
            .background(Color(red: 246 / 255, green: 246 / 255 , blue: 246 / 255))
        }
        .task {
            do{
                try await vm.GetDevices()
                vm.screenState = .loadedSuccefully
                vm.deviceViewModels = []
                for favorite in vm.devices {
                    if favorite.deviceType == "light"{
                        var strat = LightDisplayViewModelStrategy(topic: favorite.getTopic,
                                                                  room: "place holder",
                                                                  deviceName: favorite.deviceName,
                                                                  device: favorite)
                        
                        vm.deviceViewModels.append(strat)
                    }
                }
            }
            catch{
                vm.screenState = .errorLoading
                print("couldn't get favorites")
            }
            
        }
        .onDisappear(){
            
        }
    }
}
