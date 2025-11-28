//
//  CovidRepository.swift
//  examenMoviles-A01711235
//
//  Created by Enrique Ayala on 27/11/25.
//

import Foundation

struct Api {
    static let base = "https://api.api-ninjas.com/v1"
    
    struct routes {
        static let covid = "/covid19"
    }
}

protocol CovidAPIProtocol {
    func getCovidData(country: String) async -> Result<CovidCountry, Error>
    func getCovidData(country: String, date: String?) async -> Result<CovidCountry, Error>
}

class CovidRepository: CovidAPIProtocol {
    static let shared = CovidRepository()
    
    let nservice: NetworkAPIService
    
    init(nservice: NetworkAPIService = NetworkAPIService.shared) {
        self.nservice = nservice
    }
    
    func getCovidData(country: String) async -> Result<CovidCountry, Error> {
        let result = await nservice.getCovidData(country: country)
        
        switch result {
        case .success(let responses):
            if let response = responses.first {
                let processedCountry = processResponse(response)
                return .success(processedCountry)
            } else {
                return .failure(CovidError.countryNotFound)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func getCovidData(country: String, date: String?) async -> Result<CovidCountry, Error> {
        let result = await nservice.getCovidData(country: country, date: date)
        
        switch result {
        case .success(let responses):
            if let response = responses.first {
                let processedCountry = processResponse(response)
                return .success(processedCountry)
            } else {
                return .failure(CovidError.countryNotFound)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    private func processResponse(_ response: CovidCountryResponse) -> CovidCountry {
        var dailyRecords: [CovidDailyRecord] = []
        
        if let cases = response.cases {
            // Ordenar por fecha
            let sortedDates = cases.keys.sorted()
            
            for date in sortedDates {
                if let dayData = cases[date] {
                    let record = CovidDailyRecord(
                        date: date,
                        totalCases: dayData.total,
                        newCases: dayData.new
                    )
                    dailyRecords.append(record)
                }
            }
        }
        
        return CovidCountry(
            country: response.country,
            region: response.region ?? "Global",
            dailyData: dailyRecords
        )
    }
}

enum CovidError: Error, LocalizedError {
    case countryNotFound
    case networkError
    case decodingError
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .countryNotFound:
            return "No se encontraron datos para el país especificado. Verifica el nombre e intenta de nuevo."
        case .networkError:
            return "Error de conexión. Verifica tu conexión a internet e intenta de nuevo."
        case .decodingError:
            return "Error al procesar los datos. Intenta de nuevo más tarde."
        case .unknownError:
            return "Ocurrió un error inesperado. Intenta de nuevo."
        }
    }
}
