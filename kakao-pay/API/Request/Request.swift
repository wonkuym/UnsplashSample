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

class Request {
    
    enum HTTPMethod: String {
        case get
    }
    
    let urlString: String
    
    var urlStringWithQuery: String {
        return "\(urlString)?\(getQueryString())"
    }
    
    private let method: HTTPMethod = .get
    private let parameters: [String: Any]
    private let headers: [String: String]
    private var pendingTask: URLSessionDataTask?
    private var isExecute: Bool {
        return pendingTask != nil
    }
    
    init(urlString: String, parameters: [String: Any] = [:], headers: [String: String] = [:]) {
        self.urlString = urlString
        self.parameters = parameters
        self.headers = headers
    }
    
    func execute(
        completion: @escaping (Data) -> Void = { _ in /* do nothing */ },
        failure: @escaping (Error) -> Void = { _ in /* do nothing */ },
        finally: @escaping () -> Void = { /* do nothing */ }
    ) {
        _execute(completion: completion, failure: failure, finally: finally)
    }
    
    private func _execute(completion: @escaping (Data) -> Void, failure: @escaping (Error) -> Void, finally: @escaping () -> Void) {
        let wrapedFinally = { [weak self] in
            self?.pendingTask = nil
            finally()
        }
        
        let completionOnMain: (Data) -> Void = { data in
            DispatchQueue.main.async {
                completion(data)
                wrapedFinally()
            }
        }
        
        let failureOnMain: (Error) -> Void = { error in
            DispatchQueue.main.async {
                failure(error)
                wrapedFinally()
            }
        }
        
        guard let urlRequest = makeURLRequest() else {
            failureOnMain(RequestError.invalidURL(urlString: urlString))
            return
        }
        
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            guard let data = data, let response = response as? HTTPURLResponse else {
                failureOnMain(error ?? RequestError.unknown)
                return
            }
            
            guard 200..<300 ~= response.statusCode else {
                failureOnMain(RequestError.requestFailed(response: response, data: data))
                return
            }
            
            completionOnMain(data)
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

extension Request: CustomDebugStringConvertible {
    var debugDescription: String {
        return [
            "method: \(method)",
            "parameters: \(parameters)",
            "headers: \(headers)"
        ].joined(separator: "\n")
    }
}
