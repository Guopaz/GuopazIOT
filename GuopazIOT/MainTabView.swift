//
//  MainTabView.swift
//  GuopazIOT
//
//  Created by liuzedong on 2025/11/28.
//

import SwiftUI

/// 主TabBar视图 - 负责Tab的管理和导航
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

#Preview {
    MainTabView()
}
