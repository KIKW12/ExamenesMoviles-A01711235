//
//  UserRepository.swift
//  examenMoviles-A01711235
//
//  Created by Enrique Ayala on 27/11/25.
//

import Foundation

protocol UserServiceProtocol {
    func getCurrentUser() -> String?
    func setCurrentUser(email: String)
    func removeCurrentUser()
    func getLastCountry() -> String?
    func setLastCountry(country: String)
}

class UserRepository: UserServiceProtocol {
    static let shared = UserRepository()
    
    var localService: LocalService
    
    init(localService: LocalService = LocalService.shared) {
        self.localService = localService
    }
    
    func getCurrentUser() -> String? {
        localService.getCurrentUser()
    }
    
    func setCurrentUser(email: String) {
        localService.setCurrentUser(email: email)
    }
    
    func removeCurrentUser() {
        localService.removeCurrentUser()
    }
    
    func getLastCountry() -> String? {
        localService.getLastCountry()
    }
    
    func setLastCountry(country: String) {
        localService.setLastCountry(country: country)
    }
}
