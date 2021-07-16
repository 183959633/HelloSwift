//
//  CCString.swift
//  HelloSwift
//
//  Created by a51095 on 2021/7/15.
//

import UIKit
import Foundation

extension String {
    static let characters = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    // MARK: - 生成指定位数随机字符串(此处默认16位)
    static func randomString(len : Int) -> String {
        var ranStr = ""
        for _ in 0..<len {
            let index = Int(arc4random_uniform(UInt32(characters.count)))
            ranStr.append(characters[characters.index(characters.startIndex, offsetBy: index)])
        }
        return ranStr
    }
    
    // MARK: - 格式化时间字符串
    static func getDateFormatter() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateStr = formatter.string(from: Date())
        return dateStr
    }
    
    // MARK: - 去除字符串中的空格
    var removeAllSapce: String? {
        let trimmedString = self.replacingOccurrences(of: " ", with: "")
        return trimmedString
    }
}

/// 文件夹相关处理
extension String {
    func createFoldPath() {
        if !FileManager.default.fileExists(atPath: self) {
            try? FileManager.default.createDirectory(atPath: self, withIntermediateDirectories: true, attributes: nil)
        }
    }
       
    func fileExist() -> Bool {
        return FileManager.default.fileExists(atPath: self)
    }
    
    func moveTo(_ path:String) {
        try? FileManager.default.moveItem(atPath: self, toPath: path)
    }
    
    func copyTo(_ path:String) {
        try? FileManager.default.removeItem(atPath: path)
        try? FileManager.default.copyItem(atPath: self, toPath: path)
    }
    
    func removePath() {
        try? FileManager.default.removeItem(atPath: self)
    }
}
