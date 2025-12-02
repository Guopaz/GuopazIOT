# Guopaz App 架构设计文档

## 项目概述
Guopaz是一个用于控制ESP32设备的iOS应用，支持通过MQTT和蓝牙两种方式与硬件设备通信。

## 架构原则
- **严格MVVM架构**：View只负责UI展示，ViewModel处理业务逻辑，Model负责数据
- **依赖注入**：使用依赖注入管理服务依赖，便于测试和扩展
- **单一职责**：每个模块只负责一个功能
- **协议导向**：使用Protocol定义接口，便于Mock和测试

## 目录结构

```
Guopaz/
├── App/                          # 应用入口
│   ├── GuopazApp.swift
│   └── AppDependencyContainer.swift  # 依赖注入容器
│
├── Core/                         # 核心基础设施
│   ├── Services/                 # 服务层
│   │   ├── MQTT/
│   │   │   ├── MQTTService.swift
│   │   │   ├── MQTTServiceProtocol.swift
│   │   │   └── MQTTConfiguration.swift
│   │   ├── Bluetooth/
│   │   │   ├── BluetoothService.swift
│   │   │   ├── BluetoothServiceProtocol.swift
│   │   │   └── BluetoothDevice.swift
│   │   └── Storage/
│   │       ├── DeviceStorageService.swift
│   │       └── DeviceStorageServiceProtocol.swift
│   │
│   ├── Models/                   # 数据模型
│   │   ├── Device/
│   │   │   ├── ESP32Device.swift
│   │   │   ├── DeviceConnectionType.swift
│   │   │   └── DeviceStatus.swift
│   │   ├── Command/
│   │   │   ├── DeviceCommand.swift
│   │   │   └── CommandType.swift
│   │   └── Message/
│   │       └── MQTTMessage.swift
│   │
│   └── Utils/                    # 工具类
│       ├── Logger.swift
│       ├── Constants.swift
│       └── Extensions/
│
├── Features/                     # 功能模块（按功能划分）
│   ├── DeviceList/              # 设备列表
│   │   ├── View/
│   │   │   └── DeviceListView.swift
│   │   ├── ViewModel/
│   │   │   └── DeviceListViewModel.swift
│   │   └── Model/
│   │       └── DeviceListItem.swift
│   │
│   ├── DeviceConnection/         # 设备连接
│   │   ├── View/
│   │   │   ├── MQTTConnectionView.swift
│   │   │   └── BluetoothConnectionView.swift
│   │   ├── ViewModel/
│   │   │   ├── MQTTConnectionViewModel.swift
│   │   │   └── BluetoothConnectionViewModel.swift
│   │   └── Model/
│   │       └── ConnectionConfig.swift
│   │
│   ├── DeviceControl/           # 设备控制
│   │   ├── View/
│   │   │   └── DeviceControlView.swift
│   │   ├── ViewModel/
│   │   │   └── DeviceControlViewModel.swift
│   │   └── Model/
│   │       └── ControlCommand.swift
│   │
│   └── Settings/                # 设置
│       ├── View/
│       │   └── SettingsView.swift
│       ├── ViewModel/
│       │   └── SettingsViewModel.swift
│       └── Model/
│           └── AppSettings.swift
│
└── Resources/                    # 资源文件
    ├── Assets.xcassets
    └── Localizable.strings
```

## 核心模块说明

### 1. Service层（服务层）

#### MQTTService
- **职责**：管理MQTT连接、发布、订阅
- **功能**：
  - 连接/断开MQTT服务器
  - 发布消息到指定Topic
  - 订阅Topic接收消息
  - 连接状态管理
  - 消息队列管理（离线消息）

#### BluetoothService
- **职责**：管理蓝牙连接和通信
- **功能**：
  - 扫描蓝牙设备
  - 连接/断开ESP32设备
  - 发送/接收数据
  - 连接状态管理
  - 特征值读写

#### DeviceStorageService
- **职责**：设备信息持久化存储
- **功能**：
  - 保存/读取设备列表
  - 保存设备配置信息
  - 使用UserDefaults或CoreData

### 2. Model层（数据模型）

#### ESP32Device
- 设备基本信息（名称、ID、类型）
- 连接方式（MQTT/Bluetooth）
- 连接状态
- 设备能力（支持的指令）

#### DeviceCommand
- 命令类型（LED控制、传感器读取等）
- 命令参数
- 命令ID（用于追踪响应）

### 3. ViewModel层（视图模型）

#### 职责
- 处理业务逻辑
- 管理View状态
- 调用Service层方法
- 数据转换（Model -> View需要的格式）

#### 特点
- 使用`@Published`属性包装器发布状态
- 不直接依赖UIKit
- 可测试（依赖注入）

### 4. View层（视图）

#### 职责
- UI展示
- 用户交互
- 绑定ViewModel状态

#### 特点
- 使用SwiftUI声明式语法
- 通过`@ObservedObject`或`@StateObject`绑定ViewModel
- 不包含业务逻辑

## 数据流

```
User Action
    ↓
View (SwiftUI)
    ↓
ViewModel (处理逻辑)
    ↓
Service (MQTT/Bluetooth)
    ↓
ESP32 Device
```

## 依赖注入设计

使用简单的依赖注入容器管理服务：

```swift
class AppDependencyContainer {
    static let shared = AppDependencyContainer()
    
    lazy var mqttService: MQTTServiceProtocol = MQTTService()
    lazy var bluetoothService: BluetoothServiceProtocol = BluetoothService()
    lazy var storageService: DeviceStorageServiceProtocol = DeviceStorageService()
}
```

## 状态管理

- **ViewModel状态**：使用`@Published`属性
- **全局状态**：使用`@EnvironmentObject`或单例
- **持久化状态**：使用`DeviceStorageService`

## 错误处理

- Service层返回Result类型
- ViewModel处理错误并转换为用户友好的消息
- View显示错误提示

## 测试策略

- **ViewModel测试**：Mock Service层，测试业务逻辑
- **Service测试**：测试MQTT/蓝牙连接逻辑
- **集成测试**：测试完整流程

## 扩展性考虑

1. **新增通信方式**：实现新的ServiceProtocol
2. **新增设备类型**：扩展Device模型
3. **新增功能模块**：在Features下创建新模块

## 技术栈

- **UI框架**：SwiftUI
- **MQTT**：CocoaMQTT
- **蓝牙**：CoreBluetooth
- **架构**：MVVM
- **依赖管理**：CocoaPods

