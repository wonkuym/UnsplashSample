//
//  RequestTests.swift
//  kakao-payTests
//
//  Created by wonkyum kim on 2020/11/17.
//

import XCTest

class RequestTests: XCTestCase {

    func testExample() throws {
        guard let urlCompoents = URLComponents(string: "https://wwww.naver.com") else {
            print("here")
            return
        }
        print(urlCompoents)
    }

}
