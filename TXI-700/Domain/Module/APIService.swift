//
//  APIService.swift
//  TXI-700
//
//  Created by 서용준 on 1/12/26.
//

import Foundation

final class APIService {
    
    static let shared = APIService()
    private init() {}
    
    private let baseURL = URL(string: "https://your-server-domain.com/api/print")!
    
    func uploadPayloads(
        _ payloads: [PrintPayload],
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        var request = URLRequest(url: baseURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(payloads)
            request.httpBody = jsonData
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let http = response as? HTTPURLResponse,
               !(200...299).contains(http.statusCode) {
                completion(.failure(
                    NSError(domain: "HTTPError", code: http.statusCode)
                ))
                return
            }
            
            completion(.success(()))
        }
        .resume()
    }
}
