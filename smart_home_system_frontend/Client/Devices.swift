//
//  Devices.swift
//  smart_home_system_frontend
//
//  Created by Emmanuel Bastidas on 7/29/25.
//

import Foundation
import CocoaMQTT
//
struct LightDto: Codable, Hashable{
    var deviceID: String
    var deviceName: String
    var deviceType:  String
    var serviceType: String
    var manufactor:  String
    var setTopic:    String
    var getTopic:    String
    var endPoint:    String
    var roomID:      Int?
    var isDimmable: Bool
    var isRgb: Bool
}

class IotDevice: Identifiable, Equatable, Hashable{
    var mqttClient: CocoaMQTT5
    var id: String
    var name: String
    var deviceType:  String
    var serviceType: String
    var manufactor:  String
    var setTopic:    String
    var getTopic:    String
    var roomID:      Int?
    

    init(mqttClient: CocoaMQTT5, id: String, name: String,
         deviceType: String, serviceType: String, manufactor: String,
         setTopic: String, getTopic: String, roomID: Int? = nil) {
        self.mqttClient = mqttClient
        self.id = id
        self.name = name
        self.deviceType = deviceType
        self.serviceType = serviceType
        self.manufactor = manufactor
        self.setTopic = setTopic
        self.getTopic = getTopic
        self.roomID = roomID
        
        mqttClient.subscribe(self.getTopic)
    }
    
    deinit{
        mqttClient.unsubscribe(self.getTopic)
    }
    
    static func == (lhs: IotDevice, rhs: IotDevice) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher){
        hasher.combine(id)
    }
}


class Light: IotDevice, ObservableObject{
    
    var lightDto: LightDto
    var isDimmable: Bool
    var isRgb: Bool
    @Published var isOn: Bool?
    @Published var brightness: Int?
    
    init(mqttClient: CocoaMQTT5, lightDto: LightDto) {
        isDimmable = lightDto.isDimmable
        isRgb = lightDto.isRgb
        isOn = nil
        brightness = nil
        self.lightDto = lightDto
        super.init(mqttClient: mqttClient, id: lightDto.deviceID, name: lightDto.deviceName, deviceType: lightDto.deviceType, serviceType: lightDto.serviceType, manufactor: lightDto.manufactor, setTopic: lightDto.setTopic, getTopic: lightDto.getTopic, roomID: lightDto.roomID)
    }
    
    deinit{
        mqttClient.unsubscribe(self.getTopic)
    }
    
    func turnOn(){
        self.isOn = true
        //
    }
    
    func turnOff(){
        self.isOn = false
    }
    
    func toggle(){
        self.isOn = !self.isOn!
    }
    
    func setBrightness(brightness: Int){
        self.brightness = brightness
    }
}




