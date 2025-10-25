//
//  FavoritesView.swift
//  smart_home_system_frontend
//
//  Created by Emmanuel Bastidas on 10/23/25.
//

import SwiftUI

struct FavoritesView: View {
    var strats: [DeviceDisplayCard]
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    

    init() {
        strats = []
        for i in 0...10{
            strats.append( DeviceDisplayCard(vmStrategy: LightDisplayViewModelStrategy(topic: "light", room: "room \(i)", deviceName: "light\(i)"), width: 200, height: 150))
        }
    }
    var body: some View {
        NavigationStack{
            VStack{
                ScrollView{
                    LazyVGrid(columns: columns, spacing: 20){
                        ForEach(strats, id: \.self.vm.viewModelStrategy.deviceName){card in
                            NavigationLink(destination: testView()){
                                card
                            }
                            .padding()
                            .buttonStyle(.plain)
                        }
                    }
                }
                .navigationTitle("Main")
                .background(Color(red: 246 / 255, green: 246 / 255 , blue: 246 / 255))
            }
        }
    }
}

struct testView: View {
    var body: some View {
        Text("one level deeper")
    }
}
#Preview {
    FavoritesView()
}
