//
//  PhotosLoaderTests.swift
//  kakao-payTests
//
//  Created by wonkyum kim on 2020/11/22.
//

import XCTest

class PhotosLoaderTests: XCTestCase {
    
    let timeout = 10.0
    
    func testShouldGetPhotos() throws {
        let photosLoader = PhotosLoader()
        
        let expectation1 = self.expectation(description: "get first page photos")
        var firstPageResult: Result<[UnsplashPhoto], Error>?
        
        photosLoader.loadNext { result in
            firstPageResult = result
            expectation1.fulfill()
        }
        waitForExpectations(timeout: timeout, handler: nil)
        
        let expectation2 = self.expectation(description: "get second page photos")
        var secondPageResult: Result<[UnsplashPhoto], Error>?
        
        photosLoader.loadNext { result in
            secondPageResult = result
            expectation2.fulfill()
        }
        waitForExpectations(timeout: timeout, handler: nil)
        
        XCTAssertNotNil(firstPageResult)
        XCTAssertNotNil(secondPageResult)
        
        let firstPagePhotos = try firstPageResult?.get()
        let secondPagePhotos = try secondPageResult?.get()
        
        XCTAssertEqual(firstPagePhotos?.count ?? 0, 10)
        XCTAssertEqual(secondPagePhotos?.count ?? 0, 10)
        
        var allPhotos: [UnsplashPhoto] = []
        allPhotos.append(contentsOf: firstPagePhotos!)
        allPhotos.append(contentsOf: secondPagePhotos!)
        XCTAssertEqual(allPhotos, photosLoader.photos)
    }
}
