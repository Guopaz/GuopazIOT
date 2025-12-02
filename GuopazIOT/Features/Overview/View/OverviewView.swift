//
//  OverviewView.swift
//  GuopazIOT
//
//  Created on 2025/12/2.
//

import SwiftUI

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

#Preview {
    OverviewView()
}

