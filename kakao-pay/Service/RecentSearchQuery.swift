//
//  RecentSearchQuery.swift
//  kakao-pay
//
//  Created by wonkyum kim on 2020/11/21.
//

import Foundation

private let limitCount: Int = 7
private let userDefaultsKey = "RecentSearchQuery"

class RecentSearchQuery {
    static let shared = RecentSearchQuery()
    
    var recentQueries: [String] {
        return UserDefaults.standard.stringArray(forKey: userDefaultsKey) ?? []
    }
    
    func addQeury(_ newQuery: String) {
        var queries = recentQueries
        queries.removeAll { $0 == newQuery } // 이전에 동일한 쿼리 삭제
        queries.insert(newQuery, at: 0)
        UserDefaults.standard.setValue(Array(queries.prefix(limitCount)), forKey: userDefaultsKey)
    }
    
    func removeAll() {
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }
}
