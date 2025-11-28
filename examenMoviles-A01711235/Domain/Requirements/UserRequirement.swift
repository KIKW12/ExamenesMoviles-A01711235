//
//  UserRequirement.swift
//  examenMoviles-A01711235
//
//  Created by Enrique Ayala on 27/11/25.
//

import Foundation

protocol UserRequirementProtocol {
    func setCurrentUser(email: String)
    func getCurrentUser() -> String?
    func removeCurrentUser()
    func getLastCountry() -> String?
    func setLastCountry(country: String)
}

class UserRequirement: UserRequirementProtocol {
    static let shared = UserRequirement()
    
    let repo: UserRepository
    
    init(repo: UserRepository = UserRepository.shared) {
        self.repo = repo
    }
    
    func setCurrentUser(email: String) {
        repo.setCurrentUser(email: email)
    }
    
    func getCurrentUser() -> String? {
        repo.getCurrentUser()
    }
    
    func removeCurrentUser() {
        repo.removeCurrentUser()
    }
    
    func getLastCountry() -> String? {
        repo.getLastCountry()
    }
    
    func setLastCountry(country: String) {
        repo.setLastCountry(country: country)
    }
}
