//
//  JSONRequest.swift
//  kakao-pay
//
//  Created by wonkyum kim on 2020/11/17.
//

import Foundation

class JSONRequest<T: Codable> {
    
    let delegate: Request
    
    init(_ delegate: Request) {
        self.delegate = delegate
    }
    
    func execute(
        completion: @escaping (T) -> Void = { _ in /* do nothing */ },
        failure: @escaping (Error) -> Void = { _ in /* do nothing */ },
        finally: @escaping () -> Void = { /* do nothing */ }
    ) {
        delegate.execute(
            completion: { data in
                do {
                    completion(try self.decode(data))
                } catch {
                    failure(error)
                }
            },
            failure: failure,
            finally: finally)
    }
    
    private func decode(_ data: Data) throws -> T {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        return try jsonDecoder.decode(T.self, from: data)
    }
}
