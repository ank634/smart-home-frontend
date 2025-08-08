//
//  types.swift
//  smart_home_system_frontend
//
//  Created by Emmanuel Bastidas on 6/6/25.
//

enum MdnsServiceType: String{
    case http = "_http._tcp"
    case mqtt = "_mqtt._tcp"
    // dummy service remove
    case light = "light"
}

enum DeviceType: String{
    case light = "light"
}

enum DeviceManufactor: String{
    case custom = "custom"
    case esphome = "esphome"
}

