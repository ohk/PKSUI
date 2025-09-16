//
//  PKSImageManager+CacheManagement.swift
//  PKSUI
//
//  Created on 9/15/25.
//

import SwiftUI

// MARK: - Cache Management

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
extension PKSImageManager {

    /// Configures the global cache settings for all PKSImage instances.
    ///
    /// This affects all images loaded after this configuration is applied,
    /// unless they have their own specific cache configuration.
    ///
    /// Example:
    /// ```swift
    /// // Configure aggressive caching for the entire app
    /// PKSImageManager.configureCacheGlobally(.aggressive)
    /// ```
    ///
    /// - Parameter configuration: The cache configuration to apply globally.
    public static func configureCacheGlobally(_ configuration: PKSImageCacheConfiguration) {
        PKSImageCacheManager.shared.configure(with: configuration)
    }

    /// Clears all cached images from memory.
    ///
    /// Use this when you need to free up memory, such as when receiving
    /// a memory warning.
    ///
    /// Example:
    /// ```swift
    /// // Clear memory cache when receiving memory warning
    /// PKSImageManager.clearMemoryCache()
    /// ```
    public static func clearMemoryCache() {
        PKSImageCacheManager.shared.clearMemoryCache()
    }

    /// Clears all cached images from disk.
    ///
    /// Use this for maintenance or when you need to ensure fresh content.
    ///
    /// Example:
    /// ```swift
    /// // Clear disk cache on user logout
    /// PKSImageManager.clearDiskCache()
    /// ```
    public static func clearDiskCache() {
        PKSImageCacheManager.shared.clearDiskCache()
    }

    /// Clears all cached images from both memory and disk.
    ///
    /// Example:
    /// ```swift
    /// // Clear all caches when user requests fresh content
    /// PKSImageManager.clearAllCaches()
    /// ```
    public static func clearAllCaches() {
        PKSImageCacheManager.shared.clearAll()
    }

    /// Removes a specific image from the cache.
    ///
    /// - Parameter url: The URL of the image to remove from cache.
    ///
    /// Example:
    /// ```swift
    /// // Remove outdated profile image from cache
    /// PKSImageManager.removeFromCache(url: profileImageURL)
    /// ```
    public static func removeFromCache(url: URL) {
        PKSImageCacheManager.shared.removeImage(for: url)
    }

    /// Returns current cache statistics.
    ///
    /// Use this to monitor cache usage and performance.
    ///
    /// Example:
    /// ```swift
    /// let stats = PKSImageManager.cacheStatistics
    /// print("Memory cache: \(stats.memoryCacheTotalCount) items")
    /// print("Memory usage: \(stats.memoryCacheTotalCost) bytes")
    /// print("Disk cache: \(stats.diskCacheTotalCount) items")
    /// print("Disk usage: \(stats.diskCacheTotalSize) bytes")
    /// ```
    public static var cacheStatistics: PKSImageCacheManager.CacheStatistics {
        return PKSImageCacheManager.shared.statistics
    }
}
