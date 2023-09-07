//  NetworkService.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 9/6/23.
//  
//

import Foundation


protocol JSONNetworkService {
    func getJSONData<T:Decodable>(url: URL) async throws -> T
}

class NetworkService: JSONNetworkService {
    let session: URLSession
    
    init (session: URLSession) {
        self.session = session
    }
    
    func getJSONData<T:Decodable>(url: URL) async throws -> T {
        let data = try await getData(url: url)
        do {
            return try data.jsonDecode()
        }
        catch let decodingError as DecodingError {
            throw NetworkError.jsonDecodingError(error: decodingError)
        }
        catch {
            throw NetworkError.unknownError
        }
    }
    
    func getData(url: URL) async throws -> Data {
        let (data, response) = try await session.data(from: url)
        try validate(response: response)
        return data
    }
    
    func postJSON(dto: Encodable, url: URL, authToken: String?) async throws -> Data {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = authToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        do {
            request.httpBody = try JSONEncoder().encode(dto)
        }
        catch(let error) {
            if let error = error as? EncodingError {
                throw NetworkError.jsonEncodingError(error: error)
            }
            else {
                throw NetworkError.unknownError
            }
        }
        let (data, urlResponse) = try await session.upload(for: request, from: try! JSONEncoder().encode(dto))
        try validate(response: urlResponse)
        return data
    }
    
    func validate(response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknownError
        }
        if (200...299).contains(httpResponse.statusCode) {
            return
        }
        else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }
    }
    
}

enum NetworkError: Error {
    case unknownError
    case jsonDecodingError(error: DecodingError)
    case jsonEncodingError(error: EncodingError)
    case httpError(statusCode: Int)
}

extension NetworkError {
    func generateNSError() -> NSError {
        switch self {
        case .unknownError:
            return NSError(domain: "Network", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown Error"])
        case .jsonDecodingError(let error):
            return NSError(domain: "Network", code: -1, userInfo: [NSLocalizedDescriptionKey: error.localizedDescription])
        case .jsonEncodingError(let error):
            return NSError(domain: "Network", code: -1, userInfo: [NSLocalizedDescriptionKey: error.localizedDescription])
        case .httpError(let statusCode):
            let errorString = HTTPURLResponse.localizedString(forStatusCode: statusCode)
            let localizedError = NSError(domain: "Network", code: statusCode, userInfo: [NSLocalizedDescriptionKey: errorString])
            return localizedError
        }
    }
}

extension Data {
    func jsonDecode<T:Decodable>() throws -> T {
        return try JSONDecoder().decode(T.self, from: self)
    }
}
