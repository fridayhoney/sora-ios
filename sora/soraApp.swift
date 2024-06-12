//
//  soraApp.swift
//  sora
//
//  Created by Elias CHETOUANI on 27/04/2024.
//

import SwiftUI
import FirebaseCore


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct soraApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var purchaseManager = PurchaseManager()
    
    
    var body: some Scene {
        WindowGroup {
            MainView()
           // PaywallView()
            .environmentObject(purchaseManager)
        }
    }
}
