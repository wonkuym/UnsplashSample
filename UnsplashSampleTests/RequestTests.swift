//
//  RequestTests.swift
//  UnsplashSampleTests
//
//  Created by wonkyum kim on 2020/11/22.
//

import XCTest

class RequestTests: XCTestCase {
    
    let timeout = 10.0

    func testShouldMakePhotosRequest() throws {
        let firstPage = Pagination.firstPage()
        let photosRequest = UnsplashAPI.shared.photos(firstPage)

        let urlRequest = photosRequest.makeURLRequest()
        
        XCTAssertNotNil(urlRequest)
        XCTAssertEqual(urlRequest?.url?.absoluteString, "https://api.unsplash.com/photos?page=1&per_page=10")
    }
    
    func testShouldExecutePhotosRequest() throws {
        let firstPage = Pagination.firstPage()
        let photosRequest = UnsplashAPI.shared.photos(firstPage)
        
        let expectation = self.expectation(description: "get photos response")
        var photosResult: Result<[UnsplashPhoto], Error>?
        
        photosRequest.execute { (result) in
            photosResult = result
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
        
        XCTAssertNotNil(photosResult)
        XCTAssertNoThrow(try photosResult?.get())
    }
    
    func testShouldMakeSearchPhotosRequest() throws {
        let firstPage = Pagination.firstPage(parameters: ["query": "foo"])
        let searchPhotosRequest = UnsplashAPI.shared.searchPhotos(firstPage)

        let urlRequest = searchPhotosRequest.makeURLRequest()
        
        XCTAssertNotNil(urlRequest)
        XCTAssertEqual(urlRequest?.url?.absoluteString, "https://api.unsplash.com/search/photos?page=1&per_page=10&query=foo")
    }
    
    func testShouldExecuteSearchPhotosRequest() throws {
        let firstPage = Pagination.firstPage(parameters: ["query": "foo"])
        let searchPhotosRequest = UnsplashAPI.shared.searchPhotos(firstPage)

        let expectation = self.expectation(description: "search photos response")
        var searchPhotosResult: Result<UnsplashSearchResults, Error>?

        searchPhotosRequest.execute { (result) in
            searchPhotosResult = result
            expectation.fulfill()
        }

        waitForExpectations(timeout: timeout, handler: nil)

        XCTAssertNotNil(searchPhotosResult)
        XCTAssertNoThrow(try searchPhotosResult?.get())
    }
}
