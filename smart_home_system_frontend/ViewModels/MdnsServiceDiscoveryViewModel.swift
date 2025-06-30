//
//  MdnsServiceDiscoveryViewModel.swift
//  smart_home_system_frontend
//
//  Created by Emmanuel Bastidas on 6/5/25.
//

import Foundation;
import Network
import CocoaMQTT

class MdnsServiceDiscoveryViewModel: ObservableObject{
    @Published var displayedDiscoveredServices: [MDNService] = []
    @Published var isError = false
    @Published var existingServicesLoaded = false
    private var serviceType: MdnsServiceType
    private var browser: NWBrowser
    private var existingServices: Set<MDNService> = []
    private var discoveredServices: Set<MDNService> = []
    
    
    init(serviceType: MdnsServiceType){
        self.serviceType = serviceType
        browser = NWBrowser(for: .bonjour(type: serviceType.rawValue, domain: nil), using: NWParameters())
        setupServiceDiscoveryBrowser(serviceType: serviceType.rawValue)
    }
    
    
    /**
     
     */
    @MainActor
    func fetchExistingServices() async throws{
        let URL_ENDPOINT: String = "http://localhost:8080/iot-devices?servicetype=\(serviceType.rawValue)"
        
        guard let url = URL(string: URL_ENDPOINT) else{print("error "); throw URLError(.badURL);}
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let decoder = JSONDecoder()
         do{
            // this decodes an array of type device
            let devices = try decoder.decode([Device].self, from: data)
             for device in devices {
                 existingServices.insert(MDNService(device: device))
             }
             existingServicesLoaded = true;
         }
         catch{
             isError = true
         }
    }
    
    
    /**
     
     */
    func startBrowsingServices(){
        browser.start(queue: .main)
    }
    
    
    /**
     
     */
    private func setupServiceDiscoveryBrowser(serviceType: String){
        browser.browseResultsChangedHandler = {(result, changes) in
                do{
                    for discoveredService in result{
                        self.discoveredServices.insert(try MDNService(mdnsDiscoveredService: discoveredService))
                    }
                    self.displayedDiscoveredServices = Array(self.discoveredServices.subtracting(self.existingServices))
                }
                
                catch{
                    print("could not make service")
                }
        }
        
        browser.stateUpdateHandler = {(state) in
            switch state{
                
            case .setup:
                print("browser set up")
            case .ready:
                print("ready")
            case .failed(_):
                print("failed")
            case .cancelled:
                print("cancelled")
            case .waiting(_):
                print("waiting")
            @unknown default:
                print("unkown")
            }
        }
    }
}
