//
//  DeviceCommand.swift
//  GuopazIOT
//
//  Created on 2025/11/28.
//

import Foundation

/// 设备命令模型
struct DeviceCommand: Identifiable, Codable {
    /// 命令唯一标识
    let id: String
    /// 命令类型
    let type: CommandType
    /// 命令参数（JSON格式）
    var parameters: [String: Any]
    /// 目标设备ID
    let deviceId: String
    /// 创建时间
    let createdAt: Date
    /// 是否已发送
    var isSent: Bool
    /// 是否已收到响应
    var hasResponse: Bool
    /// 响应数据
    var response: String?
    
    init(
        id: String = UUID().uuidString,
        type: CommandType,
        parameters: [String: Any] = [:],
        deviceId: String,
        createdAt: Date = Date(),
        isSent: Bool = false,
        hasResponse: Bool = false,
        response: String? = nil
    ) {
        self.id = id
        self.type = type
        self.parameters = parameters
        self.deviceId = deviceId
        self.createdAt = createdAt
        self.isSent = isSent
        self.hasResponse = hasResponse
        self.response = response
    }
    
    /// 将命令转换为JSON字符串（用于发送）
    func toJSONString() -> String? {
        let commandDict: [String: Any] = [
            "id": id,
            "type": type.rawValue,
            "parameters": parameters,
            "timestamp": Int(createdAt.timeIntervalSince1970)
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: commandDict, options: []),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return nil
        }
        return jsonString
    }
    
    // MARK: - Codable Support for Dictionary
    
    enum CodingKeys: String, CodingKey {
        case id, type, parameters, deviceId, createdAt, isSent, hasResponse, response
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        type = try container.decode(CommandType.self, forKey: .type)
        deviceId = try container.decode(String.self, forKey: .deviceId)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        isSent = try container.decode(Bool.self, forKey: .isSent)
        hasResponse = try container.decode(Bool.self, forKey: .hasResponse)
        response = try container.decodeIfPresent(String.self, forKey: .response)
        
        // 处理parameters字典
        if let paramsData = try? container.decode(Data.self, forKey: .parameters),
           let paramsDict = try? JSONSerialization.jsonObject(with: paramsData) as? [String: Any] {
            parameters = paramsDict
        } else {
            parameters = [:]
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encode(deviceId, forKey: .deviceId)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(isSent, forKey: .isSent)
        try container.encode(hasResponse, forKey: .hasResponse)
        try container.encodeIfPresent(response, forKey: .response)
        
        // 编码parameters字典
        let paramsData = try JSONSerialization.data(withJSONObject: parameters, options: [])
        try container.encode(paramsData, forKey: .parameters)
    }
}

/// 命令类型
enum CommandType: String, Codable, CaseIterable {
    // LED控制
    case ledOn = "led_on"
    case ledOff = "led_off"
    case ledBlink = "led_blink"
    case ledSetBrightness = "led_set_brightness"
    
    // 传感器读取
    case readTemperature = "read_temperature"
    case readHumidity = "read_humidity"
    case readDistance = "read_distance"
    
    // 电机控制
    case motorStart = "motor_start"
    case motorStop = "motor_stop"
    case motorSetSpeed = "motor_set_speed"
    
    // GPIO控制
    case gpioSetHigh = "gpio_set_high"
    case gpioSetLow = "gpio_set_low"
    case gpioRead = "gpio_read"
    
    // 自定义命令
    case custom = "custom"
    
    /// 命令显示名称
    var displayName: String {
        switch self {
        case .ledOn: return "LED开启"
        case .ledOff: return "LED关闭"
        case .ledBlink: return "LED闪烁"
        case .ledSetBrightness: return "设置LED亮度"
        case .readTemperature: return "读取温度"
        case .readHumidity: return "读取湿度"
        case .readDistance: return "读取距离"
        case .motorStart: return "启动电机"
        case .motorStop: return "停止电机"
        case .motorSetSpeed: return "设置电机速度"
        case .gpioSetHigh: return "GPIO高电平"
        case .gpioSetLow: return "GPIO低电平"
        case .gpioRead: return "读取GPIO"
        case .custom: return "自定义命令"
        }
    }
}

