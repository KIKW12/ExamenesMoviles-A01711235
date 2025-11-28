//
//  PerfilView.swift
//  examenMoviles-A01711235
//
//  Created by Enrique Ayala on 27/11/25.
//

import SwiftUI
import FlowStacks

struct PerfilView: View {
    @StateObject var vm = PerfilViewModel()
    @EnvironmentObject var navigator: FlowNavigator<Screen>
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Spacer()
                
                // Avatar
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                
                // Información del usuario
                VStack(spacing: 16) {
                    VStack(spacing: 4) {
                        Text("Correo Electrónico")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(vm.email.isEmpty ? "—" : vm.email)
                            .font(.headline)
                    }
                    
                    Divider()
                    
                    VStack(spacing: 4) {
                        Text("Último País Consultado")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(vm.lastCountry)
                            .font(.headline)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .cornerRadius(16)
                .padding(.horizontal)
                
                Spacer()
                
                // Botón de cerrar sesión
                Button {
                    vm.logOut()
                    navigator.goBackToRoot()
                } label: {
                    Label("Cerrar Sesión", systemImage: "rectangle.portrait.and.arrow.right")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
            .navigationTitle("Perfil")
            .onAppear {
                vm.getCurrentUser()
            }
        }
    }
}

#Preview {
    Coordinator()
}
