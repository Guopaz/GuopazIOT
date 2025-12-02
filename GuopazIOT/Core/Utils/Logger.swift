//
//  Logger.swift
//  GuopazIOT
//
//  Created on 2025/11/28.
//

import Foundation
import os.log

/// 日志工具类
class Logger {
    private static let subsystem = "com.guopaz"
    
    /// MQTT日志
    static let mqtt = OSLog(subsystem: subsystem, category: "MQTT")
    
    /// 蓝牙日志
    static let bluetooth = OSLog(subsystem: subsystem, category: "Bluetooth")
    
    /// 设备日志
    static let device = OSLog(subsystem: subsystem, category: "Device")
    
    /// 通用日志
    static let general = OSLog(subsystem: subsystem, category: "General")
    
    /// 记录信息日志
    static func info(_ message: String, log: OSLog = general) {
        os_log("%{public}@", log: log, type: .info, message)
    }
    
    /// 记录错误日志
    static func error(_ message: String, log: OSLog = general) {
        os_log("%{public}@", log: log, type: .error, message)
    }
    
    /// 记录调试日志
    static func debug(_ message: String, log: OSLog = general) {
        os_log("%{public}@", log: log, type: .debug, message)
    }
}

