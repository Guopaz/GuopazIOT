//
//  DeviceListViewModel.swift
//  GuopazIOT
//
//  Created on 2025/11/28.
//

import Foundation
import Combine
import SwiftUI

/// 设备列表ViewModel
/// 负责管理设备列表的业务逻辑
class DeviceListViewModel: ObservableObject {
    // MARK: - Published Properties
    
    /// 设备列表
    @Published var devices: [ESP32Device] = []
    
    /// 是否正在加载
    @Published var isLoading: Bool = false
    
    /// 错误消息
    @Published var errorMessage: String?
    
    /// 选中的设备
    @Published var selectedDevice: ESP32Device?
    
    // MARK: - Dependencies
    
    /// 存储服务（通过依赖注入）
    private let storageService: DeviceStorageServiceProtocol
    
    /// 取消订阅集合
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    /// 初始化ViewModel
    /// - Parameter storageService: 存储服务（默认使用依赖注入容器）
    init(storageService: DeviceStorageServiceProtocol = AppDependencyContainer.shared.storageService) {
        self.storageService = storageService
        loadDevices()
    }
    
    // MARK: - Public Methods
    
    /// 加载设备列表
    func loadDevices() {
        isLoading = true
        errorMessage = nil
        
        // 从存储服务加载设备
        devices = storageService.loadDevices()
        
        isLoading = false
    }
    
    /// 添加新设备
    /// - Parameter device: 设备
    func addDevice(_ device: ESP32Device) {
        storageService.addDevice(device)
        loadDevices()
    }
    
    /// 删除设备
    /// - Parameter device: 设备
    func deleteDevice(_ device: ESP32Device) {
        storageService.deleteDevice(deviceId: device.id)
        loadDevices()
    }
    
    /// 更新设备
    /// - Parameter device: 设备
    func updateDevice(_ device: ESP32Device) {
        storageService.updateDevice(device)
        loadDevices()
    }
    
    /// 刷新设备列表
    func refresh() {
        loadDevices()
    }
}

