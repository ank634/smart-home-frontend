//
//  MdnsServiceDiscoveryView.swift
//  smart_home_system_frontend
//
//  Created by Emmanuel Bastidas on 6/5/25.
//

import SwiftUI

struct MdnsServiceDiscoveryView: View {
    let serviceType: MdnsServiceType
    @StateObject private var viewModel: MdnsServiceDiscoveryViewModel
    init(serviceType: MdnsServiceType) {
        self.serviceType = serviceType
        //https://docs.swift.org/swift-book/documentation/the-swift-programming-language/properties/#Property-Wrappers
        //https://stackoverflow.com/questions/65209314/what-does-the-underscore-mean-before-a-variable-in-swiftui-in-an-init
        //https://www.hackingwithswift.com/forums/swiftui/variable-confusion/12888
        _viewModel = StateObject(wrappedValue: MdnsServiceDiscoveryViewModel(serviceType: serviceType))
    }
    
    
    var body: some View {
        NavigationStack{
            VStack{
                if viewModel.existingServicesLoaded == true{
                    List{
                        ForEach(viewModel.displayedDiscoveredServices, id: \.self){service in
                            NavigationLink(service.name, value: service)
                        }
                    }
                    .navigationDestination(for: MDNService.self){selection in
                        Text(selection.name)
                    }
                }
                
                else{
                    ProgressView()
                }
            }
        }

        // must fetch before browsing to make sure services load first
        // MARK: Look into maybe making a function that bundles both like a factory method
        .task {
            do{
                try await viewModel.fetchExistingServices()
                viewModel.startBrowsingServices()
            }
            catch{
                print("could not get error")
            }
        }
    }
}
