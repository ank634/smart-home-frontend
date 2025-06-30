//
//  Device.swift
//  smart_home_system_frontend
//
//  Created by Emmanuel Bastidas on 6/20/25.
//

import Foundation
import Network
struct Device: Codable, Hashable{
    let DeviceID: String
    var DeviceName: String
    var DeviceType: String
    var ServiceType: String
    var SetTopic: String
    var GetTopic: String
    var DeviceUrl: String
}


