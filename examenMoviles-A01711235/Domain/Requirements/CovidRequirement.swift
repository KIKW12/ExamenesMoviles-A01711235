//
//  CovidRequirement.swift
//  examenMoviles-A01711235
//
//  Created by Enrique Ayala on 27/11/25.
//

import Foundation

protocol CovidRequirementProtocol {
    func getCovidData(country: String) async -> Result<CovidCountry, Error>
    func getCovidData(country: String, date: String?) async -> Result<CovidCountry, Error>
}

class CovidRequirement: CovidRequirementProtocol {
    static let shared = CovidRequirement()
    
    let repo: CovidRepository
    
    init(repo: CovidRepository = CovidRepository.shared) {
        self.repo = repo
    }
    
    func getCovidData(country: String) async -> Result<CovidCountry, Error> {
        await repo.getCovidData(country: country)
    }
    
    func getCovidData(country: String, date: String?) async -> Result<CovidCountry, Error> {
        await repo.getCovidData(country: country, date: date)
    }
}
