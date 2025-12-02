//
//  MQTTService.swift
//  GuopazIOT
//
//  Created on 2025/11/28.
//

import Foundation
import Combine
import CocoaMQTT

/// MQTT服务实现
class MQTTService: NSObject, MQTTServiceProtocol {
    // MARK: - Properties
    
    /// 连接状态发布者
    let connectionState = CurrentValueSubject<MQTTConnectionState, Never>(.disconnected)
    
    /// 接收到的消息发布者
    let receivedMessages = PassthroughSubject<MQTTMessage, Never>()
    
    /// CocoaMQTT实例
    private var mqtt: CocoaMQTT?
    
    /// 当前配置
    private var currentConfig: MQTTConfiguration?
    
    /// 是否已连接
    var isConnected: Bool {
        return mqtt?.connState == .connected
    }
    
    // MARK: - Public Methods
    
    /// 连接MQTT服务器
    func connect(config: MQTTConfiguration) async -> Result<Void, MQTTError> {
        // 如果已连接，先断开
        if isConnected {
            disconnect()
        }
        
        // 验证配置
        guard !config.host.isEmpty, config.port > 0 else {
            return .failure(.invalidConfiguration)
        }
        
        currentConfig = config
        
        // 创建CocoaMQTT实例
        mqtt = CocoaMQTT(clientID: config.clientId, host: config.host, port: UInt16(config.port))
        
        guard let mqtt = mqtt else {
            return .failure(.invalidConfiguration)
        }
        
        // 配置MQTT客户端
        mqtt.username = config.username
        mqtt.password = config.password
        mqtt.keepAlive = UInt16(config.keepAlive)
        mqtt.enableSSL = config.useSSL
        mqtt.delegate = self
        mqtt.autoReconnect = true
        mqtt.autoReconnectTimeInterval = 5
        
        // 更新连接状态
        connectionState.send(.connecting)
        
        // 执行连接
        let connected = mqtt.connect()
        
        if connected {
            // 等待连接结果（通过delegate回调）
            return await withCheckedContinuation { continuation in
                var hasResumed = false
                
                // 设置一个超时机制
                let timeoutTask = Task {
                    try? await Task.sleep(nanoseconds: 10_000_000_000) // 10秒超时
                    if !hasResumed && !self.isConnected {
                        hasResumed = true
                        continuation.resume(returning: .failure(.connectionFailed("连接超时")))
                    }
                }
                
                // 监听连接状态变化
                var cancellable: AnyCancellable?
                cancellable = self.connectionState
                    .dropFirst() // 跳过初始状态
                    .sink { state in
                        guard !hasResumed else { return }
                        
                        switch state {
                        case .connected:
                            hasResumed = true
                            timeoutTask.cancel()
                            cancellable?.cancel()
                            continuation.resume(returning: .success(()))
                        case .error(let message):
                            hasResumed = true
                            timeoutTask.cancel()
                            cancellable?.cancel()
                            continuation.resume(returning: .failure(.connectionFailed(message)))
                        default:
                            break
                        }
                    }
            }
        } else {
            connectionState.send(.error("连接启动失败"))
            return .failure(.connectionFailed("无法启动连接"))
        }
    }
    
    /// 断开连接
    func disconnect() {
        mqtt?.disconnect()
        mqtt = nil
        currentConfig = nil
        connectionState.send(.disconnected)
    }
    
    /// 发布消息
    func publish(topic: String, message: String, qos: Int) -> Result<Void, MQTTError> {
        guard let mqtt = mqtt, isConnected else {
            return .failure(.notConnected)
        }
        
        let qosLevel = CocoaMQTTQoS(rawValue: UInt8(qos)) ?? .qos1
        // 使用String初始化方法，CocoaMQTT会自动将String转换为[UInt8]
        let msg = CocoaMQTTMessage(topic: topic, string: message, qos: qosLevel, retained: false)
        
        let result = mqtt.publish(msg)
        
        if (result != 0) {
            return .success(())
        } else {
            return .failure(.publishFailed("发布消息失败"))
        }
    }
    
    /// 订阅主题
    func subscribe(topic: String, qos: Int) -> Result<Void, MQTTError> {
        guard let mqtt = mqtt, isConnected else {
            return .failure(.notConnected)
        }
        
        let qosLevel = CocoaMQTTQoS(rawValue: UInt8(qos)) ?? .qos1
        mqtt.subscribe(topic, qos: qosLevel)
        
        return .success(())
    }
    
    /// 取消订阅
    func unsubscribe(topic: String) -> Result<Void, MQTTError> {
        guard let mqtt = mqtt, isConnected else {
            return .failure(.notConnected)
        }
        
        mqtt.unsubscribe(topic)
        return .success(())
    }
}

// MARK: - CocoaMQTTDelegate

extension MQTTService: CocoaMQTTDelegate {
    /// MQTT连接成功回调
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        if ack == .accept {
            connectionState.send(.connected)
        } else {
            let errorMsg = "连接被拒绝: \(ack)"
            connectionState.send(.error(errorMsg))
        }
    }
    
    /// MQTT发布消息回调
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        // 发布成功，无需处理
    }
    
    /// MQTT发布消息确认回调
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        // 发布确认，无需处理
    }
    
    /// MQTT接收消息回调
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        // message.payload 是 [UInt8] 类型，使用 String 的初始化方法转换
        guard let payload = String(bytes: message.payload, encoding: .utf8) else {
            return
        }
        
        let mqttMessage = MQTTMessage(
            topic: message.topic,
            payload: payload,
            qos: Int(message.qos.rawValue)
        )
        
        // 发布接收到的消息
        receivedMessages.send(mqttMessage)
    }
    
    /// MQTT订阅成功回调
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopics success: NSDictionary, failed: [String]) {
        if !failed.isEmpty {
            print("订阅失败的主题: \(failed)")
        }
    }
    
    /// MQTT取消订阅成功回调
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopics topics: [String]) {
        // 取消订阅成功
    }
    
    /// MQTT连接状态变化回调
    func mqtt(_ mqtt: CocoaMQTT, didStateChangeTo state: CocoaMQTTConnState) {
        switch state {
        case .connected:
            connectionState.send(.connected)
        case .connecting:
            connectionState.send(.connecting)
        case .disconnected:
            connectionState.send(.disconnected)
        @unknown default:
            connectionState.send(.disconnected)
        }
    }
    
    /// MQTT断开连接回调
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        if let error = err {
            connectionState.send(.error(error.localizedDescription))
        } else {
            connectionState.send(.disconnected)
        }
    }
    
    /// MQTT Ping回调
    func mqttDidPing(_ mqtt: CocoaMQTT) {
        // Ping请求，用于保持连接
    }
    
    /// MQTT Ping响应回调
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        // Ping响应，用于保持连接
    }
}

