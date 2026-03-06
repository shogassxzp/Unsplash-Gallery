//
//  Unsplash_GalleryUnitTests.swift
//  Unsplash GalleryUnitTests
//
//  Created by Игнат Рогачевич on 28.02.26.
//

import XCTest
import Combine
@testable import Unsplash_Gallery

final class ImageListServiceTests: XCTestCase {
    private var sut: ImageListService!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        cancellables = []
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        
        let tokenStorage = OAuth2TokenStorage()
        tokenStorage.token = "test_token"
        let storageManager = StorageManager()
        let profileService = ProfileService(urlSession: session, tokenStorage: tokenStorage)
        
        sut = ImageListService(
            urlSession: session,
            tokenStorage: tokenStorage,
            storeManager: storageManager,
            profileService: profileService
        )
    }

    override func tearDown() {
        sut = nil
        cancellables = nil
        super.tearDown()
    }

    func testFetchPhotosSuccessfullyUpdatesPhotosArray() {
        // Given
        let photoId = "test_photo_id"
        let mockData = createMockPhotoJSON(id: photoId)
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, mockData)
        }

        let expectation = expectation(description: "Photos should be loaded via Combine")

        // When
        sut.$photos
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { photos in
                if !photos.isEmpty {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        sut.fetchPhotosNextPage()

        // Then
        wait(for: [expectation], timeout: 3.0)
        
        XCTAssertEqual(sut.photos.count, 1)
        XCTAssertEqual(sut.photos.first?.id, photoId)
        XCTAssertEqual(sut.photos.first?.likedByUser, false)
    }
}

// MARK: - Helpers
private extension ImageListServiceTests {
    func createMockPhotoJSON(id: String) -> Data {
        let jsonString = """
        [
            {
                "id": "\(id)",
                "created_at": "2026-03-01T12:00:00Z",
                "width": 100,
                "height": 100,
                "description": "test_description",
                "urls": {
                    "raw": "https://test.com", "full": "https://test.com",
                    "regular": "https://test.com", "small": "https://test.com", "thumb": "https://test.com"
                },
                "liked_by_user": false,
                "user": {
                    "id": "1", "username": "test_user", "name": "Test User",
                    "bio": "", "location": "", "total_likes": 0, "total_photos": 0, "total_collections": 0,
                    "profile_image": { "small": "", "medium": "", "large": "" }
                }
            }
        ]
        """
        return jsonString.data(using: .utf8)!
    }
}
