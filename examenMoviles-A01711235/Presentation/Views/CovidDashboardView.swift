//
//  CovidDashboardView.swift
//  examenMoviles-A01711235
//
//  Created by Enrique Ayala on 27/11/25.
//

import SwiftUI

struct CovidDashboardView: View {
    @StateObject var vm = CovidViewModel()
    @State private var showDateFilter = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Barra de búsqueda
                searchBar
                
                // Contenido principal según estado
                contentView
            }
            .navigationTitle("COVID-19 Stats")
            .onAppear {
                vm.loadLastCountry()
            }
        }
    }
    
    private var searchBar: some View {
        HStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Buscar país (ej: Mexico, Canada)", text: $vm.searchText)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .submitLabel(.search)
                    .onSubmit {
                        Task { await vm.searchCountry() }
                    }
                
                if !vm.searchText.isEmpty {
                    Button {
                        vm.searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(12)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            Button {
                Task { await vm.searchCountry() }
            } label: {
                Image(systemName: "arrow.right.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            .disabled(vm.searchText.isEmpty)
        }
        .padding()
    }
    
    @ViewBuilder
    private var contentView: some View {
        switch vm.loadingState {
        case .idle:
            idleView
        case .loading:
            loadingView
        case .success(let country):
            successView(country: country)
        case .error(let message):
            errorView(message: message)
        }
    }
    
    private var idleView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "globe.americas.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .foregroundColor(.blue.opacity(0.5))
            
            VStack(spacing: 8) {
                Text("Bienvenido")
                    .font(.title2.bold())
                
                Text("Ingresa el nombre de un país para consultar sus estadísticas de COVID-19")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            Spacer()
            
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Cargando datos...")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
    
    private func successView(country: CovidCountry) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header del país
                countryHeader(country: country)
                
                // Filtro de fechas
                dateFilterSection
                
                // Tarjetas de estadísticas
                statsCards
                
                // Gráfico de barras simplificado
                chartSection
                
                // Lista de datos recientes
                recentDataSection
            }
            .padding()
        }
    }
    
    private func countryHeader(country: CovidCountry) -> some View {
        VStack(spacing: 8) {
            Text(country.country)
                .font(.title.bold())
            
            Text("Región: \(country.region)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("Datos desde \(country.earliestDate) hasta \(country.latestDate)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private var dateFilterSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Filtrar por fechas")
                    .font(.headline)
                
                Spacer()
                
                Button {
                    showDateFilter.toggle()
                } label: {
                    Image(systemName: showDateFilter ? "chevron.up" : "chevron.down")
                }
            }
            
            if showDateFilter {
                VStack(spacing: 12) {
                    if !vm.availableDates.isEmpty {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Desde")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Picker("Desde", selection: Binding(
                                    get: { vm.selectedStartDate ?? vm.availableDates.first ?? "" },
                                    set: { vm.selectedStartDate = $0 }
                                )) {
                                    ForEach(vm.availableDates, id: \.self) { date in
                                        Text(date).tag(date)
                                    }
                                }
                                .pickerStyle(.menu)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .leading) {
                                Text("Hasta")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Picker("Hasta", selection: Binding(
                                    get: { vm.selectedEndDate ?? vm.availableDates.last ?? "" },
                                    set: { vm.selectedEndDate = $0 }
                                )) {
                                    ForEach(vm.availableDates, id: \.self) { date in
                                        Text(date).tag(date)
                                    }
                                }
                                .pickerStyle(.menu)
                            }
                        }
                        
                        Button {
                            vm.filterByDateRange()
                        } label: {
                            Text("Aplicar filtro")
                                .font(.subheadline.bold())
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 8)
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var statsCards: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            StatCard(
                title: "Total de Casos",
                value: formatNumber(vm.filteredTotalCases),
                icon: "person.3.fill",
                color: .blue
            )
            
            StatCard(
                title: "Nuevos Casos (Suma)",
                value: formatNumber(vm.filteredNewCasesSum),
                icon: "plus.circle.fill",
                color: .orange
            )
            
            StatCard(
                title: "Promedio Diario",
                value: formatNumber(vm.averageNewCases),
                icon: "chart.line.uptrend.xyaxis",
                color: .green
            )
            
            StatCard(
                title: "Pico Máximo",
                value: formatNumber(vm.maxNewCases),
                icon: "arrow.up.circle.fill",
                color: .red
            )
        }
    }
    
    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tendencia de Nuevos Casos")
                .font(.headline)
            
            if !vm.filteredDailyData.isEmpty {
                // Gráfico de barras simplificado
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .bottom, spacing: 2) {
                        // Mostrar últimos 30 días o menos
                        let dataToShow = Array(vm.filteredDailyData.suffix(30))
                        let maxValue = Double(dataToShow.compactMap { $0.newCases }.max() ?? 1)
                        
                        ForEach(dataToShow) { record in
                            VStack(spacing: 4) {
                                Rectangle()
                                    .fill(Color.blue.gradient)
                                    .frame(
                                        width: 8,
                                        height: CGFloat(Double(record.newCases ?? 0) / maxValue * 100)
                                    )
                                    .cornerRadius(2)
                            }
                        }
                    }
                    .frame(height: 120)
                    .padding(.vertical, 8)
                }
                
                Text("Últimos \(min(vm.filteredDailyData.count, 30)) días")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var recentDataSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Datos Recientes")
                .font(.headline)
            
            // Mostrar últimos 10 registros
            ForEach(vm.filteredDailyData.suffix(10).reversed()) { record in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(record.formattedDate)
                            .font(.subheadline.bold())
                        
                        Text("Total: \(formatNumber(record.totalCases ?? 0))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                                .font(.caption)
                            Text(formatNumber(record.newCases ?? 0))
                                .font(.subheadline.bold())
                        }
                        .foregroundColor(.orange)
                        
                        Text("nuevos casos")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(8)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.orange)
            
            VStack(spacing: 8) {
                Text("Error")
                    .font(.title2.bold())
                
                Text(message)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
            
            Button {
                Task { await vm.searchCountry() }
            } label: {
                Label("Reintentar", systemImage: "arrow.clockwise")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            
            Spacer()
        }
    }
    
    private func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title2.bold())
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    CovidDashboardView()
}
