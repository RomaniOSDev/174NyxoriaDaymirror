//
//  NyxoriaDaymirrorManager.swift
//  174NyxoriaDaymirror
//

import UIKit
import Combine
import WebKit
import AppsFlyerLib
import SwiftUI
import UserNotifications
import Foundation

public class NyxoriaDaymirrorManager: NSObject, @preconcurrency AppsFlyerLibDelegate {
    internal var lockRef: String = ""
    internal var appsRefKey: String = ""
    internal var tokenRef: String = ""
    internal var paramRef: String = ""
    
    @AppStorage("TestGraphQLUpdateManagerInitial") var TestGraphQLUpdateManagerInitial: String?
    @AppStorage("TestGraphQLUpdateManagerStatus")  var TestGraphQLUpdateManagerStatus: Bool = false
    @AppStorage("TestGraphQLUpdateManagerFinal")   var TestGraphQLUpdateManagerFinal: String?
    
    @MainActor public static let shared = NyxoriaDaymirrorManager()
    
    internal var appIDRef: String = ""
    internal var langRef: String = ""
    internal var TestGraphQLUpdateManagerWindow: UIWindow?
    
    internal var NyxoriaDaymirrorUpdateManagerSessionStarted = false
    internal var NyxoriaDaymirrorUpdateManagerTokenHex = ""
    internal var NyxoriaDaymirrorUpdateManagerCollector = Set<AnyCancellable>()
    
    private override init() {
        let cfg = URLSessionConfiguration.default
        cfg.timeoutIntervalForRequest = 20
        cfg.timeoutIntervalForResource = 20
        let debugRand = Int.random(in: 1...999)
        print("TestGraphQLUpdateManager init -> \(debugRand)")
        super.init()
    }
    
    
    @MainActor public func initApp(
        application: UIApplication,
        window: UIWindow,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        TestGraphQLUpdateManagerAskNotifications(app: application)
        
        let randomVal = Int.random(in: 10...99) + 3
        print("Run: \(randomVal)")
        
        appsRefKey = "appData"
        appIDRef   = "appId"
        langRef    = "appLng"
        tokenRef   = "appTk"
        
        lockRef  = "https://likrejiink.space/graphql"
        paramRef = "data"
        
        TestGraphQLUpdateManagerWindow = window
        
        TestGraphQLUpdateManagerSetupAppsFlyer(appID: "6768586354", devKey: "BVE6cC7xwN8jkMuPCDH6s3")
        
        completion(.success("Initialization completed successfully"))
    }
    
    
    }
