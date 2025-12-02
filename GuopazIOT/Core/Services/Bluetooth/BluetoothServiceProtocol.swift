//
//  BluetoothServiceProtocol.swift
//  GuopazIOT
//
//  Created on 2025/11/28.
//

import Foundation
import Combine
import CoreBluetooth

/// 蓝牙服务协议
protocol BluetoothServiceProtocol {
    /// 蓝牙状态（使用Combine发布状态变化）
    var bluetoothState: CurrentValueSubject<BluetoothState, Never> { get }
    
    /// 扫描到的设备（使用Combine发布）
    var discoveredDevices: PassthroughSubject<BluetoothDevice, Never> { get }
    
    /// 连接状态（使用Combine发布）
    var connectionState: CurrentValueSubject<BluetoothConnectionState, Never> { get }
    
    /// 接收到的数据（使用Combine发布）
    var receivedData: PassthroughSubject<Data, Never> { get }
    
    /// 开始扫描设备
    /// - Parameter serviceUUIDs: 要扫描的服务UUID列表（可选，nil表示扫描所有设备）
    func startScanning(serviceUUIDs: [CBUUID]?)
    
    /// 停止扫描
    func stopScanning()
    
    /// 连接设备
    /// - Parameter device: 要连接的设备
    func connect(to device: BluetoothDevice)
    
    /// 断开连接
    func disconnect()
    
    /// 发送数据
    /// - Parameters:
    ///   - data: 要发送的数据
    ///   - characteristicUUID: 特征UUID
    /// - Returns: 发送结果
    func sendData(_ data: Data, to characteristicUUID: CBUUID) -> Result<Void, BluetoothError>
    
    /// 读取特征值
    /// - Parameter characteristicUUID: 特征UUID
    /// - Returns: 读取结果
    func readCharacteristic(_ characteristicUUID: CBUUID) -> Result<Void, BluetoothError>
    
    /// 当前连接的设备
    var connectedDevice: BluetoothDevice? { get }
    
    /// 是否正在扫描
    var isScanning: Bool { get }
    
    /// 是否已连接
    var isConnected: Bool { get }
}

/// 蓝牙设备模型
struct BluetoothDevice: Identifiable, Equatable {
    /// 设备唯一标识（使用UUID）
    let id: UUID
    /// 设备名称
    let name: String
    /// 设备标识符（CBPeripheral的identifier）
    let identifier: UUID
    /// 信号强度（RSSI）
    var rssi: Int
    /// 外设对象（弱引用，避免循环引用）
    weak var peripheral: CBPeripheral?
    
    init(
        id: UUID = UUID(),
        name: String,
        identifier: UUID,
        rssi: Int = 0,
        peripheral: CBPeripheral? = nil
    ) {
        self.id = id
        self.name = name
        self.identifier = identifier
        self.rssi = rssi
        self.peripheral = peripheral
    }
    
    static func == (lhs: BluetoothDevice, rhs: BluetoothDevice) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

/// 蓝牙状态
enum BluetoothState {
    case unknown
    case resetting
    case unsupported
    case unauthorized
    case poweredOff
    case poweredOn
}

/// 蓝牙连接状态
enum BluetoothConnectionState {
    case disconnected
    case connecting
    case connected
    case disconnecting
    case error(String)
}

/// 蓝牙错误类型
enum BluetoothError: LocalizedError {
    case bluetoothUnavailable
    case connectionFailed(String)
    case characteristicNotFound
    case writeFailed(String)
    case readFailed(String)
    case notConnected
    
    var errorDescription: String? {
        switch self {
        case .bluetoothUnavailable:
            return "蓝牙不可用"
        case .connectionFailed(let message):
            return "连接失败: \(message)"
        case .characteristicNotFound:
            return "特征未找到"
        case .writeFailed(let message):
            return "写入失败: \(message)"
        case .readFailed(let message):
            return "读取失败: \(message)"
        case .notConnected:
            return "未连接"
        }
    }
}

/// ESP32常用蓝牙服务UUID
struct ESP32BluetoothUUIDs {
    /// ESP32标准服务UUID
    static let serviceUUID = CBUUID(string: "0000FFE0-0000-1000-8000-00805F9B34FB")
    /// ESP32标准特征UUID（用于读写）
    static let characteristicUUID = CBUUID(string: "0000FFE1-0000-1000-8000-00805F9B34FB")
}

