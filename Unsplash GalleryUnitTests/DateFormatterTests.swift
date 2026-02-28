//
//  ProfileServiceTests.swift
//  Unsplash GalleryUnitTests
//
//  Created by Игнат Рогачевич on 28.02.26.
//

import XCTest
@testable import Unsplash_Gallery

final class DateExtensionTests: XCTestCase {
    
    func testToReadableDateSuccess() {
        // Given
        let isoDate = "2026-02-25T12:00:00Z"
        let expectedResult = "February 25, 2026"
        
        // When
        let result = isoDate.toReadableDate()
        
        // Then
        XCTAssertEqual(result, expectedResult, "Дата должна преобразовываться в формат 'Month Day, Year'")
    }
    
    func testToReadableDateWithInvalidString() {
        // Given
        let invalidDate = "это не дата"
        
        // When
        let result = invalidDate.toReadableDate()
        
        // Then
        XCTAssertNil(result, "Для некорректной строки метод должен возвращать nil")
    }
    
    func testToReadableDateNewYear() {
        let isoDate = "2025-12-31T23:59:59Z"
        let expectedResult = "December 31, 2025"
        
        let result = isoDate.toReadableDate()
        
        XCTAssertEqual(result, expectedResult)
    }
}
