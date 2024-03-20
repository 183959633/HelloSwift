//
//  Log.swift
//  HelloSwift
//
//  Created by neusoft on 2024/3/19.
//

import Foundation

@available(iOS 13.0, *)
struct Log {
    private init() { }
    private static var logManager = LogManager()

    static func start() {
        if (logManager.isRunning) { return }
        logManager.isRunning = true
        logManager.start()
    }

    static func stop() {
        if (!logManager.isRunning) { return }
        logManager.isRunning = false
        logManager.stop()
    }

    /// 应用程序日志
    static func applicationLog(message: String,
                               date: Date? = Date()) {
        let props = LogProperties(type: .application, message: message, atDate: date)
        logToCache(props: props)
    }

    /// 异常日志
    static func exceptionLog(message: String, date: Date? = Date()) {
        let props = LogProperties(type: .exception, message: message, atDate: date)
        logToCache(props: props)
    }

    /// 开发日志
    static func debugLog(message: String, date: Date? = Date()) {
        #if DEBUG
        let props = LogProperties(type: .debug, message: message, atDate: date)
        logToCache(props: props)
        #endif
    }

    private static func logToCache(props: LogProperties) {
        logManager.logToCache(props: props)
    }
}

fileprivate enum LogType: String {
    case debug
    case exception
    case application
}

fileprivate protocol LogManagerProtocol: AnyObject {
    func start()
    func stop()
    func updateLogFilePath()
    var isRunning: Bool { get set }
    func logToCache(props: LogProperties)
}

fileprivate protocol CommonFileOutputStreamProtocol: AnyObject {
    func writeToLogFile(text: String)
    func close()
}

fileprivate struct LogProperties {
    /// 日志类型
    let type: LogType
    /// 日志信息
    var message: String
    /// 创建时间
    var atDate: Date?

    private var dateText: String {
        guard let date = atDate else { return "" }
        return date.format("yyyy/MM/dd/ hh:mm:ss.SSS a")
    }

    func makeLine() -> String {
        return "[\(type.rawValue.capitalized)], \(dateText) ==> \(message)\n"
    }
}

@available(iOS 13.0, *)
fileprivate class LogManager: LogManagerProtocol {
    var isRunning = false
    private var logFile: LogFile? = nil
    private var flushTask: Task<Void, Error>? = nil
    private let maxFileSize: Int64 = 2 * 1024 * 1024 * 1024
    private var logPropsCache: [LogProperties] = [LogProperties]()

    init() {
        updateLogFilePath()
    }

    func start() {
        flushTask = Task {
            if Task.isCancelled { return }
            while (true) {
                flushLog()
                try? await Task.sleep(nanoseconds: UInt64(0.1) * NSEC_PER_MSEC)
            }
        }
    }

    func stop() {
        flushTask?.cancel()
        logFile?.close()
    }

    func logToCache(props: LogProperties) {
        logPropsCache.append(props)
    }

    fileprivate func updateLogFilePath() {
        let dateString = Date().format("yyyyMMdd_HHmmss")
        let debugLogFileName = "tempLog_\(dateString).txt"
        let fullFileName = kAppLogURL.appendingPathComponent(debugLogFileName)
        if !kAppLogURL.path.isFolderExist {
            kAppLogURL.path.createFolderPath()
        } else {
            let filePaths = try! FileManager.default.contentsOfDirectory(at: kAppLogURL, includingPropertiesForKeys: nil)
            var incrementSize: Int64 = 0
            for path in filePaths {
                incrementSize = incrementSize + path.path.length
            }
            if incrementSize > maxFileSize {
                kAppLogURL.path.removePath()
                kAppLogURL.path.createFolderPath()
            }
        }
        logFile = LogFile(filePath: fullFileName.path, append: fullFileName.path.isFileExist)
    }

    private func flushLog() {
        if (logPropsCache.isEmpty) { return }
        let cache = Array(logPropsCache)
        logPropsCache.removeAll()
        let lines = makeLogLines(logProps: cache)
        logFile?.writeToLogFile(text: lines)
    }

    private func makeLogLines(logProps: [LogProperties]) -> String {
        var lines = ""
        logProps.forEach {
            let line = $0.makeLine()
            lines += line
        }
        return lines
    }
}

fileprivate class LogFile: CommonFileOutputStreamProtocol {
    private let outputStream: OutputStream
    init(filePath: String, append: Bool = false) {
        let fileURL = URL(fileURLWithPath: filePath)
        outputStream = OutputStream(url: fileURL, append: append)!
    }

    func writeToLogFile(text: String) {
        outputStream.open()
        if let data = text.data(using: .utf8) {
            _ = outputStream.write(data.bytes, maxLength: data.count)
        }
    }

    func close() {
        outputStream.close()
    }
}
