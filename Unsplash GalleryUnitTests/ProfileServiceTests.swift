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
    
    override func setUp() {
        super.setUp()
        sut = ProfileService.shared
        
        sut.tokenStorage.token = "test_mock_token"
    }
    
    override func tearDown() {
        sut.urlSession = .shared
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testFetchProfileSuccess() {
        // Given
        let expectedUsername = "ignat_rogachevich"
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        sut.urlSession = URLSession(configuration: config)
        
        let jsonString = """
        {
            "username": "\(expectedUsername)"
        }
        """
        let mockData = jsonString.data(using: .utf8)!
        
        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.url?.path, "/me")
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, mockData)
        }
        
        // When
        let expectation = expectation(description: "Wait for profile success")
        
        sut.fetchProfile { result in
            // Then
            switch result {
            case .success(let username):
                XCTAssertEqual(username, expectedUsername)
                XCTAssertEqual(self.sut.username, expectedUsername)
            case .failure(let error):
                XCTFail("Expected success, got error: \(error.localizedDescription)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testFetchProfileFailureServerError() {
        // Given
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        sut.urlSession = URLSession(configuration: config)
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 404,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }
        
        // When
        let expectation = expectation(description: "Wait for profile failure")
        
        sut.fetchProfile { result in
            // Then
            if case .failure = result {
                expectation.fulfill()
            } else {
                XCTFail("Expected failure for 404 status code")
            }
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
}
