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
    func parseDevice(txtRecords:[String : String], name: String)  -> IotDevice?
}

// MARK: Consider having just a strategy for the manufactor and in that method having helper methods that parse the devices
class CustomLightScanner: ScannerStrategy{
    var serviceType: MdnsServiceType
    
    init(serviceType: MdnsServiceType) {
        self.serviceType = serviceType
    }
    
    func parseDevice(txtRecords: [String : String], name: String) -> IotDevice? {
        guard let type = txtRecords["type"] else{
            return nil
        }
        
        // TODO: fix me
        if type.lowercased() == "light"{
            return IotDevice(deviceID: name, deviceName: name, deviceType: DeviceType.light.rawValue,
                                                   serviceType: serviceType.rawValue, manufactor: DeviceManufactor.custom.rawValue,
                                                   setTopic: "set" + name, getTopic: "get" + name, endPoint: name + ".local")
        }
        return nil
    }
}


class Scanner{
    var scanner: NWBrowser
    var scanningStrategy: ScannerStrategy
    var updateHandler: (_ results: Set<IotDevice>, _ changes: Set<IotDevice>) -> Void = {x,y in}
    var scannerStateUpdateHandler : (NWBrowser.State) -> Void = {x in}
    var state: NWBrowser.State
    private var browseResults: [IotDevice]
    
    // using escaping means that the function passed in will live beyond the scope it was declared in
    init(scanningStrategy: ScannerStrategy, updateHandler: @escaping (_ results: Set<IotDevice>, _ changes: Set<IotDevice>) -> Void) {
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

    public var results:[IotDevice] {return browseResults}
    
    public func cancel(){ scanner.cancel() }
    
    private func updateResults(_ results: Set<NWBrowser.Result>, _ changes: Set<NWBrowser.Result.Change>){
        var adaptedResults: Set<IotDevice> = Set<IotDevice>()
        let adaptedchanges: Set<IotDevice> = Set<IotDevice>()
        
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

