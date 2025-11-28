//
//  CovidViewModel.swift
//  examenMoviles-A01711235
//
//  Created by Enrique Ayala on 27/11/25.
//

import Foundation
import Combine

class CovidViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var selectedCountry: CovidCountry?
    @Published var loadingState: LoadingState<CovidCountry> = .idle
    @Published var availableDates: [String] = []
    @Published var selectedStartDate: String?
    @Published var selectedEndDate: String?
    @Published var filteredDailyData: [CovidDailyRecord] = []
    
    var covidReq: CovidRequirementProtocol
    var userReq: UserRequirementProtocol
    
    init(covidReq: CovidRequirementProtocol = CovidRequirement.shared,
         userReq: UserRequirementProtocol = UserRequirement.shared) {
        self.covidReq = covidReq
        self.userReq = userReq
    }
    
    @MainActor
    func loadLastCountry() {
        if let lastCountry = userReq.getLastCountry() {
            searchText = lastCountry
        }
    }
    
    @MainActor
    func searchCountry() async {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else {
            loadingState = .error("Por favor ingresa el nombre de un país")
            return
        }
        
        loadingState = .loading
        
        let result = await covidReq.getCovidData(country: searchText)
        
        switch result {
        case .success(let country):
            selectedCountry = country
            availableDates = country.dailyData.map { $0.date }
            filteredDailyData = country.dailyData
            loadingState = .success(country)
            
            // Guardar el país como última búsqueda
            userReq.setLastCountry(country: searchText)
            
            // Resetear filtros de fecha
            selectedStartDate = availableDates.first
            selectedEndDate = availableDates.last
            
        case .failure(let error):
            let message = (error as? LocalizedError)?.errorDescription ?? "Error al obtener los datos. Intenta de nuevo."
            loadingState = .error(message)
        }
    }
    
    @MainActor
    func filterByDateRange() {
        guard let country = selectedCountry else { return }
        
        guard let startDate = selectedStartDate,
              let endDate = selectedEndDate else {
            filteredDailyData = country.dailyData
            return
        }
        
        filteredDailyData = country.dailyData.filter { record in
            record.date >= startDate && record.date <= endDate
        }
    }
    
    var filteredTotalCases: Int {
        filteredDailyData.last?.totalCases ?? 0
    }
    
    var filteredNewCasesSum: Int {
        filteredDailyData.reduce(0) { $0 + ($1.newCases ?? 0) }
    }
    
    var averageNewCases: Int {
        guard !filteredDailyData.isEmpty else { return 0 }
        return filteredNewCasesSum / filteredDailyData.count
    }
    
    var maxNewCases: Int {
        filteredDailyData.compactMap { $0.newCases }.max() ?? 0
    }
    
    var maxNewCasesDate: String {
        filteredDailyData.first { $0.newCases == maxNewCases }?.formattedDate ?? "N/A"
    }
}
