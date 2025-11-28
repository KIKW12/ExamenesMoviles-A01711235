//
//  LocalService.swift
//  examenMoviles-A01711235
//
//  Created by Enrique Ayala on 27/11/25.
//

import Foundation

class LocalService {
    static let shared = LocalService()
    
    private let userKey = "currentUser"
    private let lastCountryKey = "lastCountry"
    
    func getCurrentUser() -> String? {
        UserDefaults.standard.string(forKey: userKey)
    }
    
    func setCurrentUser(email: String) {
        UserDefaults.standard.set(email, forKey: userKey)
    }
    
    func removeCurrentUser() {
        UserDefaults.standard.removeObject(forKey: userKey)
    }
    
    func getLastCountry() -> String? {
        UserDefaults.standard.string(forKey: lastCountryKey)
    }
    
    func setLastCountry(country: String) {
        UserDefaults.standard.set(country, forKey: lastCountryKey)
    }
}
