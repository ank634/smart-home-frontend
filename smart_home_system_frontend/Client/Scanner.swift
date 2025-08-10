//
//  Scanner.swift
//  smart_home_system_frontend
//
//  Created by Emmanuel Bastidas on 8/4/25.
//

import Foundation
import Network
import CocoaMQTT

protocol ScannerStrategy{
    var serviceType: MdnsServiceType{get}
    func parseDevice(txtRecords:[String : String], name: String)  -> Device?
}

// MARK: Consider having just a strategy for the manufactor and in that method having helper methods that parse the devices
class CustomLightScanner: ScannerStrategy{
    var serviceType: MdnsServiceType
    var mqttClient: CocoaMQTT5
    
    init(serviceType: MdnsServiceType, mqttClient: CocoaMQTT5) {
        self.serviceType = serviceType
        self.mqttClient = mqttClient
    }
    
    func parseDevice(txtRecords: [String : String], name: String) -> Device? {
        guard let type = txtRecords["type"] else{
            return nil
        }
        
        if type.lowercased() == "light"{
            return Device.light(light: Light(mqttClient: mqttClient, lightDto: LightDto(deviceID: name, deviceName: name, deviceType: DeviceType.light.rawValue,
                                                   serviceType: serviceType.rawValue, manufactor: DeviceManufactor.custom.rawValue,
                                                   setTopic: "set" + name, getTopic: "get" + name, endPoint: name + ".local",
                                                   isDimmable: txtRecords["isdimmable"]!.lowercased() == "true", isRgb: txtRecords["isrgb"]!.lowercased() == "true")))
        }
        return nil
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
        self.scanner = NWBrowser(for: .bonjourWithTXTRecord(type: scanningStrategy.serviceType.rawValue, domain: "local"), using: .tcp)
        self.scanningStrategy = scanningStrategy
        self.state = .setup
        self.browseResults = []
        self.updateHandler = updateHandler
        scanner.browseResultsChangedHandler = updateResults(_:_:)
    }
    
    init(scanningStrategy: ScannerStrategy) {
        self.scanner = NWBrowser(for: .bonjourWithTXTRecord(type: scanningStrategy.serviceType.rawValue, domain: "local"), using: .tcp)
        self.scanningStrategy = scanningStrategy
        self.state = .setup
        self.browseResults = []
        scanner.browseResultsChangedHandler = updateResults(_:_:)
    }
    
    public func start(){ scanner.start(queue: DispatchQueue.main) }

    public var results:[Device] {return browseResults}
    
    public func cancel(){ scanner.cancel() }
    
    private func updateResults(_ results: Set<NWBrowser.Result>, _ changes: Set<NWBrowser.Result.Change>){
        var adaptedResults: Set<Device> = Set<Device>()
        let adaptedchanges: Set<Device> = Set<Device>()
        
        for item in results{
            guard case let NWEndpoint.service(name, _, _, _) = item.endpoint,
                  case let NWBrowser.Result.Metadata.bonjour(txtRecord) = item.metadata,
                  let discoveredDevice = scanningStrategy.parseDevice(txtRecords: txtRecord.dictionary, name: name)
            else{
                continue
            }
            
            adaptedResults.insert(discoveredDevice)
        }
        browseResults = Array(adaptedResults)
        
        // TODO: make the changes feature but for now we are ok
        updateHandler(adaptedResults, adaptedchanges)
    }
    

    deinit { scanner.cancel() }
    
}
