//
//  DeviceListView.swift
//  GuopazIOT
//
//  Created on 2025/11/28.
//

import SwiftUI

/// 设备列表视图
struct DeviceListView: View {
    /// ViewModel（使用@StateObject确保生命周期管理）
    @StateObject private var viewModel = DeviceListViewModel()
    
    /// 是否显示添加设备界面
    @State private var showAddDevice = false
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    ProgressView("加载中...")
                } else if viewModel.devices.isEmpty {
                    // 空状态
                    VStack(spacing: 20) {
                        Image(systemName: "antenna.radiowaves.left.and.right")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("暂无设备")
                            .font(.title2)
                            .foregroundColor(.gray)
                        Text("点击右上角添加设备")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                } else {
                    // 设备列表
                    List {
                        ForEach(viewModel.devices) { device in
                            DeviceRowView(device: device)
                                .onTapGesture {
                                    viewModel.selectedDevice = device
                                }
                        }
                        .onDelete(perform: deleteDevices)
                    }
                    .refreshable {
                        viewModel.refresh()
                    }
                }
            }
            .navigationTitle("设备列表")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showAddDevice = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddDevice) {
                AddDeviceView(viewModel: viewModel)
            }
            .sheet(item: $viewModel.selectedDevice) { device in
                DeviceDetailView(device: device, viewModel: viewModel)
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
    
    /// 删除设备
    private func deleteDevices(at offsets: IndexSet) {
        for index in offsets {
            viewModel.deleteDevice(viewModel.devices[index])
        }
    }
}

/// 设备行视图
struct DeviceRowView: View {
    let device: ESP32Device
    
    var body: some View {
        HStack {
            // 设备图标
            Image(systemName: deviceIcon(for: device.connectionType))
                .font(.title2)
                .foregroundColor(statusColor(for: device.status))
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                // 设备名称
                Text(device.name)
                    .font(.headline)
                
                // 连接状态和类型
                HStack {
                    Text(device.status.rawValue)
                        .font(.caption)
                        .foregroundColor(statusColor(for: device.status))
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text(device.connectionType.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // 状态指示器
            Circle()
                .fill(statusColor(for: device.status))
                .frame(width: 10, height: 10)
        }
        .padding(.vertical, 4)
    }
    
    /// 根据连接类型返回图标
    private func deviceIcon(for type: DeviceConnectionType) -> String {
        switch type {
        case .mqtt:
            return "wifi"
        case .bluetooth:
            return "antenna.radiowaves.left.and.right"
        case .both:
            return "network"
        }
    }
    
    /// 根据状态返回颜色
    private func statusColor(for status: DeviceStatus) -> Color {
        switch status {
        case .connected:
            return .green
        case .connecting:
            return .orange
        case .disconnected:
            return .gray
        case .error:
            return .red
        }
    }
}

/// 添加设备视图（示例）
struct AddDeviceView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: DeviceListViewModel
    
    @State private var deviceName = ""
    @State private var connectionType: DeviceConnectionType = .mqtt
    
    var body: some View {
        NavigationView {
            Form {
                Section("设备信息") {
                    TextField("设备名称", text: $deviceName)
                    
                    Picker("连接类型", selection: $connectionType) {
                        ForEach(DeviceConnectionType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                }
            }
            .navigationTitle("添加设备")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        let device = ESP32Device(
                            name: deviceName.isEmpty ? "新设备" : deviceName,
                            connectionType: connectionType
                        )
                        viewModel.addDevice(device)
                        dismiss()
                    }
                    .disabled(deviceName.isEmpty)
                }
            }
        }
    }
}

/// 设备详情视图（示例）
struct DeviceDetailView: View {
    @Environment(\.dismiss) var dismiss
    let device: ESP32Device
    @ObservedObject var viewModel: DeviceListViewModel
    
    var body: some View {
        NavigationView {
            List {
                Section("基本信息") {
                    HStack {
                        Text("名称")
                        Spacer()
                        Text(device.name)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("连接类型")
                        Spacer()
                        Text(device.connectionType.rawValue)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("状态")
                        Spacer()
                        Text(device.status.rawValue)
                            .foregroundColor(.secondary)
                    }
                }
                
                if !device.capabilities.isEmpty {
                    Section("设备能力") {
                        ForEach(device.capabilities, id: \.self) { capability in
                            Text(capability.rawValue)
                        }
                    }
                }
            }
            .navigationTitle("设备详情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    DeviceListView()
}

