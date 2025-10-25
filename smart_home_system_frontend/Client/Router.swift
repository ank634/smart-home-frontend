//
//  Router.swift
//  smart_home_system_frontend
//
//  Created by Emmanuel Bastidas on 10/17/25.
//

import Foundation
import CocoaMQTT

protocol MqttSubscriber: AnyObject{
    func update(data: String)
}


protocol MqttPublisher{
    func attach(topic: String, subscriber: MqttSubscriber)
    func detach(topic: String, subscriber: MqttSubscriber)
}


class MqttManager{
    private var client: CocoaMQTT5
    private var subscriptions: [String : [MqttSubscriber]]
    private var messageCache: [String : String] // cache for each me
    static let shared = MqttManager()
    
    
    private var pendingSubscriptions: Set<String> = []
    private var pendingPublishes: [(topic: String, data: String)] = []
    
    init() {
        // TODO: this may have to be unique later on
        let mqttClient = CocoaMQTT5(clientID: UUID().uuidString)
        mqttClient.autoReconnect = true
        mqttClient.cleanSession = false
        mqttClient.port = 1883
        // TODO: Discover the broker on mdns for the first time
        mqttClient.host = "localhost" // REPLACE WITH BROKER ADDRES
        
        client = mqttClient
        self.subscriptions = [:] // init dictionary
        self.messageCache = [:]
        
        self.client.delegate = self // must be last thing called because class must be init first
        mqttClient.connect()
    }
    
    /*
     * publish any messages if not connected queue up messages
     * to be published when connection is restablished
     */
    func publish(topic: String, data: String){
        if client.connState == .connected {
            let msg = CocoaMQTT5Message(topic: topic, string: data)
            client.publish(msg, properties: MqttPublishProperties())
        } else {
            pendingPublishes.append((topic, data))
        }
    }
    
    // TODO: Consider removing and adding to attach and detach methods
    /*
     * subscribe any topic if not connected queue up messages
     * to be subscribed when connection is restablished
     */
    func subscribe(topic: String){
        let subscribers = self.subscriptions[topic]
        if subscribers == nil{
            if client.connState == .connected {
                client.subscribe(topic)
            } else {
                pendingSubscriptions.insert(topic)
            }
        }
    }
    
    func unsubscribe(topic: String){
        client.unsubscribe(topic)
    }
    
    func disconnect(){
        client.disconnect()
    }
    
    func getSubScriptions() -> [String:[MqttSubscriber]]{
        return subscriptions
    }
    
    func getCachedValueForTopic(topic: String) -> String?{
        return messageCache[topic]
    }
}


extension MqttManager: MqttPublisher{
    func attach(topic: String, subscriber: any MqttSubscriber) {
        if var subscribers = subscriptions[topic]{
            subscribers.append(subscriber)
            // must reassign the topic of subscribers
            // subscribers is a copy and changes won't effect
            subscriptions[topic] = subscribers
        } else{
            subscriptions[topic] = []
            subscriptions[topic]!.append(subscriber)
        }
        
        if let lastCachedMessage = messageCache[topic]{
            subscriber.update(data: lastCachedMessage)
        }
    }
    
    func detach(topic: String, subscriber: any MqttSubscriber) {
        if var subscribers = subscriptions[topic]{
            subscribers.removeAll(where: {$0 === subscriber})
            subscriptions[topic] = subscribers
        }
    }
}


extension MqttManager: CocoaMQTT5Delegate{
    func mqtt5(_ mqtt5: CocoaMQTT5, didConnectAck ack: CocoaMQTTCONNACKReasonCode, connAckData: MqttDecodeConnAck?) {
        // resubscribe if connection was lost
        //for topic in subscriptions.keys{
        //    client.subscribe(topic)
        //}
        // if you tried to subscribe before connection established now subscribe
        for pendingSubscription in self.pendingSubscriptions {
            client.subscribe(pendingSubscription)
        }
        pendingSubscriptions.removeAll()
        // if you tried to publish before connection established now publish
        for pendingPublish in self.pendingPublishes {
            client.publish(CocoaMQTT5Message(topic: pendingPublish.topic, string: pendingPublish.data), properties: MqttPublishProperties())
        }
        pendingPublishes.removeAll()
    }
    
    func mqtt5(_ mqtt5: CocoaMQTT5, didPublishMessage message: CocoaMQTT5Message, id: UInt16) {
        print("didPublishMessage")
    }
    
    func mqtt5(_ mqtt5: CocoaMQTT5, didPublishAck id: UInt16, pubAckData: MqttDecodePubAck?) {
        print("didPublishAck")
    }
    
    func mqtt5(_ mqtt5: CocoaMQTT5, didPublishRec id: UInt16, pubRecData: MqttDecodePubRec?) {
        print("didPublishRec")
    }
    
    // send out message to all observers of topics
    func mqtt5(_ mqtt5: CocoaMQTT5, didReceiveMessage message: CocoaMQTT5Message, id: UInt16, publishData: MqttDecodePublish?) {
        if let messageString = message.string{
            messageCache[message.topic] = messageString
            if let subscribers = subscriptions[message.topic]{
                for subscriber in subscribers {
                    subscriber.update(data: messageString)
                }
            }
        }
    }
    
    func mqtt5(_ mqtt5: CocoaMQTT5, didSubscribeTopics success: NSDictionary, failed: [String], subAckData: MqttDecodeSubAck?) {
        print("didSubscribeTopics")
    }
    
    func mqtt5(_ mqtt5: CocoaMQTT5, didUnsubscribeTopics topics: [String], unsubAckData: MqttDecodeUnsubAck?) {
        print("didUnsubscribeTopics")
    }
    
    func mqtt5(_ mqtt5: CocoaMQTT5, didReceiveDisconnectReasonCode reasonCode: CocoaMQTTDISCONNECTReasonCode) {
        print("didReceiveDisconnectReasonCode")
    }
    
    func mqtt5(_ mqtt5: CocoaMQTT5, didReceiveAuthReasonCode reasonCode: CocoaMQTTAUTHReasonCode) {
        print("didReceiveAuthReasonCode")
    }
    
    func mqtt5DidPing(_ mqtt5: CocoaMQTT5) {
        print("Did pint")
    }
    
    func mqtt5DidReceivePong(_ mqtt5: CocoaMQTT5) {
        print("did pong")
    }
    
    func mqtt5DidDisconnect(_ mqtt5: CocoaMQTT5, withError err: (any Error)?) {
        print("did disconnect")
    }
}


