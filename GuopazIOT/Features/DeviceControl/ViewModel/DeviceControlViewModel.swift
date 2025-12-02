//
//  DeviceControlViewModel.swift
//  GuopazIOT
//
//  Created on 2025/11/28.
//

import Foundation
import Combine
import SwiftUI

/// 设备控制ViewModel
/// 负责处理设备控制相关的业务逻辑
class DeviceControlViewModel: ObservableObject {
    // MARK: - Published Properties
    
    /// 当前控制的设备
    @Published var device: ESP32Device
    
    /// 是否已连接
    @Published var isConnected: Bool = false
    
    /// 连接状态消息
    @Published var connectionMessage: String = ""
    
    /// 最近接收到的消息
    @Published var recentMessages: [MQTTMessage] = []
    
    /// 错误消息
    @Published var errorMessage: String?
    
    // MARK: - Dependencies
    
    /// MQTT服务
    private let mqttService: MQTTServiceProtocol
    
    /// 蓝牙服务
    private let bluetoothService: BluetoothServiceProtocol
    
    /// 取消订阅集合
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    /// 初始化ViewModel
    /// - Parameters:
    ///   - device: 要控制的设备
    ///   - mqttService: MQTT服务（默认使用依赖注入容器）
    ///   - bluetoothService: 蓝牙服务（默认使用依赖注入容器）
    init(
        device: ESP32Device,
        mqttService: MQTTServiceProtocol = AppDependencyContainer.shared.mqttService,
        bluetoothService: BluetoothServiceProtocol = AppDependencyContainer.shared.bluetoothService
    ) {
        self.device = device
        self.mqttService = mqttService
        self.bluetoothService = bluetoothService
        
        setupSubscriptions()
    }
    
    // MARK: - Private Methods
    
    /// 设置订阅（监听服务状态变化）
    private func setupSubscriptions() {
        // 订阅MQTT连接状态
        mqttService.connectionState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleMQTTStateChange(state)
            }
            .store(in: &cancellables)
        
        // 订阅MQTT消息
        mqttService.receivedMessages
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                self?.handleMQTTMessage(message)
            }
            .store(in: &cancellables)
        
        // 订阅蓝牙连接状态
        bluetoothService.connectionState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleBluetoothStateChange(state)
            }
            .store(in: &cancellables)
        
        // 订阅蓝牙接收到的数据
        bluetoothService.receivedData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                self?.handleBluetoothData(data)
            }
            .store(in: &cancellables)
    }
    
    /// 处理MQTT状态变化
    private func handleMQTTStateChange(_ state: MQTTConnectionState) {
        switch state {
        case .connected:
            isConnected = true
            connectionMessage = "MQTT已连接"
        case .connecting:
            isConnected = false
            connectionMessage = "MQTT连接中..."
        case .disconnected:
            isConnected = false
            connectionMessage = "MQTT未连接"
        case .error(let message):
            isConnected = false
            connectionMessage = "MQTT连接错误"
            errorMessage = message
        }
    }
    
    /// 处理蓝牙状态变化
    private func handleBluetoothStateChange(_ state: BluetoothConnectionState) {
        switch state {
        case .connected:
            isConnected = true
            connectionMessage = "蓝牙已连接"
        case .connecting:
            isConnected = false
            connectionMessage = "蓝牙连接中..."
        case .disconnected:
            isConnected = false
            connectionMessage = "蓝牙未连接"
        case .disconnecting:
            isConnected = false
            connectionMessage = "蓝牙断开中..."
        case .error(let message):
            isConnected = false
            connectionMessage = "蓝牙连接错误"
            errorMessage = message
        }
    }
    
    /// 处理MQTT消息
    private func handleMQTTMessage(_ message: MQTTMessage) {
        recentMessages.insert(message, at: 0)
        // 限制消息数量
        if recentMessages.count > 50 {
            recentMessages = Array(recentMessages.prefix(50))
        }
    }
    
    /// 处理蓝牙数据
    private func handleBluetoothData(_ data: Data) {
        if let text = String(data: data, encoding: .utf8) {
            let message = MQTTMessage(
                topic: "bluetooth",
                payload: text
            )
            recentMessages.insert(message, at: 0)
            // 限制消息数量
            if recentMessages.count > 50 {
                recentMessages = Array(recentMessages.prefix(50))
            }
        }
    }
    
    // MARK: - Public Methods
    
    /// 连接设备
    func connect() async {
        switch device.connectionType {
        case .mqtt:
            await connectMQTT()
        case .bluetooth:
            connectBluetooth()
        case .both:
            // 优先使用MQTT
            await connectMQTT()
        }
    }
    
    /// 断开连接
    func disconnect() {
        switch device.connectionType {
        case .mqtt:
            mqttService.disconnect()
        case .bluetooth:
            bluetoothService.disconnect()
        case .both:
            mqttService.disconnect()
            bluetoothService.disconnect()
        }
    }
    
    /// 发送命令
    /// - Parameter command: 设备命令
    func sendCommand(_ command: DeviceCommand) {
        guard let commandJSON = command.toJSONString() else {
            errorMessage = "命令序列化失败"
            return
        }
        
        switch device.connectionType {
        case .mqtt:
            sendCommandViaMQTT(commandJSON, command: command)
        case .bluetooth:
            sendCommandViaBluetooth(commandJSON, command: command)
        case .both:
            // 两种方式都发送
            sendCommandViaMQTT(commandJSON, command: command)
            sendCommandViaBluetooth(commandJSON, command: command)
        }
    }
    
    // MARK: - Private Methods
    
    /// 连接MQTT
    private func connectMQTT() async {
        guard let topicPrefix = device.mqttTopicPrefix else {
            errorMessage = "设备未配置MQTT Topic"
            return
        }
        
        // 加载MQTT配置
        let storageService = AppDependencyContainer.shared.storageService
        let config = storageService.loadMQTTConfig()
        
        // 连接MQTT
        let result = await mqttService.connect(config: config)
        
        switch result {
        case .success:
            // 订阅设备主题
            let subscribeTopic = "\(topicPrefix)/response"
            _ = mqttService.subscribe(topic: subscribeTopic, qos: 1)
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
    
    /// 连接蓝牙
    private func connectBluetooth() {
        // 如果设备有MAC地址，需要先扫描找到对应的蓝牙设备
        // 这里简化处理，实际应该先扫描设备
        errorMessage = "蓝牙连接功能需要先扫描设备"
    }
    
    /// 通过MQTT发送命令
    private func sendCommandViaMQTT(_ commandJSON: String, command: DeviceCommand) {
        guard let topicPrefix = device.mqttTopicPrefix else {
            errorMessage = "设备未配置MQTT Topic"
            return
        }
        
        let publishTopic = "\(topicPrefix)/command"
        let result = mqttService.publish(topic: publishTopic, message: commandJSON, qos: 1)
        
        switch result {
        case .success:
            // 命令发送成功
            break
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
    
    /// 通过蓝牙发送命令
    private func sendCommandViaBluetooth(_ commandJSON: String, command: DeviceCommand) {
        guard let data = commandJSON.data(using: .utf8) else {
            errorMessage = "命令编码失败"
            return
        }
        
        let characteristicUUID = ESP32BluetoothUUIDs.characteristicUUID
        let result = bluetoothService.sendData(data, to: characteristicUUID)
        
        switch result {
        case .success:
            // 命令发送成功
            break
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
}

