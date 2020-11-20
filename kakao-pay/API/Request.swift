//
//  Request.swift
//  kakao-pay
//
//  Created by wonkyum kim on 2020/11/17.
//

import Foundation

enum RequestError: Error {
    case unknown
    case invalidURL(urlString: String)
    case requestFailed(response: HTTPURLResponse, data: Data)
}

class Request<T> {
    enum HTTPMethod: String {
        case get, post, put, delete
    }
    
    typealias RequestResult = Result<T, Error>
    typealias ResponseMapper = (Data) throws -> T
    
    let urlString: String
    private let method: HTTPMethod = .get
    private let parameters: [String: Any]
    private let headers: [String: String]
    private let mapper: ResponseMapper
    private var pendingTask: URLSessionDataTask?
    
    var urlStringWithQuery: String {
        return "\(urlString)?\(getQueryString())"
    }
    
    init(urlString: String, parameters: [String: Any] = [:], headers: [String: String] = [:], mapper: @escaping ResponseMapper) {
        self.urlString = urlString
        self.parameters = parameters
        self.headers = headers
        self.mapper = mapper
    }
    
    func execute(_ completion: @escaping (RequestResult) -> Void = { _ in }) {
        guard pendingTask == nil else { return }
        
        let completionOnMain: (RequestResult) -> Void = { [weak self] result in
            DispatchQueue.main.async {
                completion(result)
                self?.pendingTask = nil
            }
        }
        
        guard let urlRequest = makeURLRequest() else {
            completionOnMain(.failure(RequestError.invalidURL(urlString: urlString)))
            return
        }
        
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            guard let data = data, let response = response as? HTTPURLResponse else {
                completionOnMain(.failure(error ?? RequestError.unknown))
                return
            }
            
            guard 200..<300 ~= response.statusCode else {
                completionOnMain(.failure(RequestError.requestFailed(response: response, data: data)))
                return
            }
            
            do {
                completionOnMain(.success(try self.mapper(data)))
            } catch {
                completionOnMain(.failure(error))
            }
        }
        
        dataTask.resume()
        pendingTask = dataTask
    }
    
    func cancel() {
        guard let pendingTask = pendingTask else { return }
        
        pendingTask.cancel()
        self.pendingTask = nil
    }
    
    private func makeURLRequest() -> URLRequest? {
        guard let url = URL(string: urlStringWithQuery) else {
            return nil
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.allHTTPHeaderFields = headers
        return urlRequest
    }
    
    
    private func getQueryString() -> String {
        return parameters
            .map { element in
                let encodedValue: String
                if let stringValue = element.value as? String {
                    encodedValue = stringValue.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
                } else {
                    encodedValue = "\(element.value)"
                }
                
                return "\(element.key)=\(encodedValue)"
            }
            .joined(separator: "&")
    }
}

extension Request {
    static func jsonRequest<T: Codable>(_ urlString: String, parameters: [String: Any], headers: [String: String]) -> Request<T> {
        return Request<T>(urlString: urlString, parameters: parameters, headers: headers, mapper: { data in
            let jsonDecoder = JSONDecoder()
            jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
            return try jsonDecoder.decode(T.self, from: data)
        })
    }
}

extension Request: CustomDebugStringConvertible {
    var debugDescription: String {
        return [
            "method: \(method)",
            "parameters: \(parameters)",
            "headers: \(headers)"
        ].joined(separator: "\n")
    }
}
