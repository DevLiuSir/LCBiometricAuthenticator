//
//  LCBiometricAuthenticator.swift
//
//
//  Created by DevLiuSir on 2019/3/2.
//

import LocalAuthentication




/// 提供基于生物识别（如 Touch ID / Face ID）认证的工具类
class LCBiometricAuthenticator {
    
    /// 执行生物识别身份验证（默认只使用 biometrics）
    /// - Parameters:
    ///   - reason: 显示给用户的提示文本
    ///   - successHandler: 验证成功后的回调
    ///   - failureHandler: 验证失败后的回调，返回错误信息
    static func authenticate(reason: String, successHandler: @escaping () -> Void,
                             failureHandler: @escaping (Error?) -> Void) {
        let context = LAContext()
        var error: NSError?
        
        print("🔐 尝试进行生物识别认证...")
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            print("✅ 设备支持生物识别，开始验证（类型：\(biometryTypeString(from: context.biometryType))）...")
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                   localizedReason: reason) { success, evalError in
                DispatchQueue.main.async {
                    if success {
                        print("🎉 认证成功")
                        successHandler()
                    } else {
                        print("❌ 认证失败: \(evalError?.localizedDescription ?? "未知错误")")
                        failureHandler(evalError)
                    }
                }
            }
        } else {
            print("⚠️ 不支持生物认证: \(error?.localizedDescription ?? "未知错误")")
            failureHandler(error)
        }
    }
    
    
    /// 检查设备是否支持生物识别（Touch ID / Face ID / Optic ID）
    /// 在 macOS 上通常只会是 Touch ID
    static func isBiometricAvailable() -> Bool {
        let context = LAContext()
        var error: NSError?
        
        // 检查是否可以评估生物识别策略
        let canEvaluate = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        
        // 可选：更细粒度判断实际的生物识别类型
        let type = context.biometryType
#if os(macOS)
        // macOS 目前仅支持 Touch ID
        return canEvaluate && type == .touchID
#else
        // iOS / visionOS 支持更多生物识别方式
        return canEvaluate && (type == .touchID || type == .faceID || type == .opticID)
#endif
    }
    
    
    
    /// 返回当前支持的生物识别类型
    static func supportedBiometryType() -> LABiometryType {
        let context = LAContext()
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        return context.biometryType
    }
    
    /// 当前支持类型的名称（字符串形式）
    static func supportedBiometryTypeName() -> String {
        return biometryTypeString(from: supportedBiometryType())
    }
    
    // MARK: - 私有方法
    
    private static func biometryTypeString(from type: LABiometryType) -> String {
        switch type {
        case .touchID: return "Touch ID"
        case .faceID: return "Face ID"
        case .none: return "The device does not support biometry"
        case .opticID: return "Optic ID"    // Vision Pro 设备的虹膜识别
        @unknown default: return "Unknown"
        }
    }
    
    
    
}
