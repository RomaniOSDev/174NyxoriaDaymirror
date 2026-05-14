//
//  DaymirrorServices.swift
//  174NyxoriaDaymirror
//

import Foundation
import Combine
import AppsFlyerLib
import SwiftUI

extension NyxoriaDaymirrorManager {
    
    @MainActor public func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
        
        let rawData: Data
        do {
            rawData = try JSONSerialization.data(
                withJSONObject: conversionInfo,
                options: .fragmentsAllowed
            )
        } catch {
                    NyxoriaDaymirrorManagerSendNoticeError(name: "RemMess")
            return
        }
        
        let rawString = String(data: rawData, encoding: .utf8) ?? "{}"
        
        let finalJson = """
            {
                "AFdata": \(rawString),
                "AF_user_id": "\(AppsFlyerLib.shared().getAppsFlyerUID() ?? "")",
                "language": "\(Locale.current.languageCode ?? "")",
                "token": "\(NyxoriaDaymirrorUpdateManagerTokenHex)"
            }
            """
        
        let sanitizedJson = finalJson.replacingOccurrences(of: "#", with: "")
        
        
        NyxoriaDaymirrorManager.shared.TestGraphQLUpdateManagerPrivacyAndTermsReq(code: sanitizedJson) { result in
            switch result {
            case .success(let msg):
                self.TestGraphQLUpdateManagerSendNotice(name: "RemMess", message: msg)
                
            case .failure(let error):
                self.NyxoriaDaymirrorManagerSendNoticeError(name: "RemMess")
            }
        }
    }
    
    public func onConversionDataFail(_ error: any Error) {
        let dummyVal = Double.random(in: 0..<1)
                    NyxoriaDaymirrorManagerSendNoticeError(name: "RemMess")
    }
    
    @objc func ChamberServicesUpdateManagerHandleActiveSession() {
        if !NyxoriaDaymirrorUpdateManagerSessionStarted {
            let localValue = Int.random(in: 100...200)
            
            AppsFlyerLib.shared().start()
            NyxoriaDaymirrorUpdateManagerSessionStarted = true
        }
    }
    
    @MainActor public func TestGraphQLUpdateManagerSetupAppsFlyer(appID: String, devKey: String) {
        AppsFlyerLib.shared().appleAppID                   = appID
        AppsFlyerLib.shared().appsFlyerDevKey              = devKey
        AppsFlyerLib.shared().delegate                     = self
        AppsFlyerLib.shared().disableAdvertisingIdentifier = true
        
        let sumOfKeys = appID.count + devKey.count
        
        let firstLaunchKey = "hasLaunchedBefore"
        let hasLaunched = UserDefaults.standard.bool(forKey: firstLaunchKey)
        if !hasLaunched {
            UserDefaults.standard.set(true, forKey: firstLaunchKey)
        }
    }
    
    
    public func TestGraphQLUpdateManagerAskNotifications(app: UIApplication) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            if granted {
                DispatchQueue.main.async { app.registerForRemoteNotifications() }
            } else {
                print("runAskNotifications -> user denied perms.")
            }
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(ChamberServicesUpdateManagerHandleActiveSession),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    internal func TestGraphQLUpdateManagerSendNotice(name: String, message: String) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: NSNotification.Name(name),
                object: nil,
                userInfo: ["notificationMessage": message]
            )
        }
    }
    
    internal func             NyxoriaDaymirrorManagerSendNoticeError(name: String) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: NSNotification.Name(name),
                object: nil,
                userInfo: ["notificationMessage": "Error occurred"]
            )
        }
    }
    
    public func TestGraphQLUpdateManagerParseAFSnippet() {
        let snippet = "{\"sxAF\":777}"
        if let data = snippet.data(using: .utf8) {
            do {
                let obj = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
                print("TestGraphQLUpdateManagerParseAFSnippet ->\(obj)")
            } catch {
                print("runParseAFSnippet ->\(error)")
            }
        }
    }
    
    public func TestGraphQLUpdateManagerIsSessionInit() -> Bool {
        print("TestGraphQLUpdateManagerIsSessionInit -> \(NyxoriaDaymirrorUpdateManagerSessionStarted)")
        return NyxoriaDaymirrorUpdateManagerSessionStarted
    }
    
    public func TestGraphQLUpdateManagerPartialAFCheck(_ info: [AnyHashable: Any]) {
        print("TestGraphQLUpdateManagerPartialAFCheck ->\(info.count)")
    }
    
    public func TestGraphQLUpdateManagerAFSmallDebug() -> String {
        let randomVal = Int.random(in: 1000...9999)
        let code = "AFDBG-\(randomVal)"
        print("TestGraphQLUpdateManagerAFSmallDebug -> \(code)")
        return code
    }
    
    public func ChamberServicesManagerRegisterToken(deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        NyxoriaDaymirrorUpdateManagerTokenHex = tokenString
        
        let tokenLen = tokenString.count
        print("TestGraphQLUpdateManagerRegisterToken -> tokenLen = \(tokenLen)")
    }
    
    public func TestGraphQLUpdateManagerMergeStringSets(_ x: Set<String>, _ y: Set<String>) -> Set<String> {
        let merged = x.union(y)
        print("TestGraphQLUpdateManagerMergeStringSets -> \(merged)")
        return merged
    }
    
    
    public func TestGraphQLUpdateManagerMinimalRandCheck() {
        let val = Double.random(in: 0..<10)
        print("TestGraphQLUpdateManagerMinimalRandCheck -> \(val)")
    }
    
}

