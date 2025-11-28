//
//  PerfilViewModel.swift
//  examenMoviles-A01711235
//
//  Created by Enrique Ayala on 27/11/25.
//

import Foundation
import Combine

class PerfilViewModel: ObservableObject {
    @Published var email = ""
    @Published var lastCountry = ""
    
    var userReq: UserRequirementProtocol
    
    init(userReq: UserRequirementProtocol = UserRequirement.shared) {
        self.userReq = userReq
    }
    
    @MainActor
    func getCurrentUser() {
        email = userReq.getCurrentUser() ?? ""
        lastCountry = userReq.getLastCountry() ?? "Ninguno"
    }
    
    @MainActor
    func logOut() {
        email = ""
        userReq.removeCurrentUser()
    }
}
