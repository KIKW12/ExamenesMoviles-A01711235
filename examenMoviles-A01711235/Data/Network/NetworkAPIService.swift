//
//  NetworkAPIService.swift
//  examenMoviles-A01711235
//
//  Created by Enrique Ayala on 27/11/25.
//

import Foundation
import Alamofire

class NetworkAPIService {
    static let shared = NetworkAPIService()
    
    private let apiKey = "wLVPN1zV08lJYF7uXqgyPw==zVwp6TlVcAO1NLUf"
    private let baseURL = "https://api.api-ninjas.com/v1/covid19"
    
    // Headers comunes para todas las peticiones
    private var headers: HTTPHeaders {
        [
            "X-Api-Key": apiKey,
            "Accept": "application/json"
        ]
    }
    
    func getCovidData(country: String) async -> Result<[CovidCountryResponse], Error> {
        await getCovidData(country: country, date: nil)
    }
    
    func getCovidData(country: String, date: String?) async -> Result<[CovidCountryResponse], Error> {
        // Construir parámetros
        var parameters: [String: String] = ["country": country]
        
        if let date = date {
            parameters["date"] = date
        }
        
        // Realizar petición con Alamofire
        let response = await AF.request(
            baseURL,
            method: .get,
            parameters: parameters,
            headers: headers
        )
        .validate(statusCode: 200..<300)
        .serializingData()
        .response
        
        // Procesar respuesta
        switch response.result {
        case .success(let data):
            do {
                let decoded = try JSONDecoder().decode([CovidCountryResponse].self, from: data)
                return .success(decoded)
            } catch {
                debugPrint("Error de decodificación: \(error)")
                return .failure(NetworkError.decodingError)
            }
            
        case .failure(let error):
            debugPrint("Error de Alamofire: \(error)")
            return .failure(mapAlamofireError(error, statusCode: response.response?.statusCode))
        }
    }
    
    // Mapear errores de Alamofire a NetworkError
    private func mapAlamofireError(_ error: AFError, statusCode: Int?) -> NetworkError {
        if let statusCode = statusCode {
            if statusCode == 401 || statusCode == 403 {
                return .unauthorized
            }
            return .serverError(statusCode)
        }
        
        switch error {
        case .invalidURL:
            return .invalidURL
        case .responseSerializationFailed:
            return .decodingError
        case .responseValidationFailed:
            return .invalidResponse
        default:
            return .networkError(error.localizedDescription)
        }
    }
}

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case serverError(Int)
    case decodingError
    case networkError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL inválida"
        case .invalidResponse:
            return "Respuesta inválida del servidor"
        case .unauthorized:
            return "Error de autenticación con el API"
        case .serverError(let code):
            return "Error del servidor (código: \(code))"
        case .decodingError:
            return "Error al procesar los datos"
        case .networkError(let message):
            return "Error de conexión: \(message)"
        }
    }
}
