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
    enum ServiceError: Error {
        case unknown
        case reachability
        case timeout
        case jsonDecodingError(error: DecodingError)
        case jsonEncodingError(error: EncodingError)
        case httpError(statusCode: Int)
    }
    
    let session: URLSession
    
    init (session: URLSession = .shared) {
        self.session = session
    }
    
    func getJSONData<T:Decodable>(url: URL) async throws -> T {
        let data = try await getData(url: url)
        do {
            return try data.jsonDecode()
        }
        catch let error {
            throw evaluate(error: error)
        }
    }
    
    func getData(url: URL) async throws -> Data {
        do {
            let (data, response) = try await session.data(from: url)
            try validate(response: response)
            return data
        }
        catch let error {
            throw evaluate(error: error)
        }
    }
    
    func postJSON(dto: Encodable, url: URL, authToken: String?) async throws -> Data {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = authToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        let bodyData: Data
        do {
            bodyData = try JSONEncoder().encode(dto)
            let data = try await post(request: request, data: bodyData)
            return data
        }
        catch let error {
            throw evaluate(error: error)
        }
    }
    
    func post(request: URLRequest, data: Data) async throws -> Data {
        do {
            let (data, urlResponse) = try await session.upload(for: request, from: data)
            try validate(response: urlResponse)
            return data
        }
        catch let error {
            if error.isOtherConnectionError == true {
                throw ServiceError.reachability
            }
            throw error
        }
    }
    
    func validate(response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ServiceError.unknown
        }
        if (200...299).contains(httpResponse.statusCode) {
            return
        }
        else {
            throw ServiceError.httpError(statusCode: httpResponse.statusCode)
        }
    }
    
    func evaluate(error: Error) -> ServiceError {
        if let serviceError = error as? ServiceError {
            // Error has already been transformed to ServiceError, return it.
            return serviceError
        }
        if error.isOtherConnectionError == true {
            return .reachability
        }
        if let error = error as? EncodingError {
            return .jsonEncodingError(error: error)
        }
        if let error = error as? DecodingError {
            return .jsonDecodingError(error: error)
        }
        return .unknown
    }
    
}

extension Data {
    func jsonDecode<T:Decodable>() throws -> T {
        return try JSONDecoder().decode(T.self, from: self)
    }
}

extension Encodable {
    func jsonEncode() throws -> Data {
        return try JSONEncoder().encode(self)
    }
}

// Reachability error code from this article:
// https://www.avanderlee.com/swift/optimizing-network-reachability/
public var NSURLErrorConnectionFailureCodes: [Int] {
    [
        NSURLErrorBackgroundSessionInUseByAnotherProcess, /// Error Code: `-996`
        NSURLErrorCannotFindHost, /// Error Code: ` -1003`
        NSURLErrorCannotConnectToHost, /// Error Code: ` -1004`
        NSURLErrorNetworkConnectionLost, /// Error Code: ` -1005`
        NSURLErrorNotConnectedToInternet, /// Error Code: ` -1009`
        NSURLErrorSecureConnectionFailed /// Error Code: ` -1200`
    ]
}

extension Error {
    /// Indicates an error which is caused by various connection related issue or an unaccepted status code.
    /// See: `NSURLErrorConnectionFailureCodes`
    var isOtherConnectionError: Bool {
        NSURLErrorConnectionFailureCodes.contains(_code)
    }
}
