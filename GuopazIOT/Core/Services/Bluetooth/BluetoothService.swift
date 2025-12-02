//
//  BluetoothService.swift
//  GuopazIOT
//
//  Created on 2025/11/28.
//

import Foundation
import Combine
import CoreBluetooth

/// 蓝牙服务实现
class BluetoothService: NSObject, BluetoothServiceProtocol {
    // MARK: - Properties
    
    /// 蓝牙状态发布者
    let bluetoothState = CurrentValueSubject<BluetoothState, Never>(.unknown)
    
    /// 扫描到的设备发布者
    let discoveredDevices = PassthroughSubject<BluetoothDevice, Never>()
    
    /// 连接状态发布者
    let connectionState = CurrentValueSubject<BluetoothConnectionState, Never>(.disconnected)
    
    /// 接收到的数据发布者
    let receivedData = PassthroughSubject<Data, Never>()
    
    /// 中央管理器
    private var centralManager: CBCentralManager!
    
    /// 当前连接的设备
    private var currentPeripheral: CBPeripheral?
    
    /// 目标服务UUID列表
    private var targetServiceUUIDs: [CBUUID]?
    
    /// 已发现的设备字典（使用identifier作为key）
    private var discoveredDevicesDict: [UUID: BluetoothDevice] = [:]
    
    /// 是否正在扫描
    var isScanning: Bool {
        return centralManager?.isScanning ?? false
    }
    
    /// 是否已连接
    var isConnected: Bool {
        return currentPeripheral?.state == .connected
    }
    
    /// 当前连接的设备
    var connectedDevice: BluetoothDevice? {
        guard let peripheral = currentPeripheral,
              let device = discoveredDevicesDict[peripheral.identifier] else {
            return nil
        }
        return device
    }
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        // 初始化中央管理器
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // MARK: - Public Methods
    
    /// 开始扫描设备
    func startScanning(serviceUUIDs: [CBUUID]?) {
        // 检查蓝牙状态
        guard bluetoothState.value == .poweredOn else {
            print("蓝牙未开启，无法扫描")
            return
        }
        
        // 如果正在扫描，先停止
        if isScanning {
            stopScanning()
        }
        
        targetServiceUUIDs = serviceUUIDs
        
        // 开始扫描
        if let serviceUUIDs = serviceUUIDs {
            centralManager.scanForPeripherals(withServices: serviceUUIDs, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
        } else {
            // 扫描所有设备
            centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
        }
        
        print("开始扫描蓝牙设备...")
    }
    
    /// 停止扫描
    func stopScanning() {
        if isScanning {
            centralManager.stopScan()
            print("停止扫描蓝牙设备")
        }
    }
    
    /// 连接设备
    func connect(to device: BluetoothDevice) {
        guard let peripheral = device.peripheral else {
            connectionState.send(.error("设备外设对象无效"))
            return
        }
        
        // 如果已连接其他设备，先断开
        if let currentPeripheral = currentPeripheral, currentPeripheral.state == .connected {
            centralManager.cancelPeripheralConnection(currentPeripheral)
        }
        
        currentPeripheral = peripheral
        peripheral.delegate = self
        connectionState.send(.connecting)
        
        // 连接设备
        centralManager.connect(peripheral, options: nil)
    }
    
    /// 断开连接
    func disconnect() {
        if let peripheral = currentPeripheral {
            centralManager.cancelPeripheralConnection(peripheral)
        }
        currentPeripheral = nil
        connectionState.send(.disconnected)
    }
    
    /// 发送数据
    func sendData(_ data: Data, to characteristicUUID: CBUUID) -> Result<Void, BluetoothError> {
        guard let peripheral = currentPeripheral, peripheral.state == .connected else {
            return .failure(.notConnected)
        }
        
        // 查找特征
        guard let characteristic = findCharacteristic(uuid: characteristicUUID, in: peripheral) else {
            return .failure(.characteristicNotFound)
        }
        
        // 发送数据
        peripheral.writeValue(data, for: characteristic, type: .withResponse)
        return .success(())
    }
    
    /// 读取特征值
    func readCharacteristic(_ characteristicUUID: CBUUID) -> Result<Void, BluetoothError> {
        guard let peripheral = currentPeripheral, peripheral.state == .connected else {
            return .failure(.notConnected)
        }
        
        // 查找特征
        guard let characteristic = findCharacteristic(uuid: characteristicUUID, in: peripheral) else {
            return .failure(.characteristicNotFound)
        }
        
        // 读取特征值
        peripheral.readValue(for: characteristic)
        return .success(())
    }
    
    // MARK: - Private Methods
    
    /// 查找特征
    private func findCharacteristic(uuid: CBUUID, in peripheral: CBPeripheral) -> CBCharacteristic? {
        guard let services = peripheral.services else {
            return nil
        }
        
        for service in services {
            if let characteristics = service.characteristics {
                for characteristic in characteristics {
                    if characteristic.uuid == uuid {
                        return characteristic
                    }
                }
            }
        }
        
        return nil
    }
}

// MARK: - CBCentralManagerDelegate

extension BluetoothService: CBCentralManagerDelegate {
    /// 蓝牙状态更新
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            bluetoothState.send(.unknown)
        case .resetting:
            bluetoothState.send(.resetting)
        case .unsupported:
            bluetoothState.send(.unsupported)
        case .unauthorized:
            bluetoothState.send(.unauthorized)
        case .poweredOff:
            bluetoothState.send(.poweredOff)
            stopScanning()
        case .poweredOn:
            bluetoothState.send(.poweredOn)
        @unknown default:
            bluetoothState.send(.unknown)
        }
    }
    
    /// 发现设备
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // 创建设备对象
        let deviceName = peripheral.name ?? "未知设备"
        let device = BluetoothDevice(
            name: deviceName,
            identifier: peripheral.identifier,
            rssi: RSSI.intValue,
            peripheral: peripheral
        )
        
        // 更新已发现设备字典
        discoveredDevicesDict[peripheral.identifier] = device
        
        // 发布发现的设备
        discoveredDevices.send(device)
    }
    
    /// 连接成功
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("蓝牙设备连接成功: \(peripheral.name ?? "未知设备")")
        connectionState.send(.connected)
        
        // 发现服务
        peripheral.discoverServices(targetServiceUUIDs)
    }
    
    /// 连接失败
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        let errorMessage = error?.localizedDescription ?? "连接失败"
        print("蓝牙设备连接失败: \(errorMessage)")
        connectionState.send(.error(errorMessage))
        currentPeripheral = nil
    }
    
    /// 断开连接
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("蓝牙设备已断开: \(peripheral.name ?? "未知设备")")
        if let error = error {
            connectionState.send(.error(error.localizedDescription))
        } else {
            connectionState.send(.disconnected)
        }
        currentPeripheral = nil
    }
}

// MARK: - CBPeripheralDelegate

extension BluetoothService: CBPeripheralDelegate {
    /// 发现服务
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("发现服务失败: \(error.localizedDescription)")
            return
        }
        
        guard let services = peripheral.services else {
            return
        }
        
        // 发现每个服务的特征
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    /// 发现特征
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("发现特征失败: \(error.localizedDescription)")
            return
        }
        
        guard let characteristics = service.characteristics else {
            return
        }
        
        // 订阅通知（如果特征支持）
        for characteristic in characteristics {
            if characteristic.properties.contains(.notify) {
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    /// 特征值更新（通知）
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("读取特征值失败: \(error.localizedDescription)")
            return
        }
        
        guard let data = characteristic.value else {
            return
        }
        
        // 发布接收到的数据
        receivedData.send(data)
    }
    
    /// 写入特征值完成
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("写入特征值失败: \(error.localizedDescription)")
        } else {
            print("写入特征值成功")
        }
    }
    
    /// 特征通知状态更新
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("更新通知状态失败: \(error.localizedDescription)")
        } else {
            print("特征通知状态已更新: \(characteristic.isNotifying)")
        }
    }
}

