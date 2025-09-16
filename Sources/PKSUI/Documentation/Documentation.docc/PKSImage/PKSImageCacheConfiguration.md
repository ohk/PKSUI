# PKSImage Cache Configuration

Master the multi-tier caching system to optimize memory usage, reduce bandwidth, and deliver instant image loading.

## Overview

`PKSImageCacheConfiguration` provides comprehensive control over how images are stored and retrieved from both memory and disk caches. By fine-tuning cache settings, you can dramatically improve app performance, reduce data usage, and provide a superior user experience.

## Cache Architecture

### Three-Tier Cache System

```
┌─────────────┐
│   Memory    │  ← Fastest (microseconds)
│    Cache    │     Limited capacity
└──────┬──────┘     Cleared on memory pressure
       │
       ▼
┌─────────────┐
│    Disk     │  ← Fast (milliseconds)
│    Cache    │     Persistent across launches
└──────┬──────┘     Configurable size limits
       │
       ▼
┌─────────────┐
│   Network   │  ← Slowest (seconds)
│   Request   │     Requires internet connection
└─────────────┘     Consumes bandwidth
```

## Configuration Presets

### Built-in Configurations

```swift
// Balanced configuration for most apps
PKSImage(url: imageURL)
    .cacheConfiguration(.default)

// Maximum caching for best performance
PKSImage(url: imageURL)
    .cacheConfiguration(.aggressive)

// Minimal caching for storage-conscious apps
PKSImage(url: imageURL)
    .cacheConfiguration(.conservative)

// Speed-optimized with progressive loading
PKSImage(url: imageURL)
    .cacheConfiguration(.performance)

// Memory-only for temporary/sensitive images
PKSImage(url: imageURL)
    .cacheConfiguration(.memoryOnly)

// Disk-only for large images
PKSImage(url: imageURL)
    .cacheConfiguration(.diskOnly)

// No caching - always fetch fresh
PKSImage(url: imageURL)
    .cacheConfiguration(.disabled)
```

### Preset Comparison

| Configuration | Memory Cache | Disk Cache | Progressive | Best For |
|--------------|-------------|------------|-------------|----------|
| `.default` | Moderate | Moderate | No | General use |
| `.aggressive` | Large | Large | Yes | Image-heavy apps |
| `.conservative` | Small | Small | No | Limited storage |
| `.performance` | Large | Moderate | Yes | Speed critical |
| `.memoryOnly` | Moderate | None | No | Temporary images |
| `.diskOnly` | None | Moderate | No | Large files |
| `.disabled` | None | None | No | Dynamic content |

## Custom Configuration

### Creating Custom Cache Settings

```swift
let customConfig = PKSImageCacheConfiguration(
    memoryCache: PKSMemoryCacheConfiguration(
        costLimit: 100 * 1024 * 1024,  // 100 MB
        countLimit: 100,                // Max 100 images
        ttl: 300,                        // 5 minutes
        minimumPreCachingInterval: 1.0
    ),
    diskCache: PKSDiskCacheConfiguration(
        sizeLimit: 500 * 1024 * 1024,   // 500 MB
        ttl: 86400 * 7,                  // 7 days
        maximumSize: 1000 * 1024 * 1024 // 1 GB absolute max
    ),
    policy: .automatic,
    isProgressiveDecodingEnabled: true,
    isStoringPreviewsInMemoryCache: true,
    isResumableDataEnabled: true
)

PKSImage(url: imageURL)
    .cacheConfiguration(customConfig)
```

### Memory Cache Configuration

```swift
public struct PKSMemoryCacheConfiguration {
    /// Maximum memory cost in bytes
    public var costLimit: Int

    /// Maximum number of cached items
    public var countLimit: Int

    /// Time-to-live in seconds (nil = no expiration)
    public var ttl: TimeInterval?

    /// Minimum interval between pre-caching attempts
    public var minimumPreCachingInterval: TimeInterval
}

// Examples
extension PKSMemoryCacheConfiguration {
    // High-memory devices (iPad Pro, newer iPhones)
    static let highMemory = PKSMemoryCacheConfiguration(
        costLimit: 500 * 1024 * 1024,  // 500 MB
        countLimit: 500,
        ttl: nil,  // No expiration
        minimumPreCachingInterval: 0.5
    )

    // Low-memory devices (older iPhones, Apple Watch)
    static let lowMemory = PKSMemoryCacheConfiguration(
        costLimit: 20 * 1024 * 1024,   // 20 MB
        countLimit: 20,
        ttl: 60,   // 1 minute
        minimumPreCachingInterval: 2.0
    )

    // Temporary cache for sensitive data
    static let ephemeral = PKSMemoryCacheConfiguration(
        costLimit: 50 * 1024 * 1024,   // 50 MB
        countLimit: 50,
        ttl: 30,   // 30 seconds
        minimumPreCachingInterval: 1.0
    )
}
```

### Disk Cache Configuration

```swift
public struct PKSDiskCacheConfiguration {
    /// Maximum disk cache size in bytes
    public var sizeLimit: Int

    /// Time-to-live in seconds
    public var ttl: TimeInterval?

    /// Absolute maximum size (safety limit)
    public var maximumSize: Int

    /// Directory for cache storage
    public var directory: URL?

    /// File manager for disk operations
    public var fileManager: FileManager
}

// Examples
extension PKSDiskCacheConfiguration {
    // For apps with large image galleries
    static let largeStorage = PKSDiskCacheConfiguration(
        sizeLimit: 2 * 1024 * 1024 * 1024,    // 2 GB
        ttl: 86400 * 30,                       // 30 days
        maximumSize: 5 * 1024 * 1024 * 1024   // 5 GB max
    )

    // For apps with limited storage needs
    static let minimalStorage = PKSDiskCacheConfiguration(
        sizeLimit: 50 * 1024 * 1024,          // 50 MB
        ttl: 86400,                            // 1 day
        maximumSize: 100 * 1024 * 1024        // 100 MB max
    )

    // For offline-first apps
    static let offline = PKSDiskCacheConfiguration(
        sizeLimit: 1 * 1024 * 1024 * 1024,    // 1 GB
        ttl: nil,                              // Never expire
        maximumSize: 3 * 1024 * 1024 * 1024   // 3 GB max
    )
}
```

## Cache Policies

### Understanding Cache Policies

```swift
public enum CachePolicy {
    /// Automatically determine the best caching strategy
    case automatic

    /// Only use memory cache, no disk persistence
    case memoryOnly

    /// Only use disk cache, no memory cache
    case diskOnly

    /// Use both memory and disk cache
    case all

    /// Store only the original downloaded data
    case storeOriginalData

    /// Store only the processed/decoded images
    case storeDecodedImages

    /// Store both original data and decoded images
    case storeAll

    /// Don't cache anything
    case none
}
```

### Policy Selection Guide

```swift
struct CachePolicySelector {
    static func selectPolicy(for imageType: ImageType) -> PKSImageCacheConfiguration.CachePolicy {
        switch imageType {
        case .userAvatar:
            // Avatars change infrequently, cache aggressively
            return .storeAll

        case .productImage:
            // Product images are important, cache decoded for speed
            return .storeDecodedImages

        case .temporaryContent:
            // Temporary content shouldn't persist
            return .memoryOnly

        case .sensitiveData:
            // Sensitive data shouldn't be cached
            return .none

        case .largeImage:
            // Large images should use disk to save memory
            return .diskOnly

        case .thumbnail:
            // Small thumbnails can stay in memory
            return .memoryOnly

        default:
            // Let the system decide
            return .automatic
        }
    }
}

enum ImageType {
    case userAvatar
    case productImage
    case temporaryContent
    case sensitiveData
    case largeImage
    case thumbnail
}
```

## Global Cache Management

### Configuring Global Cache

```swift
@main
struct MyApp: App {
    init() {
        configureImageCache()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

    private func configureImageCache() {
        // Configure based on device capabilities
        let totalMemory = ProcessInfo.processInfo.physicalMemory
        let availableStorage = getAvailableStorage()

        let config: PKSImageCacheConfiguration

        if totalMemory > 4 * 1024 * 1024 * 1024 { // > 4GB RAM
            config = .aggressive
        } else if totalMemory > 2 * 1024 * 1024 * 1024 { // > 2GB RAM
            config = .default
        } else {
            config = .conservative
        }

        // Apply configuration
        PKSImageCacheManager.shared.configure(with: config)

        // Set up cache monitoring
        setupCacheMonitoring()
    }

    private func getAvailableStorage() -> Int64 {
        let documentsURL = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!

        do {
            let values = try documentsURL.resourceValues(
                forKeys: [.volumeAvailableCapacityKey]
            )
            return values.volumeAvailableCapacity ?? 0
        } catch {
            return 0
        }
    }

    private func setupCacheMonitoring() {
        // Monitor cache performance
        PKSImageCacheManager.shared.onCacheHit = { url in
            print("✅ Cache hit: \(url.lastPathComponent)")
        }

        PKSImageCacheManager.shared.onCacheMiss = { url in
            print("❌ Cache miss: \(url.lastPathComponent)")
        }
    }
}
```

### Cache Manager Operations

```swift
class CacheOperations {
    let cacheManager = PKSImageCacheManager.shared

    // Clear all caches
    func clearAllCaches() {
        cacheManager.clearMemoryCache()
        cacheManager.clearDiskCache()
    }

    // Clear memory cache only
    func clearMemoryCache() {
        cacheManager.clearMemoryCache()
    }

    // Clear disk cache only
    func clearDiskCache() {
        cacheManager.clearDiskCache()
    }

    // Remove specific image from cache
    func removeFromCache(url: URL) {
        cacheManager.removeFromCache(url: url)
    }

    // Check if image is cached
    func isCached(url: URL) -> Bool {
        return cacheManager.isCached(url: url)
    }

    // Get cache size
    func getCacheSize() -> (memory: Int, disk: Int) {
        return (
            memory: cacheManager.memoryCacheSize,
            disk: cacheManager.diskCacheSize
        )
    }

    // Trim cache to size limit
    func trimCache(toSize limit: Int) {
        cacheManager.trimCache(toSize: limit)
    }
}
```

## Advanced Caching Strategies

### Adaptive Caching

```swift
class AdaptiveCacheManager: ObservableObject {
    @Published var currentConfiguration: PKSImageCacheConfiguration = .default

    private let monitor = NWPathMonitor()
    private var memoryPressureSource: DispatchSourceMemoryPressure?

    init() {
        setupNetworkMonitoring()
        setupMemoryMonitoring()
    }

    private func setupNetworkMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.adjustCacheForNetwork(path)
            }
        }
        monitor.start(queue: .global())
    }

    private func adjustCacheForNetwork(_ path: NWPath) {
        if path.isExpensive || path.isConstrained {
            // On cellular or limited connection
            currentConfiguration = .aggressive // Cache more aggressively
        } else if path.usesInterfaceType(.wifi) {
            // On WiFi
            currentConfiguration = .default
        } else {
            // No connection
            currentConfiguration = PKSImageCacheConfiguration(
                memoryCache: .default,
                diskCache: .aggressive, // Rely heavily on disk cache
                policy: .diskOnly
            )
        }
    }

    private func setupMemoryMonitoring() {
        memoryPressureSource = DispatchSource.makeMemoryPressureSource(
            eventMask: [.warning, .critical],
            queue: .global()
        )

        memoryPressureSource?.setEventHandler { [weak self] in
            self?.handleMemoryPressure()
        }

        memoryPressureSource?.resume()
    }

    private func handleMemoryPressure() {
        DispatchQueue.main.async { [weak self] in
            // Switch to disk-only caching under memory pressure
            self?.currentConfiguration = .diskOnly

            // Clear memory cache
            PKSImageCacheManager.shared.clearMemoryCache()

            print("⚠️ Memory pressure detected, switching to disk-only cache")
        }
    }
}
```

### Content-Based Caching

```swift
struct ContentAwareCaching {
    static func configuration(for content: ContentType) -> PKSImageCacheConfiguration {
        switch content {
        case .profilePictures:
            // Profile pictures rarely change
            return PKSImageCacheConfiguration(
                memoryCache: .aggressive,
                diskCache: PKSDiskCacheConfiguration(
                    sizeLimit: 100 * 1024 * 1024,
                    ttl: 86400 * 30 // 30 days
                ),
                policy: .storeAll
            )

        case .feedImages:
            // Feed images are viewed frequently but briefly
            return PKSImageCacheConfiguration(
                memoryCache: PKSMemoryCacheConfiguration(
                    costLimit: 200 * 1024 * 1024,
                    countLimit: 100,
                    ttl: 3600 // 1 hour
                ),
                diskCache: .default,
                policy: .storeDecodedImages
            )

        case .storyImages:
            // Stories are temporary by nature
            return PKSImageCacheConfiguration(
                memoryCache: PKSMemoryCacheConfiguration(
                    costLimit: 50 * 1024 * 1024,
                    countLimit: 30,
                    ttl: 86400 // 24 hours
                ),
                diskCache: .disabled,
                policy: .memoryOnly
            )

        case .productCatalog:
            // Product images need to be fresh but load fast
            return PKSImageCacheConfiguration(
                memoryCache: .default,
                diskCache: PKSDiskCacheConfiguration(
                    sizeLimit: 500 * 1024 * 1024,
                    ttl: 3600 // 1 hour
                ),
                policy: .automatic,
                isProgressiveDecodingEnabled: true
            )

        case .maps:
            // Map tiles need extensive caching
            return PKSImageCacheConfiguration(
                memoryCache: .conservative,
                diskCache: PKSDiskCacheConfiguration(
                    sizeLimit: 1024 * 1024 * 1024, // 1 GB
                    ttl: 86400 * 7 // 7 days
                ),
                policy: .diskOnly
            )
        }
    }

    enum ContentType {
        case profilePictures
        case feedImages
        case storyImages
        case productCatalog
        case maps
    }
}
```

### Cache Warming

```swift
class CacheWarmer {
    /// Preload critical images into cache
    static func warmCache(with urls: [URL], priority: PKSImagePriority = .low) {
        // Load images in background with low priority
        for url in urls {
            PKSImageManager.prefetch(url: url, priority: priority)
        }
    }

    /// Warm cache based on user behavior
    static func predictiveWarmCache(userHistory: [URL], limit: Int = 10) {
        // Analyze patterns and preload likely next images
        let predictions = analyzePredictions(from: userHistory)
        let urlsToWarm = Array(predictions.prefix(limit))

        warmCache(with: urlsToWarm, priority: .veryLow)
    }

    private static func analyzePredictions(from history: [URL]) -> [URL] {
        // Implement prediction logic based on user patterns
        // This is a simplified example
        return history.suffix(5).reversed()
    }
}
```

## Cache Metrics and Monitoring

### Cache Performance Tracking

```swift
class CacheMetrics: ObservableObject {
    @Published var hitRate: Double = 0
    @Published var totalRequests: Int = 0
    @Published var cacheHits: Int = 0
    @Published var cacheMisses: Int = 0
    @Published var averageLoadTime: TimeInterval = 0

    private var loadTimes: [TimeInterval] = []

    func recordRequest(cached: Bool, loadTime: TimeInterval) {
        totalRequests += 1

        if cached {
            cacheHits += 1
        } else {
            cacheMisses += 1
        }

        loadTimes.append(loadTime)
        if loadTimes.count > 100 {
            loadTimes.removeFirst()
        }

        updateMetrics()
    }

    private func updateMetrics() {
        hitRate = totalRequests > 0
            ? Double(cacheHits) / Double(totalRequests)
            : 0

        averageLoadTime = loadTimes.isEmpty
            ? 0
            : loadTimes.reduce(0, +) / Double(loadTimes.count)
    }

    func generateReport() -> String {
        """
        Cache Performance Report
        ========================
        Total Requests: \(totalRequests)
        Cache Hits: \(cacheHits) (\(Int(hitRate * 100))%)
        Cache Misses: \(cacheMisses)
        Average Load Time: \(String(format: "%.2f", averageLoadTime))s

        Recommendations:
        \(generateRecommendations())
        """
    }

    private func generateRecommendations() -> String {
        if hitRate < 0.5 {
            return "• Consider increasing cache size\n• Review cache TTL settings"
        } else if hitRate > 0.9 {
            return "• Cache performing well\n• Consider reducing cache size if storage is limited"
        } else {
            return "• Cache performance is acceptable"
        }
    }
}
```

## Troubleshooting Cache Issues

### Common Issues and Solutions

| Issue | Cause | Solution |
|-------|-------|----------|
| Images not caching | Cache disabled | Check configuration isn't `.disabled` |
| Cache fills quickly | Low size limits | Increase `costLimit` or `sizeLimit` |
| Stale images shown | Long TTL | Reduce TTL or implement validation |
| High memory usage | Aggressive caching | Use `.conservative` or reduce limits |
| Slow initial loads | No prefetching | Implement strategic prefetching |

### Cache Debugging

```swift
extension PKSImage {
    func debugCache(_ label: String) -> some View {
        self
            .onProgress { progress in
                print("[\(label)] From cache: \(progress.isFromCache)")
            }
            .onStatusChange { status in
                if case .success = status {
                    let cached = PKSImageCacheManager.shared.isCached(url: url)
                    print("[\(label)] Cached after load: \(cached)")
                }
            }
    }
}
```

## Best Practices

### DO's

1. **Configure cache based on content type** - Different content needs different strategies
2. **Monitor cache performance** - Track hit rates and adjust accordingly
3. **Implement cache warming** for predictable content
4. **Clear cache periodically** to prevent stale data
5. **Adjust for device capabilities** - Memory and storage vary

### DON'Ts

1. **Don't cache sensitive data** to disk without encryption
2. **Don't use aggressive caching** on memory-constrained devices
3. **Don't ignore TTL** - Stale content frustrates users
4. **Don't cache everything** - Be selective about what needs caching
5. **Don't forget to handle** cache clearing on logout

## See Also

- ``PKSImageCacheConfiguration``
- ``PKSImageCacheManager``
- ``PKSMemoryCacheConfiguration``
- ``PKSDiskCacheConfiguration``
- <doc:PKSImageCacheManagement>
- <doc:PKSImagePerformanceOptimization>
