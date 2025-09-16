//
//  PKSImageCacheConfiguration.swift
//  PKSUI
//
//  Created on 9/14/25.
//

import Foundation

/// Configuration for image caching behavior.
///
/// This struct provides a unified interface for configuring both memory and disk
/// caching strategies for PKSImage, providing full control over caching behavior
/// through a clean API.
///
/// Example:
/// ```swift
/// // Use a preset configuration
/// let config = PKSImageCacheConfiguration.aggressive
///
/// // Or create a custom configuration
/// let customConfig = PKSImageCacheConfiguration(
///     memoryCache: .conservative,
///     diskCache: .aggressive,
///     policy: .automatic
/// )
/// ```
public struct PKSImageCacheConfiguration: Sendable {

    /// Memory cache configuration.
    public var memoryCache: PKSMemoryCacheConfiguration

    /// Disk cache configuration.
    public var diskCache: PKSDiskCacheConfiguration

    /// Cache policy determines when and how images are cached.
    public var policy: CachePolicy

    /// Whether to enable progressive image loading.
    ///
    /// When enabled, partial images are displayed as they download.
    public var isProgressiveDecodingEnabled: Bool

    /// Whether to store preview images in memory cache.
    ///
    /// Applies when progressive decoding is enabled.
    public var isStoringPreviewsInMemoryCache: Bool

    /// Whether to enable resumable downloads.
    ///
    /// When enabled, interrupted downloads can resume from where they left off.
    public var isResumableDataEnabled: Bool

    /// Creates a cache configuration with the specified options.
    ///
    /// - Parameters:
    ///   - memoryCache: Memory cache configuration. Default is `.default`.
    ///   - diskCache: Disk cache configuration. Default is `.default`.
    ///   - policy: Caching policy. Default is `.automatic`.
    ///   - isProgressiveDecodingEnabled: Enable progressive decoding. Default is false.
    ///   - isStoringPreviewsInMemoryCache: Store previews in memory. Default is true.
    ///   - isResumableDataEnabled: Enable resumable downloads. Default is true.
    public init(
        memoryCache: PKSMemoryCacheConfiguration = .default,
        diskCache: PKSDiskCacheConfiguration = .default,
        policy: CachePolicy = .automatic,
        isProgressiveDecodingEnabled: Bool = false,
        isStoringPreviewsInMemoryCache: Bool = true,
        isResumableDataEnabled: Bool = true
    ) {
        self.memoryCache = memoryCache
        self.diskCache = diskCache
        self.policy = policy
        self.isProgressiveDecodingEnabled = isProgressiveDecodingEnabled
        self.isStoringPreviewsInMemoryCache = isStoringPreviewsInMemoryCache
        self.isResumableDataEnabled = isResumableDataEnabled
    }

    /// Cache policy determines when and how images are cached.
    public enum CachePolicy: Sendable {
        /// Automatically determine the best caching strategy.
        ///
        /// Uses memory cache for small images and both memory and disk for larger ones.
        case automatic

        /// Only use memory cache, no disk persistence.
        case memoryOnly

        /// Only use disk cache, no memory cache.
        case diskOnly

        /// Use both memory and disk cache.
        case all

        /// Store only the original downloaded data.
        case storeOriginalData

        /// Store only the processed/decoded images.
        case storeDecodedImages

        /// Store both original data and decoded images.
        case storeAll

        /// Don't cache anything.
        case none
    }

    /// Default cache configuration.
    ///
    /// Balanced configuration suitable for most apps.
    public static let `default` = PKSImageCacheConfiguration()

    /// Aggressive cache configuration.
    ///
    /// Maximizes caching for best performance at the expense of storage.
    public static let aggressive = PKSImageCacheConfiguration(
        memoryCache: .aggressive,
        diskCache: .aggressive,
        policy: .storeAll,
        isProgressiveDecodingEnabled: true
    )

    /// Conservative cache configuration.
    ///
    /// Minimizes storage usage while still providing some caching benefits.
    public static let conservative = PKSImageCacheConfiguration(
        memoryCache: .conservative,
        diskCache: .conservative,
        policy: .automatic
    )

    /// Performance-optimized configuration.
    ///
    /// Focuses on speed with aggressive memory caching and progressive loading.
    public static let performance = PKSImageCacheConfiguration(
        memoryCache: .aggressive,
        diskCache: .default,
        policy: .all,
        isProgressiveDecodingEnabled: true,
        isStoringPreviewsInMemoryCache: true
    )

    /// Memory-only cache configuration.
    ///
    /// No disk persistence, suitable for temporary or sensitive images.
    public static let memoryOnly = PKSImageCacheConfiguration(
        memoryCache: .default,
        diskCache: .disabled,
        policy: .memoryOnly
    )

    /// Disk-only cache configuration.
    ///
    /// No memory cache, suitable for large images or memory-constrained scenarios.
    public static let diskOnly = PKSImageCacheConfiguration(
        memoryCache: .disabled,
        diskCache: .default,
        policy: .diskOnly
    )

    /// Disabled cache configuration.
    ///
    /// No caching at all, images are always downloaded fresh.
    public static let disabled = PKSImageCacheConfiguration(
        memoryCache: .disabled,
        diskCache: .disabled,
        policy: .none
    )
}