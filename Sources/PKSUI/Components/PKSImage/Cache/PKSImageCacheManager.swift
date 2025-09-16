//
//  PKSImageCacheManager.swift
//  PKSUI
//
//  Created on 9/14/25.
//

import Foundation
import Nuke

/// Manages image caching for PKSImage components.
///
/// This class provides a centralized way to configure and manage image caching
/// throughout your application with full control over caching behavior.
///
/// Example:
/// ```swift
/// // Set a global cache configuration
/// PKSImageCacheManager.shared.configure(with: .aggressive)
///
/// // Clear all caches
/// PKSImageCacheManager.shared.clearAll()
///
/// // Get cache statistics
/// let stats = PKSImageCacheManager.shared.statistics
/// ```
@MainActor
public final class PKSImageCacheManager {

    /// The shared cache manager instance.
    public static let shared = PKSImageCacheManager()

    /// The current cache configuration.
    public private(set) var configuration: PKSImageCacheConfiguration

    /// The underlying image pipeline.
    /// - Important: This property uses `nonisolated(unsafe)` for performance reasons.
    ///   The pipeline is only modified during configuration (which is MainActor-isolated)
    ///   and all reads after initialization are safe as ImagePipeline is thread-safe.
    ///   The singleton pattern ensures there's only one instance managing this pipeline.
    private nonisolated(unsafe) var pipeline: ImagePipeline

    /// Private initializer to ensure singleton.
    private init() {
        self.configuration = .default
        self.pipeline = ImagePipeline.shared
    }

    /// Configures the cache manager with the specified configuration.
    ///
    /// This method creates a new image pipeline with the specified caching settings.
    /// Changes take effect immediately for all new image loads.
    ///
    /// - Parameter configuration: The cache configuration to apply.
    public func configure(with configuration: PKSImageCacheConfiguration) {
        self.configuration = configuration
        self.pipeline = createPipeline(with: configuration)
    }

    /// Creates an image pipeline with the specified configuration.
    private func createPipeline(with config: PKSImageCacheConfiguration) -> ImagePipeline {
        var pipelineConfig = ImagePipeline.Configuration()

        // Configure memory cache
        if config.memoryCache.isEnabled {
            let imageCache = ImageCache()

            if let costLimit = config.memoryCache.costLimit {
                imageCache.costLimit = costLimit
            }

            if let countLimit = config.memoryCache.countLimit {
                imageCache.countLimit = countLimit
            }

            if let ttl = config.memoryCache.ttl {
                imageCache.ttl = ttl
            }

            imageCache.entryCostLimit = config.memoryCache.entryCostLimit

            pipelineConfig.imageCache = imageCache
        } else {
            pipelineConfig.imageCache = nil
        }

        // Configure disk cache
        if config.diskCache.isEnabled {
            let dataCache: DataCache?

            switch config.diskCache.directory {
            case .caches:
                dataCache = try? DataCache(name: "com.pksui.imagecache")
            case .custom(let name):
                dataCache = try? DataCache(name: name)
            case .url(let url):
                dataCache = try? DataCache(path: url)
            }

            if let cache = dataCache {
                cache.sizeLimit = config.diskCache.sizeLimit
                cache.sweepInterval = config.diskCache.sweepInterval
                pipelineConfig.dataCache = cache
            }
        } else {
            pipelineConfig.dataCache = nil
        }

        // Configure cache policy
        switch config.policy {
        case .automatic:
            pipelineConfig.dataCachePolicy = .automatic
        case .memoryOnly:
            pipelineConfig.dataCache = nil
        case .diskOnly:
            pipelineConfig.imageCache = nil
        case .all:
            pipelineConfig.dataCachePolicy = .storeAll
        case .storeOriginalData:
            pipelineConfig.dataCachePolicy = .storeOriginalData
        case .storeDecodedImages:
            pipelineConfig.dataCachePolicy = .storeEncodedImages
        case .storeAll:
            pipelineConfig.dataCachePolicy = .storeAll
        case .none:
            pipelineConfig.imageCache = nil
            pipelineConfig.dataCache = nil
        }

        // Configure additional options
        pipelineConfig.isProgressiveDecodingEnabled = config.isProgressiveDecodingEnabled
        pipelineConfig.isStoringPreviewsInMemoryCache = config.isStoringPreviewsInMemoryCache
        pipelineConfig.isResumableDataEnabled = config.isResumableDataEnabled

        return ImagePipeline(configuration: pipelineConfig)
    }

    /// Returns the current image pipeline configured for caching.
    internal nonisolated var imagePipeline: ImagePipeline {
        return self.pipeline
    }

    /// Clears all cached images from memory.
    public func clearMemoryCache() {
        pipeline.cache.removeAll()
    }

    /// Clears all cached images from disk.
    public func clearDiskCache() {
        if let dataCache = pipeline.configuration.dataCache as? DataCache {
            dataCache.removeAll()
        }
    }

    /// Clears all cached images from both memory and disk.
    public func clearAll() {
        clearMemoryCache()
        clearDiskCache()
    }

    /// Removes a specific image from the memory cache.
    ///
    /// - Parameter url: The URL of the image to remove.
    /// - Note: Selective removal from disk cache is not supported due to limitations in the public API.
    public func removeImage(for url: URL) {
        let request = ImageRequest(url: url)
        pipeline.cache.removeCachedImage(for: request)
        // Disk cache does not support selective removal via public API.
    }

    /// Cache statistics providing insight into cache usage.
    public var statistics: CacheStatistics {
        let imageCache = pipeline.configuration.imageCache as? ImageCache
        let dataCache = pipeline.configuration.dataCache as? DataCache

        return CacheStatistics(
            memoryCacheTotalCost: imageCache?.totalCost ?? 0,
            memoryCacheTotalCount: imageCache?.totalCount ?? 0,
            memoryCacheCostLimit: imageCache?.costLimit ?? 0,
            memoryCacheCountLimit: imageCache?.countLimit ?? 0,
            diskCacheSizeLimit: dataCache?.sizeLimit ?? 0,
            diskCacheTotalSize: dataCache?.totalSize ?? 0,
            diskCacheTotalCount: dataCache?.totalCount ?? 0,
            isDiskCacheEnabled: dataCache != nil,
            isMemoryCacheEnabled: configuration.memoryCache.isEnabled
        )
    }

    /// Statistics about cache usage.
    public struct CacheStatistics {
        /// Total cost of items in memory cache.
        public let memoryCacheTotalCost: Int

        /// Total number of items in memory cache.
        public let memoryCacheTotalCount: Int

        /// Memory cache cost limit.
        public let memoryCacheCostLimit: Int

        /// Memory cache count limit.
        public let memoryCacheCountLimit: Int

        /// Disk cache size limit in bytes.
        public let diskCacheSizeLimit: Int

        /// Current total size of items in disk cache in bytes.
        public let diskCacheTotalSize: Int

        /// Total number of items in disk cache.
        public let diskCacheTotalCount: Int

        /// Whether disk cache is enabled.
        public let isDiskCacheEnabled: Bool

        /// Whether memory cache is enabled.
        public let isMemoryCacheEnabled: Bool
    }
}

