//  NWBrowserResultToDeviceAdapter.swift
//  smart_home_system_frontend
//
//  Created by Emmanuel Bastidas on 6/26/25.
//

import Foundation
import Network

enum InvalidEndpointType: Error{
    case notMdnsService
}

class MDNService: Equatable, Hashable{
    var name: String
    var endpoint: String
    var serviceType: MdnsServiceType
    init(device: Device) {
        self.name = device.DeviceName
        self.endpoint = device.DeviceID
        //TODO: this should maybe throw some sort of exception
        self.serviceType = MdnsServiceType(rawValue: device.ServiceType) ?? .mqtt
    }
    
    init(mdnsDiscoveredService: NWBrowser.Result) throws{
        switch mdnsDiscoveredService.endpoint {
        case .hostPort(_, _):
            throw InvalidEndpointType.notMdnsService
        case .service(let name, let type, let domain, _):
            self.name = name
            self.serviceType = MdnsServiceType(rawValue: type) ?? .mqtt
            self.endpoint = name + "." + domain
        case .unix(_):
            throw InvalidEndpointType.notMdnsService
        case .url(_):
            throw InvalidEndpointType.notMdnsService
        case .opaque(_):
            throw InvalidEndpointType.notMdnsService
        @unknown default:
            throw InvalidEndpointType.notMdnsService
        }
    }
    
    static func == (lhs: MDNService, rhs: MDNService) -> Bool{
        return lhs.endpoint == rhs.endpoint && lhs.serviceType == rhs.serviceType
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(endpoint)
        hasher.combine(serviceType)
    }
}

