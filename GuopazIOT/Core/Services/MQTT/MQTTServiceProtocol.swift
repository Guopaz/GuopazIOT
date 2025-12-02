//
//  MQTTServiceProtocol.swift
//  GuopazIOT
//
//  Created on 2025/11/28.
//

import Foundation
import Combine

/// MQTT服务协议
protocol MQTTServiceProtocol {
    /// 连接状态（使用Combine发布状态变化）
    var connectionState: CurrentValueSubject<MQTTConnectionState, Never> { get }
    
    /// 接收到的消息（使用Combine发布消息）
    var receivedMessages: PassthroughSubject<MQTTMessage, Never> { get }
    
    /// 连接MQTT服务器
    /// - Parameter config: MQTT配置
    /// - Returns: 连接结果
    func connect(config: MQTTConfiguration) async -> Result<Void, MQTTError>
    
    /// 断开连接
    func disconnect()
    
    /// 发布消息
    /// - Parameters:
    ///   - topic: 主题
    ///   - message: 消息内容
    ///   - qos: 消息质量等级（0, 1, 2）
    /// - Returns: 发布结果
    func publish(topic: String, message: String, qos: Int) -> Result<Void, MQTTError>
    
    /// 订阅主题
    /// - Parameters:
    ///   - topic: 主题
    ///   - qos: 消息质量等级
    /// - Returns: 订阅结果
    func subscribe(topic: String, qos: Int) -> Result<Void, MQTTError>
    
    /// 取消订阅
    /// - Parameter topic: 主题
    /// - Returns: 取消订阅结果
    func unsubscribe(topic: String) -> Result<Void, MQTTError>
    
    /// 检查连接状态
    var isConnected: Bool { get }
}

/// MQTT连接状态
enum MQTTConnectionState {
    case disconnected
    case connecting
    case connected
    case error(String)
}

/// MQTT错误类型
enum MQTTError: LocalizedError {
    case connectionFailed(String)
    case publishFailed(String)
    case subscribeFailed(String)
    case invalidConfiguration
    case notConnected
    
    var errorDescription: String? {
        switch self {
        case .connectionFailed(let message):
            return "连接失败: \(message)"
        case .publishFailed(let message):
            return "发布失败: \(message)"
        case .subscribeFailed(let message):
            return "订阅失败: \(message)"
        case .invalidConfiguration:
            return "配置无效"
        case .notConnected:
            return "未连接"
        }
    }
}

