//
//  DeviceControlView.swift
//  GuopazIOT
//
//  Created on 2025/11/28.
//

import SwiftUI

/// 设备控制视图
struct DeviceControlView: View {
    /// ViewModel
    @StateObject private var viewModel: DeviceControlViewModel
    
    /// 初始化
    /// - Parameter device: 要控制的设备
    init(device: ESP32Device) {
        _viewModel = StateObject(wrappedValue: DeviceControlViewModel(device: device))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // 连接状态
            ConnectionStatusView(
                isConnected: viewModel.isConnected,
                message: viewModel.connectionMessage
            )
            
            // 控制按钮区域
            ControlButtonsView(viewModel: viewModel)
            
            // 消息列表
            MessageListView(messages: viewModel.recentMessages)
        }
        .padding()
        .navigationTitle(viewModel.device.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    Task {
                        if viewModel.isConnected {
                            viewModel.disconnect()
                        } else {
                            await viewModel.connect()
                        }
                    }
                }) {
                    Text(viewModel.isConnected ? "断开" : "连接")
                }
            }
        }
        .alert("错误", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("确定") {
                viewModel.errorMessage = nil
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }
}

/// 连接状态视图
struct ConnectionStatusView: View {
    let isConnected: Bool
    let message: String
    
    var body: some View {
        HStack {
            Circle()
                .fill(isConnected ? Color.green : Color.gray)
                .frame(width: 12, height: 12)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

/// 控制按钮视图
struct ControlButtonsView: View {
    @ObservedObject var viewModel: DeviceControlViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            Text("快速控制")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // LED控制按钮
            if viewModel.device.capabilities.contains(.ledControl) {
                HStack(spacing: 12) {
                    Button(action: {
                        let command = DeviceCommand(
                            type: .ledOn,
                            deviceId: viewModel.device.id
                        )
                        viewModel.sendCommand(command)
                    }) {
                        Label("LED开", systemImage: "lightbulb.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.yellow.opacity(0.2))
                            .cornerRadius(8)
                    }
                    .disabled(!viewModel.isConnected)
                    
                    Button(action: {
                        let command = DeviceCommand(
                            type: .ledOff,
                            deviceId: viewModel.device.id
                        )
                        viewModel.sendCommand(command)
                    }) {
                        Label("LED关", systemImage: "lightbulb")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                    .disabled(!viewModel.isConnected)
                }
            }
            
            // 传感器读取按钮
            if viewModel.device.capabilities.contains(.sensorReading) {
                HStack(spacing: 12) {
                    Button(action: {
                        let command = DeviceCommand(
                            type: .readTemperature,
                            deviceId: viewModel.device.id
                        )
                        viewModel.sendCommand(command)
                    }) {
                        Label("读取温度", systemImage: "thermometer")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(8)
                    }
                    .disabled(!viewModel.isConnected)
                    
                    Button(action: {
                        let command = DeviceCommand(
                            type: .readHumidity,
                            deviceId: viewModel.device.id
                        )
                        viewModel.sendCommand(command)
                    }) {
                        Label("读取湿度", systemImage: "humidity")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.cyan.opacity(0.2))
                            .cornerRadius(8)
                    }
                    .disabled(!viewModel.isConnected)
                }
            }
        }
    }
}

/// 消息列表视图
struct MessageListView: View {
    let messages: [MQTTMessage]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("最近消息")
                .font(.headline)
            
            if messages.isEmpty {
                Text("暂无消息")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(messages) { message in
                            MessageRowView(message: message)
                        }
                    }
                }
                .frame(maxHeight: 200)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

/// 消息行视图
struct MessageRowView: View {
    let message: MQTTMessage
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(message.topic)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(message.receivedAt, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Text(message.payload)
                .font(.subheadline)
        }
        .padding(8)
        .background(Color.white)
        .cornerRadius(6)
    }
}

#Preview {
    NavigationView {
        DeviceControlView(device: ESP32Device(
            name: "ESP32设备",
            connectionType: .wifi,
            status: .disconnected,
            mqttTopicPrefix: "esp32/device1",
            capabilities: [.ledControl, .sensorReading]
        ))
    }
}

