//
//  Scanner.swift
//  smart_home_system_frontend
//
//  Created by Emmanuel Bastidas on 8/4/25.
//

import Foundation
import Network

protocol ScannerStrategy{
    var serviceType: MdnsServiceType{get}
    func parseDevice(txtRecords:[String : String], name: String)  -> Device
}

class CustomLightScanner: ScannerStrategy{
    
    var serviceType: MdnsServiceType
    init(serviceType: MdnsServiceType) {
        self.serviceType = serviceType
    }
    
    func parseDevice(txtRecords: [String : String], name: String) -> Device {
        if let _ = txtRecords["light"]{
            return Device.light(light: LightDto(deviceID: name, deviceName: name, deviceType: DeviceType.light.rawValue,
                                                serviceType: serviceType.rawValue, manufactor: DeviceManufactor.custom.rawValue,
                                                setTopic: "set" + name, getTopic: "get" + name, endPoint: name + ".local",
                                                isDimmable: txtRecords["isdimmable"]!.lowercased() == "true", isRgb: txtRecords["isrgb"]!.lowercased() == "true"))
        }
        
        // TODO: remove this once we get more devices added
        return Device.light(light: LightDto(deviceID: name, deviceName: name, deviceType: DeviceType.light.rawValue,
                                            serviceType: serviceType.rawValue, manufactor: DeviceManufactor.custom.rawValue,
                                            setTopic: "set" + name, getTopic: "get" + name, endPoint: name + ".local",
                                            isDimmable: txtRecords["isdimmable"]!.lowercased() == "true", isRgb: txtRecords["isrgb"]!.lowercased() == "true"))
        
        
    }
}


class Scanner{
    var scanner: NWBrowser
    var scanningStrategy: ScannerStrategy
    var updateHandler: (_ results: Set<Device>, _ changes: Set<Device>) -> Void = {x,y in}
    var scannerStateUpdateHandler : (NWBrowser.State) -> Void = {x in}
    var state: NWBrowser.State
    private var browseResults: [Device]
    
    // using escaping means that the function passed in will live beyond the scope it was declared in
    init(scanningStrategy: ScannerStrategy, updateHandler: @escaping (_ results: Set<Device>, _ changes: Set<Device>) -> Void) {
        self.scanner = NWBrowser(for: .bonjourWithTXTRecord(type: scanningStrategy.serviceType.rawValue, domain: ".local"), using: .tcp)
        self.scanningStrategy = scanningStrategy
        self.state = .setup
        self.browseResults = []
        self.updateHandler = updateHandler
        scanner.browseResultsChangedHandler = updateResults(_:_:)
    }
    
    public func start(){ scanner.start(queue: DispatchQueue.main) }

    public var results:[Device] {return browseResults}
    
    public func cancel(){ scanner.cancel() }
    
    private func updateResults(_ results: Set<NWBrowser.Result>, _ changes: Set<NWBrowser.Result.Change>){
        var adaptedResults: Set<Device> = Set<Device>()
        let adaptedchanges: Set<Device> = Set<Device>()
        
        for item in results{
            if case let NWEndpoint.service(name, _, _, _) = item.endpoint{
                if case let NWBrowser.Result.Metadata.bonjour(txtRecord) = item.metadata{
                    let discoveredDevice = scanningStrategy.parseDevice(txtRecords: txtRecord.dictionary, name: name)
                    adaptedResults.insert(discoveredDevice)
                }
            }
        }
        browseResults = Array(adaptedResults)
        
        // TODO: make the changes feature but for now we are ok
        updateHandler(adaptedResults, adaptedchanges)
    }
    

    deinit { scanner.cancel() }
    
}
