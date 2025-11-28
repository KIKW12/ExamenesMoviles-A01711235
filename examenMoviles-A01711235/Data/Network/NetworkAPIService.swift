//
//  NetworkAPIService.swift
//  examenMoviles-A01711235
//
//  Created by Enrique Ayala on 27/11/25.
//

import Foundation

class NetworkAPIService {
    static let shared = NetworkAPIService()
    
    private let apiKey = "wLVPN1zV08lJYF7uXqgyPw==zVwp6TlVcAO1NLUf"
    private let baseURL = "https://api.api-ninjas.com/v1/covid19"
    
    func getCovidData(country: String) async -> Result<[CovidCountryResponse], Error> {
        await getCovidData(country: country, date: nil)
    }
    
    func getCovidData(country: String, date: String?) async -> Result<[CovidCountryResponse], Error> {
        // Construir URL con parámetros
        var components = URLComponents(string: baseURL)!
        var queryItems = [URLQueryItem(name: "country", value: country)]
        
        if let date = date {
            queryItems.append(URLQueryItem(name: "date", value: date))
        }
        
        components.queryItems = queryItems
        
        guard let url = components.url else {
            return .failure(NetworkError.invalidURL)
        }
        
        // Crear request con headers
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "X-Api-Key")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Verificar respuesta HTTP
            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(NetworkError.invalidResponse)
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                if httpResponse.statusCode == 401 || httpResponse.statusCode == 403 {
                    return .failure(NetworkError.unauthorized)
                }
                return .failure(NetworkError.serverError(httpResponse.statusCode))
            }
            
            // Decodificar respuesta
            let decoded = try JSONDecoder().decode([CovidCountryResponse].self, from: data)
            return .success(decoded)
            
        } catch let error as DecodingError {
            debugPrint("Error de decodificación: \(error)")
            return .failure(NetworkError.decodingError)
        } catch {
            debugPrint("Error de red: \(error.localizedDescription)")
            return .failure(NetworkError.networkError(error.localizedDescription))
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
