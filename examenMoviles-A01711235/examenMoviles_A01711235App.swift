//
//  examenMoviles_A01711235App.swift
//  examenMoviles-A01711235
//
//  Created by Enrique Ayala on 27/11/25.
//

import SwiftUI

@main
struct examenMoviles_A01711235App: App {
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            Coordinator()
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            switch newPhase {
            case .background:
                print("App State: Background")
            case .inactive:
                print("App State: Inactive")
            case .active:
                print("App State: Active")
            @unknown default:
                print("App State: Unknown")
            }
        }
    }
}
