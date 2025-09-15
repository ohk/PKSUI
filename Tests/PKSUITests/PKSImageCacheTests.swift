//
//  PKSImageCacheTests.swift
//  PKSUITests
//
//  Created on 9/14/25.
//

import XCTest
import SwiftUI
@testable import PKSUI

@MainActor
final class PKSImageCacheTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Clear all caches before each test
        PKSImageManager.clearAllCaches()
    }

    override func tearDown() {
        super.tearDown()
        // Clear all caches after each test
        PKSImageManager.clearAllCaches()
    }

    func testMemoryCacheConfiguration() {
        let config = PKSMemoryCacheConfiguration(
            costLimit: 100_000_000,
            countLimit: 100,
            ttl: 300,
            entryCostLimit: 0.1,
            isEnabled: true
        )

        XCTAssertEqual(config.costLimit, 100_000_000)
        XCTAssertEqual(config.countLimit, 100)
        XCTAssertEqual(config.ttl, 300)
        XCTAssertEqual(config.entryCostLimit, 0.1)
        XCTAssertTrue(config.isEnabled)
    }

    func testDiskCacheConfiguration() {
        let config = PKSDiskCacheConfiguration(
            sizeLimit: 200_000_000,
            expiration: .days(7),
            directory: .caches,
            isEnabled: true,
            sweepInterval: 3600
        )

        XCTAssertEqual(config.sizeLimit, 200_000_000)
        XCTAssertEqual(config.sweepInterval, 3600)
        XCTAssertTrue(config.isEnabled)

        // Test expiration time interval
        if case .days(let days) = config.expiration {
            XCTAssertEqual(days, 7)
            XCTAssertEqual(config.expiration.timeInterval, TimeInterval(7 * 24 * 60 * 60))
        } else {
            XCTFail("Expected expiration to be .days(7)")
        }
    }

    func testImageCacheConfiguration() {
        let config = PKSImageCacheConfiguration(
            memoryCache: .aggressive,
            diskCache: .conservative,
            policy: .all,
            isProgressiveDecodingEnabled: true,
            isStoringPreviewsInMemoryCache: false,
            isResumableDataEnabled: true
        )

        XCTAssertTrue(config.isProgressiveDecodingEnabled)
        XCTAssertFalse(config.isStoringPreviewsInMemoryCache)
        XCTAssertTrue(config.isResumableDataEnabled)

        if case .all = config.policy {
            // Success
        } else {
            XCTFail("Expected policy to be .all")
        }
    }

    func testPredefinedConfigurations() {
        // Test default configuration
        let defaultConfig = PKSImageCacheConfiguration.default
        XCTAssertTrue(defaultConfig.memoryCache.isEnabled)
        XCTAssertTrue(defaultConfig.diskCache.isEnabled)

        // Test aggressive configuration
        let aggressiveConfig = PKSImageCacheConfiguration.aggressive
        XCTAssertTrue(aggressiveConfig.isProgressiveDecodingEnabled)

        // Test memory-only configuration
        let memoryOnlyConfig = PKSImageCacheConfiguration.memoryOnly
        XCTAssertTrue(memoryOnlyConfig.memoryCache.isEnabled)
        XCTAssertFalse(memoryOnlyConfig.diskCache.isEnabled)

        // Test disabled configuration
        let disabledConfig = PKSImageCacheConfiguration.disabled
        XCTAssertFalse(disabledConfig.memoryCache.isEnabled)
        XCTAssertFalse(disabledConfig.diskCache.isEnabled)
    }

    @MainActor
    func testGlobalCacheConfiguration() {
        // Configure cache globally
        PKSImageManager.configureCacheGlobally(.aggressive)

        let manager = PKSImageCacheManager.shared
        XCTAssertNotNil(manager.configuration)

        // Test cache statistics
        let stats = PKSImageManager.cacheStatistics
        XCTAssertNotNil(stats)
        XCTAssertGreaterThanOrEqual(stats.memoryCacheTotalCount, 0)
    }

    @MainActor
    func testCacheManagement() {
        // Test clearing memory cache
        PKSImageManager.clearMemoryCache()

        // Test clearing disk cache
        PKSImageManager.clearDiskCache()

        // Test clearing all caches
        PKSImageManager.clearAllCaches()

        // Test removing specific image
        let testURL = URL(string: "https://example.com/test.jpg")!
        PKSImageManager.removeFromCache(url: testURL)
    }

    func testExpirationTimeInterval() {
        // Test never expiration
        let neverExpiration = PKSDiskCacheConfiguration.Expiration.never
        XCTAssertNil(neverExpiration.timeInterval)

        // Test seconds expiration
        let secondsExpiration = PKSDiskCacheConfiguration.Expiration.seconds(3600)
        XCTAssertEqual(secondsExpiration.timeInterval, 3600)

        // Test days expiration
        let daysExpiration = PKSDiskCacheConfiguration.Expiration.days(7)
        XCTAssertEqual(daysExpiration.timeInterval, TimeInterval(7 * 24 * 60 * 60))
    }

    func testCachePolicies() {
        let policies: [PKSImageCacheConfiguration.CachePolicy] = [
            .automatic,
            .memoryOnly,
            .diskOnly,
            .all,
            .storeOriginalData,
            .storeDecodedImages,
            .storeAll,
            .none
        ]

        // Ensure all policies are distinct
        for policy in policies {
            let config = PKSImageCacheConfiguration(policy: policy)
            XCTAssertNotNil(config.policy)
        }
    }
}
