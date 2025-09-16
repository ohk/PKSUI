//
//  PKSImageTests.swift
//  PKSUITests
//
//  Created by Omer Hamid Kamisli on 9/12/25.
//

import XCTest
import SwiftUI
@testable import PKSUI

@MainActor
final class PKSImageTests: XCTestCase {
    
    func testPKSImagePriority() {
        // Test static properties
        XCTAssertEqual(PKSImagePriority.veryLow.rawValue, 0)
        XCTAssertEqual(PKSImagePriority.low.rawValue, 250)
        XCTAssertEqual(PKSImagePriority.normal.rawValue, 500)
        XCTAssertEqual(PKSImagePriority.high.rawValue, 750)
        XCTAssertEqual(PKSImagePriority.veryHigh.rawValue, 1000)
        
        // Test custom priorities
        let customPriority = PKSImagePriority(rawValue: 600)
        XCTAssertEqual(customPriority.rawValue, 600)
        
        // Test clamping for out-of-range values
        let tooLow = PKSImagePriority(rawValue: -100)
        XCTAssertEqual(tooLow.rawValue, 0)
        
        let tooHigh = PKSImagePriority(rawValue: 2000)
        XCTAssertEqual(tooHigh.rawValue, 1000)
        
        // Test Comparable
        XCTAssertTrue(PKSImagePriority.low < PKSImagePriority.high)
        XCTAssertTrue(PKSImagePriority.normal > PKSImagePriority.veryLow)
    }
    
    func testPKSImageProgress() {
        let progress1 = PKSImageProgress(totalBytes: 1024, downloadedBytes: 512, isFromCache: false)
        XCTAssertEqual(progress1.fractionCompleted, 0.5)
        XCTAssertEqual(progress1.totalKB, 1.0)
        XCTAssertEqual(progress1.downloadedKB, 0.5)
        
        let progress2 = PKSImageProgress(totalBytes: nil, downloadedBytes: 2048, isFromCache: true)
        XCTAssertEqual(progress2.fractionCompleted, 0.0)
        XCTAssertNil(progress2.totalKB)
        XCTAssertEqual(progress2.downloadedKB, 2.0)
        XCTAssertTrue(progress2.isFromCache)
    }
    
    func testPKSImageStatus() {
        let loadingStatus = PKSImageStatus.loading(PKSImageProgress(totalBytes: 100, downloadedBytes: 50))
        XCTAssertTrue(loadingStatus.isLoading)
        XCTAssertFalse(loadingStatus.isFinal)
        XCTAssertNotNil(loadingStatus.progress)
        XCTAssertEqual(loadingStatus.progress?.fractionCompleted, 0.5)
        
        let successStatus = PKSImageStatus.success
        XCTAssertFalse(successStatus.isLoading)
        XCTAssertTrue(successStatus.isFinal)
        XCTAssertNil(successStatus.progress)
        
        let error = NSError(domain: "test", code: 1, userInfo: nil)
        let failureStatus = PKSImageStatus.failure(error)
        XCTAssertFalse(failureStatus.isLoading)
        XCTAssertTrue(failureStatus.isFinal)
        XCTAssertNotNil(failureStatus.error)
    }
    
    func testPKSImagePrefetch() {
        // Test single URL prefetch - just verify it doesn't crash
        let url = URL(string: "https://example.com/test.jpg")
        PKSImageManager.prefetch(url: url, priority: .high)
        
        // Test multiple URLs prefetch
        let urls = [
            URL(string: "https://example.com/1.jpg"),
            URL(string: "https://example.com/2.jpg"),
            URL(string: "https://example.com/3.jpg")
        ].compactMap { $0 }
        
        PKSImageManager.prefetch(urls: urls, priority: .low)
        
        // Test cancel prefetch
        PKSImageManager.cancelPrefetch(url: url)
        PKSImageManager.cancelPrefetch(urls: urls)
        
        // Test cancel all prefetches
        PKSImageManager.cancelAllPrefetches()
        
        // Test with nil URL (should not crash)
        PKSImageManager.prefetch(url: nil)
        PKSImageManager.cancelPrefetch(url: nil)
        
        // Test with empty array (should not crash)
        PKSImageManager.prefetch(urls: [], priority: .normal)
        PKSImageManager.cancelPrefetch(urls: [])
    }
}
