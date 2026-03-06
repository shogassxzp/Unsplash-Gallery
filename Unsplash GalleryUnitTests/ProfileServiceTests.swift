//
//  ProfileServiceTests.swift
//  Unsplash GalleryUnitTests
//
//  Created by Игнат Рогачевич on 28.02.26.
//

import XCTest
@testable import Unsplash_Gallery

final class ProfileServiceTests: XCTestCase {
    
    private var sut: ProfileService!
    private var tokenStorage: OAuth2TokenStorage!
    
    override func setUp() {
        super.setUp()
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        
        tokenStorage = OAuth2TokenStorage()
        tokenStorage.token = "test_mock_token"
        
        sut = ProfileService(urlSession: session, tokenStorage: tokenStorage)
    }
    
    override func tearDown() {
        sut = nil
        tokenStorage = nil
        super.tearDown()
    }
    
    func testFetchProfileSuccess() {
        // Given
        let expectedUsername = "ignat_rogachevich"
        let jsonString = """
        {
            "username": "\(expectedUsername)"
        }
        """
        let mockData = jsonString.data(using: .utf8)!
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, mockData)
        }
        
        let expectation = expectation(description: "Wait for profile success")
        
        // When
        sut.fetchProfile { result in
            // Then
            if case let .success(username) = result {
                XCTAssertEqual(username, expectedUsername)
                XCTAssertEqual(self.sut.username, expectedUsername)
            } else {
                XCTFail("Expected success, but got \(result)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3.0)
    }
    
    func testFetchProfileFailureServerError() {
        // Given
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 404,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }
        
        let expectation = expectation(description: "Wait for profile failure")
        
        // When
        sut.fetchProfile { result in
            // Then
            if case .failure = result {
                expectation.fulfill()
            } else {
                XCTFail("Expected failure for 404 status code")
            }
        }
        
        wait(for: [expectation], timeout: 3.0)
    }
}
