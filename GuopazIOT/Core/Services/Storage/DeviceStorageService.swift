//
//  DeviceStorageService.swift
//  GuopazIOT
//
//  Created on 2025/11/28.
//

import Foundation

/// 设备存储服务实现（使用UserDefaults）
class DeviceStorageService: DeviceStorageServiceProtocol {
    // MARK: - Constants
    
    private enum Keys {
        static let devices = "com.guopaz.devices"
        static let mqttConfig = "com.guopaz.mqtt.config"
    }
    
    // MARK: - Public Methods
    
    /// 保存设备列表
    func saveDevices(_ devices: [ESP32Device]) {
        if let encoded = try? JSONEncoder().encode(devices) {
            UserDefaults.standard.set(encoded, forKey: Keys.devices)
        }
    }
    
    /// 读取设备列表
    func loadDevices() -> [ESP32Device] {
        guard let data = UserDefaults.standard.data(forKey: Keys.devices),
              let devices = try? JSONDecoder().decode([ESP32Device].self, from: data) else {
            return []
        }
        return devices
    }
    
    /// 添加设备
    func addDevice(_ device: ESP32Device) {
        var devices = loadDevices()
        // 检查是否已存在
        if let index = devices.firstIndex(where: { $0.id == device.id }) {
            devices[index] = device
        } else {
            devices.append(device)
        }
        saveDevices(devices)
    }
    
    /// 更新设备
    func updateDevice(_ device: ESP32Device) {
        var devices = loadDevices()
        if let index = devices.firstIndex(where: { $0.id == device.id }) {
            devices[index] = device
            saveDevices(devices)
        }
    }
    
    /// 删除设备
    func deleteDevice(deviceId: String) {
        var devices = loadDevices()
        devices.removeAll { $0.id == deviceId }
        saveDevices(devices)
    }
    
    /// 保存MQTT配置
    func saveMQTTConfig(_ config: MQTTConfiguration) {
        if let encoded = try? JSONEncoder().encode(config) {
            UserDefaults.standard.set(encoded, forKey: Keys.mqttConfig)
        }
    }
    
    /// 读取MQTT配置
    func loadMQTTConfig() -> MQTTConfiguration {
        guard let data = UserDefaults.standard.data(forKey: Keys.mqttConfig),
              let config = try? JSONDecoder().decode(MQTTConfiguration.self, from: data) else {
            // 返回默认配置
            return MQTTConfiguration()
        }
        return config
    }
}

