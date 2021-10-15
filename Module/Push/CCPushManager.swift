//
//  CCPushManager.swift
//  HelloSwift
//
//  Created by well on 2021/10/15.
//

import Foundation

class CCPushManager: NSObject {
    
    /// 注册通知
    static func requestAuthorization(_ application: UIApplication)  {
        let notificationCenter = UNUserNotificationCenter.current()
        // 每次冷启动,先移除所有通知内容,再执行后续操作
        notificationCenter.removeAllDeliveredNotifications()
        notificationCenter.requestAuthorization(options: [.sound, .alert, .badge]) { requestRes, requestErr in
            // 若注册失败,则直接返回,不执行后续操作
            guard  requestRes else { return }
            
            notificationCenter.getNotificationSettings { settings in
                // 仅在用户未执行"通知"授权时,注册即可
                if (settings.authorizationStatus == .notDetermined) {
                    DispatchQueue.main.async { application.registerForRemoteNotifications() }
                } else if (settings.authorizationStatus == .authorized) {
                    notificationCenter.requestAuthorization(options: [.sound, .alert, .badge]) { requestRes, requestErr in
                        // 用户已授权,添加通知内容
                        if requestRes { self.requestWeather() }
                    }
                }
            }
        }
    }
    
    /// 获取天气信息
    private static func requestWeather() {
        CCLocationManager.requestWeather { model in
            // 非空校验
            guard model.text != nil, model.temp != nil, model.feelsLike != nil, model.windScale != nil, model.precip != nil, model.vis != nil else { return }
            self.addNotificationRequest(model)
        }
    }
    
    /// 添加本地通知
    private static func addNotificationRequest(_ model: CCWeatherModel) {
        let resString = String(format: "今日天气:%@,室外温度:%@,体感温度:%@,风力:%@,降水量:%@,能见度:%@", model.text!, model.temp!, model.feelsLike!, model.windScale!, model.precip!, model.vis!)
        
        let notificationCenter = UNUserNotificationCenter.current()
        let notificationContent = UNMutableNotificationContent()
        
        notificationContent.sound = .default
        notificationContent.title = "每日推送😊"
        notificationContent.body = resString
        
        var notificationDate = DateComponents()
        notificationDate.hour = 7
        notificationDate.minute = 30
        notificationDate.second = 00
        
        let notificationTrigger = UNCalendarNotificationTrigger(dateMatching: notificationDate, repeats: true)
        
        let notificationRequest = UNNotificationRequest(identifier: AppDelegate.classString(), content: notificationContent, trigger: notificationTrigger)
        
        notificationCenter.add(notificationRequest, withCompletionHandler: nil)
    }
}
