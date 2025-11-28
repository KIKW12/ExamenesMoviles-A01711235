//
//  LoginView.swift
//  examenMoviles-A01711235
//
//  Created by Enrique Ayala on 27/11/25.
//

import SwiftUI
import FlowStacks

struct LoginView: View {
    @EnvironmentObject var navigator: FlowNavigator<Screen>
    @StateObject var vm = LoginViewModel()
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Logo/Icono
            VStack(spacing: 16) {
                Image(systemName: "heart.text.square.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                
                Text("COVID-19 Stats")
                    .font(.largeTitle.bold())
                
                Text("Consulta estadísticas de COVID-19 por país")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            // Campo de correo
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Correo Electrónico")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    TextField("ejemplo@correo.com", text: $vm.email)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .font(.body)
                }
                
                // Botón de acceso
                Button {
                    vm.setCurrentUser()
                    if !vm.showAlert {
                        navigator.presentCover(.menu)
                    }
                } label: {
                    Text("Acceder")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .onAppear {
            vm.getCurrentUser()
            if !vm.email.isEmpty {
                navigator.presentCover(.menu)
            }
        }
        .alert("Oops!", isPresented: $vm.showAlert) {
            Button("Aceptar", role: .cancel) { }
        } message: {
            Text(vm.messageAlert)
        }
    }
}

#Preview {
    Coordinator()
}
