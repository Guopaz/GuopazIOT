//
//  SettingsView.swift
//  GuopazIOT
//
//  Created on 2025/12/2.
//

import SwiftUI

/// 设置视图
struct SettingsView: View {
    var body: some View {
        NavigationView {
            List {
                Section("连接设置") {
                    SettingsRowView(
                        icon: "wifi",
                        title: "Wifi设置",
                        color: .blue
                    ) {
                        // Wifi设置页面
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
    SettingsView()
}

