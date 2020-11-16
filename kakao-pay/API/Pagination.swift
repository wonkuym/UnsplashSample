//
//  Pagination.swift
//  kakao-pay
//
//  Created by wonkyum kim on 2020/11/17.
//

import Foundation

struct Pagination {
    let page: Int
    let perPage: Int
    let parameters: [String: Any]
    
    static func firstPage(parameters: [String: Any] = [:]) -> Pagination {
        return Pagination(page: 1, perPage: 10, parameters: parameters)
    }
    
    func nextPage() -> Pagination {
        return Pagination(page: page + 1, perPage: perPage, parameters: parameters)
    }
    
    func toAllParameters() -> [String: Any] {
        var results: [String: Any] = [:]
        results["page"] = page
        results["per_page"] = perPage
        parameters.forEach { results[$0.key] = $0.value }
        return results
    }
}
