//
//  MenuView.swift
//  examenMoviles-A01711235
//
//  Created by Enrique Ayala on 27/11/25.
//

import SwiftUI

struct MenuView: View {
    var body: some View {
        TabView {
            CovidDashboardView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Dashboard")
                }
            
            PerfilView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Perfil")
                }
        }
    }
}

#Preview {
    MenuView()
}
