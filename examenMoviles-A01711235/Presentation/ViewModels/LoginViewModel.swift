//
//  LoginViewModel.swift
//  examenMoviles-A01711235
//
//  Created by Enrique Ayala on 27/11/25.
//

import Foundation
import Combine

class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var messageAlert = ""
    @Published var showAlert = false
    
    var userReq: UserRequirementProtocol
    
    init(userReq: UserRequirementProtocol = UserRequirement.shared) {
        self.userReq = userReq
    }
    
    @MainActor
    func setCurrentUser() {
        if email.trimmingCharacters(in: .whitespaces).isEmpty {
            messageAlert = "Por favor ingresa un correo electrónico válido"
            showAlert = true
        } else if !isValidEmail(email) {
            messageAlert = "El formato del correo electrónico no es válido"
            showAlert = true
        } else {
            userReq.setCurrentUser(email: email)
        }
    }
    
    @MainActor
    func getCurrentUser() {
        email = userReq.getCurrentUser() ?? ""
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}
