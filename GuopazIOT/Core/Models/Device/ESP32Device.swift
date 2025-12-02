//
//  ESP32Device.swift
//  GuopazIOT
//
//  Created on 2025/11/28.
//

import Foundation

/// ESP32设备数据模型
struct ESP32Device: Identifiable, Codable, Equatable {
    /// 设备唯一标识
    let id: String
    /// 设备名称
    var name: String
    /// 设备连接类型
    let connectionType: DeviceConnectionType
    /// 设备连接状态
    var status: DeviceStatus
    /// 设备MAC地址（蓝牙设备）
    var macAddress: String?
    /// MQTT Topic前缀（MQTT设备）
    var mqttTopicPrefix: String?
    /// 设备能力列表（支持的指令类型）
    var capabilities: [DeviceCapability]
    /// 最后连接时间
    var lastConnectedAt: Date?
    /// 设备描述信息
    var description: String?
    
    init(
        id: String = UUID().uuidString,
        name: String,
        connectionType: DeviceConnectionType,
        status: DeviceStatus = .disconnected,
        macAddress: String? = nil,
        mqttTopicPrefix: String? = nil,
        capabilities: [DeviceCapability] = [],
        lastConnectedAt: Date? = nil,
        description: String? = nil
    ) {
        self.id = id
        self.name = name
        self.connectionType = connectionType
        self.status = status
        self.macAddress = macAddress
        self.mqttTopicPrefix = mqttTopicPrefix
        self.capabilities = capabilities
        self.lastConnectedAt = lastConnectedAt
        self.description = description
    }
}

/// 设备连接类型
enum DeviceConnectionType: String, Codable, CaseIterable {
    case wifi = "Wifi"
    case bluetooth = "Bluetooth"
    case both = "Both"  // 同时支持两种方式
}

/// 设备连接状态
enum DeviceStatus: String, Codable {
    case connected = "已连接"
    case connecting = "连接中"
    case disconnected = "未连接"
    case error = "连接错误"
}

/// 设备能力（支持的指令类型）
enum DeviceCapability: String, Codable, CaseIterable {
    case ledControl = "LED控制"
    case sensorReading = "传感器读取"
    case motorControl = "电机控制"
    case displayControl = "显示屏控制"
    case gpioControl = "GPIO控制"
}

