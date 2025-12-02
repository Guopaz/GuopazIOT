//
//  AppDependencyContainer.swift
//  GuopazIOT
//
//  Created on 2025/11/28.
//

import Foundation

/// 应用依赖注入容器
/// 使用单例模式管理所有服务的依赖关系
class AppDependencyContainer {
    static let shared = AppDependencyContainer()
    
    // MARK: - Services
    
    /// MQTT服务
    lazy var mqttService: MQTTServiceProtocol = {
        return MQTTService()
    }()
    
    /// 蓝牙服务
    lazy var bluetoothService: BluetoothServiceProtocol = {
        return BluetoothService()
    }()
    
    /// 设备存储服务
    lazy var storageService: DeviceStorageServiceProtocol = {
        return DeviceStorageService()
    }()
    
    // MARK: - Initialization
    
    private init() {
        // 私有初始化，确保单例
    }
}

