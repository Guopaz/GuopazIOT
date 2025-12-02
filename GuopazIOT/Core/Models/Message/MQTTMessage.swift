//
//  MQTTMessage.swift
//  GuopazIOT
//
//  Created on 2025/11/28.
//

import Foundation

/// MQTT消息模型
struct MQTTMessage: Identifiable {
    /// 消息唯一标识
    let id: String
    /// 消息主题
    let topic: String
    /// 消息内容
    let payload: String
    /// 消息质量等级
    let qos: Int
    /// 接收时间
    let receivedAt: Date
    /// 是否已读
    var isRead: Bool
    
    init(
        id: String = UUID().uuidString,
        topic: String,
        payload: String,
        qos: Int = 1,
        receivedAt: Date = Date(),
        isRead: Bool = false
    ) {
        self.id = id
        self.topic = topic
        self.payload = payload
        self.qos = qos
        self.receivedAt = receivedAt
        self.isRead = isRead
    }
}

/// MQTT连接配置
struct MQTTConfiguration: Codable {
    /// 服务器地址
    var host: String
    /// 端口号
    var port: Int
    /// 客户端ID
    var clientId: String
    /// 用户名（可选）
    var username: String?
    /// 密码（可选）
    var password: String?
    /// 是否使用SSL
    var useSSL: Bool
    /// 保持连接时间（秒）
    var keepAlive: Int
    
    init(
        host: String = "localhost",
        port: Int = 1883,
        clientId: String = "Guopaz_\(UUID().uuidString)",
        username: String? = nil,
        password: String? = nil,
        useSSL: Bool = false,
        keepAlive: Int = 60
    ) {
        self.host = host
        self.port = port
        self.clientId = clientId
        self.username = username
        self.password = password
        self.useSSL = useSSL
        self.keepAlive = keepAlive
    }
}

