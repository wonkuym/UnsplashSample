//
//  RecentSearchQueryTests.swift
//  UnsplashSampleTests
//
//  Created by wonkyum kim on 2020/11/22.
//

import XCTest

class RecentSearchQueryTests: XCTestCase {

    override func setUpWithError() throws {
        RecentSearchQuery.shared.removeAll()
    }

    func testExample() throws {
        RecentSearchQuery.shared.limitCount = 3
        
        XCTAssertEqual(RecentSearchQuery.shared.recentQueries, [])
        
        RecentSearchQuery.shared.addQeury("1")
        XCTAssertEqual(RecentSearchQuery.shared.recentQueries, ["1"])
        
        RecentSearchQuery.shared.addQeury("2")
        XCTAssertEqual(RecentSearchQuery.shared.recentQueries, ["2", "1"])
        
        RecentSearchQuery.shared.addQeury("3")
        XCTAssertEqual(RecentSearchQuery.shared.recentQueries, ["3", "2", "1"])
        
        RecentSearchQuery.shared.addQeury("4")
        XCTAssertEqual(RecentSearchQuery.shared.recentQueries, ["4", "3", "2"])
        
        RecentSearchQuery.shared.addQeury("2")
        XCTAssertEqual(RecentSearchQuery.shared.recentQueries, ["2", "4", "3"])
    }
}
