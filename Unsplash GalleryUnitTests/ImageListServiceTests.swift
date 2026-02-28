//
//  Unsplash_GalleryUnitTests.swift
//  Unsplash GalleryUnitTests
//
//  Created by Игнат Рогачевич on 28.02.26.
//

import XCTest
@testable import Unsplash_Gallery

final class ImageListServiceTests: XCTestCase {
    
    func testFetchPhotosSyncsWithLikes() {
        // Given
        let sut = ImageListService.shared
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        sut.urlSession = URLSession(configuration: config)
        
        let photoId = "test_photo_id"
        let jsonString = """
        [
            {
                "id": "\(photoId)",
                "created_at": "2026-02-28T12:00:00Z",
                "width": 100,
                "height": 100,
                "description": "test",
                "urls": {
                    "raw": "https://test.com",
                    "full": "https://test.com",
                    "regular": "https://test.com",
                    "small": "https://test.com",
                    "thumb": "https://test.com"
                },
                "liked_by_user": false,
                "user": {
                    "id": "1",
                    "username": "test_user",
                    "name": "Test",
                    "bio": "",
                    "location": "",
                    "total_likes": 0,
                    "total_photos": 0,
                    "total_collections": 0,
                    "profile_image": { "small": "", "medium": "", "large": "" }
                }
            }
        ]
        """
        let mockData = jsonString.data(using: .utf8)!
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, mockData)
        }
        
        // When
        let expectation = expectation(description: "Wait for photos")
        
        sut.fetchPhotosNextPage()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
        
        // Then
        XCTAssertFalse(sut.photos.isEmpty)
        XCTAssertEqual(sut.photos.first?.id, photoId)
        
        // Clean up
        sut.urlSession = .shared
    }
}
