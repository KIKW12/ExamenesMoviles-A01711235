//
//  CovidModels.swift
//  examenMoviles-A01711235
//
//  Created by Enrique Ayala on 27/11/25.
//

import Foundation

// El API retorna un array donde cada elemento tiene el nombre del país
// y un diccionario de fechas con los datos de cada día

struct CovidCountryResponse: Codable {
    var country: String
    var region: String?
    var cases: [String: CovidDayData]?
}

struct CovidDayData: Codable {
    var total: Int?
    var new: Int?
    
    enum CodingKeys: String, CodingKey {
        case total
        case new
    }
}

struct CovidCountry: Identifiable {
    var id: String { country }
    var country: String
    var region: String
    var dailyData: [CovidDailyRecord]
    
    // Estadísticas calculadas
    var totalCases: Int {
        dailyData.last?.totalCases ?? 0
    }
    
    var totalNewCases: Int {
        dailyData.reduce(0) { $0 + ($1.newCases ?? 0) }
    }
    
    var latestDate: String {
        dailyData.last?.date ?? "N/A"
    }
    
    var earliestDate: String {
        dailyData.first?.date ?? "N/A"
    }
}

struct CovidDailyRecord: Identifiable, Hashable {
    var id: String { date }
    var date: String
    var totalCases: Int?
    var newCases: Int?
    
    var formattedDate: String {
        // Convertir de "2020-01-22" a formato más legible
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd MMM yyyy"
        outputFormatter.locale = Locale(identifier: "es_MX")
        
        if let date = inputFormatter.date(from: date) {
            return outputFormatter.string(from: date)
        }
        return date
    }
}

enum LoadingState<T> {
    case idle
    case loading
    case success(T)
    case error(String)
    
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
    
    var errorMessage: String? {
        if case .error(let message) = self { return message }
        return nil
    }
    
    var data: T? {
        if case .success(let data) = self { return data }
        return nil
    }
}

struct CovidComparison: Identifiable {
    var id = UUID()
    var countries: [CovidCountry]
    
    var comparisonData: [(country: String, totalCases: Int, latestNew: Int)] {
        countries.map { country in
            let latestNew = country.dailyData.last?.newCases ?? 0
            return (country.country, country.totalCases, latestNew)
        }
    }
}
