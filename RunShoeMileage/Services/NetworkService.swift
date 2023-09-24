//  NetworkService.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 9/6/23.
//  
//

import Foundation

/// A service that throws errors that are related to the service itself.
protocol ThrowingService {
    /// The error structure that contains all the errors for a given service
    associatedtype DomainError: Error
}

/**
 Functions to implement a networking service that deals with JSON data within a REST API
 */
protocol JSONNetworkService: ThrowingService {
    /**
     A standard GET call that transforms the network return data to a Decodable object.
     
     - Parameter url: The URL of the desired API endpoint.
     - Returns: The decodable domain object created from the JSON data
     - Throws: Domain Error of the concrete service.
     */
    func getJSONData<T:Decodable>(url: URL) async throws -> T
    
    /**
     A standard POST call that transforms the encodable DTO into JSON data that is then added to the
     body of the call.
     
     - Parameters:
        - dto: Encodable DTO (Data Transfer Object). The CodingKeys must map to the parameters that the endpoint is expecting.
        - url: The URL of the desired API endpoint.
        - authToken: Option authorization token. If provided, it will be added to the header.
     - Returns: Response Data (currently I have no domain response objects, so this is just data rather than a Decodable).
     - Throws: Domain Error of the concrete service.
     */
    func postJSON(dto: Encodable, url: URL, authToken: String?) async throws -> Data
}

class NetworkService: JSONNetworkService {
    enum DomainError: Error {
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
    
    /**
     A pure GET call that returns raw data
     
     - Parameter url: Endpoint URL
     - Returns: a raw DATA object
     - Throws: DomainError
     */
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
    
    /**
     A pure POST call that adds the raw data to the body of the call.
     
     - Parameter url: Endpoint URL
     - Returns: a raw DATA object
     - Throws: DomainError
     */
    func post(request: URLRequest, data: Data) async throws -> Data {
        do {
            let (data, urlResponse) = try await session.upload(for: request, from: data)
            try validate(response: urlResponse)
            return data
        }
        catch let error {
            if error.isOtherConnectionError == true {
                throw DomainError.reachability
            }
            throw error
        }
    }
    
    /**
     Validation logic for the URLResponse
     
     - Parameter response: standard network response
     */
    func validate(response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw DomainError.unknown
        }
        if (200...299).contains(httpResponse.statusCode) {
            return
        }
        else {
            throw DomainError.httpError(statusCode: httpResponse.statusCode)
        }
    }
    
    /**
     Evaluate the error response from the network and transforms it to a DomainError.
     
     - Parameter error: Error from the network
     - Returns: The mapped DomainError
     */
    func evaluate(error: Error) -> DomainError {
        if let domainError = error as? DomainError {
            // Error has already been transformed to ServiceError, return it.
            return domainError
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

// MARK: - Helper extensions for networking and JSON Codables
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
