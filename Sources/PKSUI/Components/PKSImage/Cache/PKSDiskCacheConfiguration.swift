//
//  PKSDiskCacheConfiguration.swift
//  PKSUI
//
//  Created on 9/14/25.
//

import Foundation

/// Configuration options for disk-based image caching.
///
/// Use this struct to customize how images are cached on disk. Disk caching
/// provides persistent storage that survives app restarts and memory pressure.
///
/// Example:
/// ```swift
/// let config = PKSDiskCacheConfiguration(
///     sizeLimit: 200_000_000, // 200 MB
///     expiration: .days(7),
///     directory: .caches
/// )
/// ```
public struct PKSDiskCacheConfiguration: Sendable {

    /// The maximum size of the disk cache in bytes.
    ///
    /// When the cache exceeds this limit, it removes the least recently used items.
    /// Default is 150 MB.
    public var sizeLimit: Int

    /// Cache expiration policy.
    public var expiration: Expiration

    /// The directory where cache files are stored.
    public var directory: Directory

    /// Whether disk caching is enabled.
    ///
    /// Set to `false` to disable disk caching entirely.
    public var isEnabled: Bool

    /// The time interval between cache sweeps in seconds.
    ///
    /// The cache periodically removes expired items. Default is 1 hour (3600 seconds).
    public var sweepInterval: TimeInterval

    /// Creates a disk cache configuration with the specified options.
    ///
    /// - Parameters:
    ///   - sizeLimit: Maximum cache size in bytes. Default is 150 MB.
    ///   - expiration: When cached items expire. Default is 7 days.
    ///   - directory: Where to store cache files. Default is .caches.
    ///   - isEnabled: Whether disk caching is enabled. Default is true.
    ///   - sweepInterval: Time between cache sweeps in seconds. Default is 3600 (1 hour).
    public init(
        sizeLimit: Int = 150 * 1024 * 1024,
        expiration: Expiration = .days(7),
        directory: Directory = .caches,
        isEnabled: Bool = true,
        sweepInterval: TimeInterval = 3600
    ) {
        self.sizeLimit = sizeLimit
        self.expiration = expiration
        self.directory = directory
        self.isEnabled = isEnabled
        self.sweepInterval = sweepInterval
    }

    /// Cache expiration policy.
    public enum Expiration: Sendable {
        /// Items never expire.
        case never

        /// Items expire after the specified number of seconds.
        case seconds(TimeInterval)

        /// Items expire after the specified number of days.
        case days(Int)

        /// Items expire on the specified date.
        case date(Date)

        /// The expiration time interval in seconds.
        public var timeInterval: TimeInterval? {
            switch self {
            case .never:
                return nil
            case .seconds(let seconds):
                return seconds
            case .days(let days):
                return TimeInterval(days * 24 * 60 * 60)
            case .date(let date):
                return date.timeIntervalSinceNow
            }
        }
    }

    /// Cache directory location.
    public enum Directory: Sendable {
        /// Store cache in the system caches directory.
        ///
        /// This is the recommended location for cache files that can be recreated.
        case caches

        /// Store cache in a custom directory with the specified name.
        ///
        /// The directory will be created inside the caches directory.
        case custom(String)

        /// Store cache at a specific URL.
        ///
        /// You are responsible for ensuring the directory exists and is writable.
        case url(URL)
    }

    /// Default disk cache configuration.
    ///
    /// Uses 150 MB size limit, 7-day expiration, and system caches directory.
    public static let `default` = PKSDiskCacheConfiguration()

    /// Aggressive disk cache configuration.
    ///
    /// Uses larger size limit and longer expiration for better performance.
    public static let aggressive = PKSDiskCacheConfiguration(
        sizeLimit: 500 * 1024 * 1024, // 500 MB
        expiration: .days(30),
        sweepInterval: 7200 // 2 hours
    )

    /// Conservative disk cache configuration.
    ///
    /// Uses smaller size limit and shorter expiration to minimize disk usage.
    public static let conservative = PKSDiskCacheConfiguration(
        sizeLimit: 50 * 1024 * 1024, // 50 MB
        expiration: .days(3),
        sweepInterval: 1800 // 30 minutes
    )

    /// Disabled disk cache configuration.
    ///
    /// Completely disables disk caching.
    public static let disabled = PKSDiskCacheConfiguration(isEnabled: false)
}