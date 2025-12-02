//
//  ContentView.swift
//  GuopazIOT
//
//  Created by liuzedong on 2025/11/28.
//

import SwiftUI

/// 主TabBar视图
struct MainTabView: View {
    /// 当前选中的Tab索引
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 设备列表Tab
            DeviceListView()
                .tabItem {
                    Label("设备", systemImage: "list.bullet")
                }
                .tag(0)
            
            // 概览Tab
            OverviewView()
                .tabItem {
                    Label("概览", systemImage: "square.grid.2x2")
                }
                .tag(1)
            
            // 设置Tab
            SettingsView()
                .tabItem {
                    Label("设置", systemImage: "gearshape")
                }
                .tag(2)
        }
    }
}

/// 概览视图
struct OverviewView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 统计卡片
                    StatisticsCardView()
                    
                    // 快速操作
                    QuickActionsView()
                    
                    // 最近活动
                    RecentActivityView()
                }
                .padding()
            }
            .navigationTitle("概览")
        }
    }
}

/// 统计卡片视图
struct StatisticsCardView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("设备统计")
                .font(.headline)
            
            HStack(spacing: 20) {
                StatItemView(
                    title: "总设备",
                    value: "0",
                    icon: "antenna.radiowaves.left.and.right",
                    color: .blue
                )
                
                StatItemView(
                    title: "在线",
                    value: "0",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                StatItemView(
                    title: "离线",
                    value: "0",
                    icon: "xmark.circle.fill",
                    color: .gray
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

/// 统计项视图
struct StatItemView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

/// 快速操作视图
struct QuickActionsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("快速操作")
                .font(.headline)
            
            HStack(spacing: 12) {
                QuickActionButton(
                    title: "添加设备",
                    icon: "plus.circle.fill",
                    color: .blue
                ) {
                    // 添加设备操作
                }
                
                QuickActionButton(
                    title: "扫描设备",
                    icon: "magnifyingglass",
                    color: .green
                ) {
                    // 扫描设备操作
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

/// 快速操作按钮
struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white)
            .cornerRadius(8)
        }
    }
}

/// 最近活动视图
struct RecentActivityView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("最近活动")
                .font(.headline)
            
            VStack(spacing: 8) {
                ActivityItemView(
                    icon: "info.circle",
                    message: "暂无活动记录",
                    time: Date()
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

/// 活动项视图
struct ActivityItemView: View {
    let icon: String
    let message: String
    let time: Date
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(message)
                    .font(.subheadline)
                
                Text(time, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

/// 设置视图
struct SettingsView: View {
    var body: some View {
        NavigationView {
            List {
                Section("连接设置") {
                    SettingsRowView(
                        icon: "wifi",
                        title: "MQTT设置",
                        color: .blue
                    ) {
                        // MQTT设置页面
                    }
                    
                    SettingsRowView(
                        icon: "antenna.radiowaves.left.and.right",
                        title: "蓝牙设置",
                        color: .green
                    ) {
                        // 蓝牙设置页面
                    }
                }
                
                Section("应用设置") {
                    SettingsRowView(
                        icon: "bell",
                        title: "通知设置",
                        color: .orange
                    ) {
                        // 通知设置
                    }
                    
                    SettingsRowView(
                        icon: "lock",
                        title: "隐私与安全",
                        color: .purple
                    ) {
                        // 隐私设置
                    }
                }
                
                Section("关于") {
                    SettingsRowView(
                        icon: "info.circle",
                        title: "关于应用",
                        color: .gray
                    ) {
                        // 关于页面
                    }
                }
            }
            .navigationTitle("设置")
        }
    }
}

/// 设置行视图
struct SettingsRowView: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 24)
                
                Text(title)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    MainTabView()
}
