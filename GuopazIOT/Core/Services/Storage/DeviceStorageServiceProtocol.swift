//
//  DeviceStorageServiceProtocol.swift
//  GuopazIOT
//
//  Created on 2025/11/28.
//

import Foundation

/// 设备存储服务协议
protocol DeviceStorageServiceProtocol {
    /// 保存设备列表
    /// - Parameter devices: 设备列表
    func saveDevices(_ devices: [ESP32Device])
    
    /// 读取设备列表
    /// - Returns: 设备列表
    func loadDevices() -> [ESP32Device]
    
    /// 添加设备
    /// - Parameter device: 设备
    func addDevice(_ device: ESP32Device)
    
    /// 更新设备
    /// - Parameter device: 设备
    func updateDevice(_ device: ESP32Device)
    
    /// 删除设备
    /// - Parameter deviceId: 设备ID
    func deleteDevice(deviceId: String)
    
    /// 保存MQTT配置
    /// - Parameter config: MQTT配置
    func saveMQTTConfig(_ config: MQTTConfiguration)
    
    /// 读取MQTT配置
    /// - Returns: MQTT配置（如果不存在则返回默认配置）
    func loadMQTTConfig() -> MQTTConfiguration
}

