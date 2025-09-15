//
//  PKSMemoryCacheConfiguration.swift
//  PKSUI
//
//  Created on 9/14/25.
//

import Foundation

/// Configuration options for in-memory image caching.
///
/// Use this struct to customize how images are cached in memory. The memory cache
/// provides fast access to recently used images without requiring disk I/O.
///
/// Example:
/// ```swift
/// let config = PKSMemoryCacheConfiguration(
///     costLimit: 100_000_000, // 100 MB
///     countLimit: 100,
///     ttl: 300 // 5 minutes
/// )
/// ```
public struct PKSMemoryCacheConfiguration: Sendable {

    /// The maximum total cost that the cache can hold in bytes.
    ///
    /// When the cache exceeds this limit, it removes the least recently used items.
    /// If `nil`, uses a default value based on the device's available memory.
    public var costLimit: Int?

    /// The maximum number of items that the cache can hold.
    ///
    /// When the cache exceeds this limit, it removes the least recently used items.
    /// If `nil`, no count limit is applied.
    public var countLimit: Int?

    /// Time to live (TTL) for cached items in seconds.
    ///
    /// Items older than this duration are automatically removed from the cache.
    /// If `nil`, items never expire based on time.
    public var ttl: TimeInterval?

    /// The maximum cost of a single entry as a proportion of the total cost limit.
    ///
    /// Values should be between 0.0 and 1.0. For example, 0.1 means a single entry
    /// can be at most 10% of the total cache size. Default is 0.1.
    public var entryCostLimit: Double

    /// Whether the memory cache is enabled.
    ///
    /// Set to `false` to disable memory caching entirely.
    public var isEnabled: Bool

    /// Creates a memory cache configuration with the specified options.
    ///
    /// - Parameters:
    ///   - costLimit: Maximum total cost in bytes. If nil, uses device-based default.
    ///   - countLimit: Maximum number of items. If nil, no count limit.
    ///   - ttl: Time to live in seconds. If nil, items never expire.
    ///   - entryCostLimit: Maximum single entry cost as proportion of total. Default is 0.1.
    ///   - isEnabled: Whether memory caching is enabled. Default is true.
    public init(
        costLimit: Int? = nil,
        countLimit: Int? = nil,
        ttl: TimeInterval? = nil,
        entryCostLimit: Double = 0.1,
        isEnabled: Bool = true
    ) {
        self.costLimit = costLimit
        self.countLimit = countLimit
        self.ttl = ttl
        self.entryCostLimit = entryCostLimit
        self.isEnabled = isEnabled
    }

    /// Default memory cache configuration.
    ///
    /// Uses automatic cost limit based on device memory, no count limit,
    /// no TTL, and 10% entry cost limit.
    public static let `default` = PKSMemoryCacheConfiguration()

    /// Aggressive memory cache configuration.
    ///
    /// Uses a higher cost limit and count limit for better performance
    /// at the expense of memory usage.
    public static let aggressive = PKSMemoryCacheConfiguration(
        costLimit: 500_000_000, // 500 MB
        countLimit: 1000,
        ttl: nil,
        entryCostLimit: 0.2
    )

    /// Conservative memory cache configuration.
    ///
    /// Uses lower limits to minimize memory usage.
    public static let conservative = PKSMemoryCacheConfiguration(
        costLimit: 50_000_000, // 50 MB
        countLimit: 50,
        ttl: 300, // 5 minutes
        entryCostLimit: 0.05
    )

    /// Disabled memory cache configuration.
    ///
    /// Completely disables memory caching.
    public static let disabled = PKSMemoryCacheConfiguration(isEnabled: false)
}