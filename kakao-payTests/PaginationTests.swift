//
//  PaginationTests.swift
//  kakao-payTests
//
//  Created by wonkyum kim on 2020/11/17.
//

import XCTest

class PaginationTests: XCTestCase {
    
    func testPagenation() throws {
        let firstPage = Pagination.firstPage()
        XCTAssertEqual(1, firstPage.page)
        
        let nextPage = firstPage.nextPage()
        XCTAssertEqual(2, nextPage.page)
    }
}
