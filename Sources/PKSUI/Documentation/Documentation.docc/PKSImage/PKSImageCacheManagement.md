# PKSImage Cache Management

Master the complete cache management system to control storage, improve performance, and handle cache lifecycle effectively.

## Overview

`PKSImageCacheManager` provides centralized control over the image caching system. This guide covers cache operations, monitoring, cleanup strategies, and advanced management techniques for optimal cache utilization.

## Cache Manager Architecture

### System Overview

```
┌──────────────────────────────────────────┐
│          PKSImageCacheManager            │
│                                          │
│  ┌─────────────┐    ┌─────────────────┐ │
│  │   Memory    │    │      Disk       │ │
│  │    Cache    │───►│     Cache       │ │
│  └─────────────┘    └─────────────────┘ │
│         │                    │           │
│         ▼                    ▼           │
│  ┌─────────────────────────────────────┐│
│  │         Cache Operations             ││
│  │  • Store  • Retrieve  • Evict        ││
│  │  • Clear  • Monitor   • Validate     ││
│  └─────────────────────────────────────┘│
└──────────────────────────────────────────┘
```

## Basic Cache Operations

### Accessing the Cache Manager

```swift
// Singleton instance
let cacheManager = PKSImageCacheManager.shared

// Configure globally
cacheManager.configure(with: .default)

// Clear all caches
cacheManager.clearAllCaches()
```

### Core Operations

```swift
class CacheOperationsExample {
    let manager = PKSImageCacheManager.shared

    // Check if image is cached
    func checkCache(for url: URL) -> Bool {
        return manager.isCached(url: url)
    }

    // Remove specific image
    func removeImage(url: URL) {
        manager.removeFromCache(url: url)
    }

    // Clear memory cache only
    func clearMemory() {
        manager.clearMemoryCache()
    }

    // Clear disk cache only
    func clearDisk() {
        manager.clearDiskCache()
    }

    // Get cache sizes
    func getCacheSizes() -> (memory: Int, disk: Int) {
        return (
            memory: manager.memoryCacheSize,
            disk: manager.diskCacheSize
        )
    }

    // Trim cache to specific size
    func trimCache(toMB megabytes: Int) {
        manager.trimCache(toSize: megabytes * 1024 * 1024)
    }
}
```

## Advanced Cache Management

### Custom Cache Manager

```swift
class CustomCacheManager: ObservableObject {
    static let shared = CustomCacheManager()

    @Published var configuration: PKSImageCacheConfiguration
    @Published var statistics = CacheStatistics()

    private let fileManager = FileManager.default
    private var cacheDirectory: URL
    private var memoryWarningObserver: NSObjectProtocol?

    struct CacheStatistics {
        var totalRequests: Int = 0
        var cacheHits: Int = 0
        var cacheMisses: Int = 0
        var evictions: Int = 0
        var currentMemoryUsage: Int = 0
        var currentDiskUsage: Int = 0
        var lastCleanup: Date?

        var hitRate: Double {
            guard totalRequests > 0 else { return 0 }
            return Double(cacheHits) / Double(totalRequests)
        }
    }

    init() {
        self.configuration = .default

        // Setup cache directory
        let cachesDirectory = fileManager.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        ).first!
        self.cacheDirectory = cachesDirectory.appendingPathComponent("PKSImageCache")

        // Create directory if needed
        try? fileManager.createDirectory(
            at: cacheDirectory,
            withIntermediateDirectories: true
        )

        setupObservers()
        loadStatistics()
    }

    private func setupObservers() {
        #if os(iOS) || os(tvOS)
        memoryWarningObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleMemoryWarning()
        }
        #endif

        // Observe app lifecycle
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationWillTerminate),
            name: UIApplication.willTerminateNotification,
            object: nil
        )
    }

    private func handleMemoryWarning() {
        print("⚠️ Memory warning received, clearing memory cache")
        clearMemoryCache()
        statistics.evictions += statistics.cacheHits
        configuration = .conservative
    }

    @objc private func applicationDidEnterBackground() {
        // Perform cleanup when app goes to background
        performMaintenance()
    }

    @objc private func applicationWillTerminate() {
        // Save statistics before termination
        saveStatistics()
    }

    func performMaintenance() {
        Task {
            await cleanupExpiredCache()
            await compactCache()
            statistics.lastCleanup = Date()
        }
    }

    private func cleanupExpiredCache() async {
        // Remove expired items based on TTL
        let now = Date()

        do {
            let contents = try fileManager.contentsOfDirectory(
                at: cacheDirectory,
                includingPropertiesForKeys: [.creationDateKey, .fileSizeKey]
            )

            for url in contents {
                let resourceValues = try url.resourceValues(
                    forKeys: [.creationDateKey, .fileSizeKey]
                )

                if let creationDate = resourceValues.creationDate {
                    let age = now.timeIntervalSince(creationDate)

                    // Remove if older than TTL
                    if let ttl = configuration.diskCache.ttl, age > ttl {
                        try fileManager.removeItem(at: url)
                        statistics.evictions += 1
                    }
                }
            }
        } catch {
            print("Cache cleanup error: \(error)")
        }
    }

    private func compactCache() async {
        // Remove least recently used items if over size limit
        let sizeLimit = configuration.diskCache.sizeLimit

        do {
            let contents = try fileManager.contentsOfDirectory(
                at: cacheDirectory,
                includingPropertiesForKeys: [.fileSizeKey, .contentAccessDateKey]
            )

            // Sort by last access date
            let sorted = try contents.sorted { url1, url2 in
                let date1 = try url1.resourceValues(forKeys: [.contentAccessDateKey])
                    .contentAccessDate ?? Date.distantPast
                let date2 = try url2.resourceValues(forKeys: [.contentAccessDateKey])
                    .contentAccessDate ?? Date.distantPast
                return date1 < date2
            }

            var totalSize = 0
            var filesToDelete: [URL] = []

            // Calculate total size and mark for deletion
            for url in sorted.reversed() {
                let size = try url.resourceValues(forKeys: [.fileSizeKey])
                    .fileSize ?? 0
                totalSize += size

                if totalSize > sizeLimit {
                    filesToDelete.append(url)
                }
            }

            // Delete marked files
            for url in filesToDelete {
                try fileManager.removeItem(at: url)
                statistics.evictions += 1
            }

            statistics.currentDiskUsage = totalSize
        } catch {
            print("Cache compaction error: \(error)")
        }
    }

    private func loadStatistics() {
        // Load persisted statistics
        let statisticsURL = cacheDirectory.appendingPathComponent("statistics.json")

        if let data = try? Data(contentsOf: statisticsURL),
           let stats = try? JSONDecoder().decode(CacheStatistics.self, from: data) {
            self.statistics = stats
        }
    }

    private func saveStatistics() {
        // Persist statistics
        let statisticsURL = cacheDirectory.appendingPathComponent("statistics.json")

        if let data = try? JSONEncoder().encode(statistics) {
            try? data.write(to: statisticsURL)
        }
    }
}
```

### Cache Validation

```swift
class CacheValidator {
    enum ValidationResult {
        case valid
        case expired
        case corrupted
        case missing
    }

    static func validate(url: URL, in cache: PKSImageCacheManager) -> ValidationResult {
        // Check if cached
        guard cache.isCached(url: url) else {
            return .missing
        }

        // Check expiration
        if isExpired(url: url) {
            return .expired
        }

        // Verify integrity
        if !verifyIntegrity(url: url) {
            return .corrupted
        }

        return .valid
    }

    private static func isExpired(url: URL) -> Bool {
        // Check against configured TTL
        // Implementation depends on cache storage
        return false
    }

    private static func verifyIntegrity(url: URL) -> Bool {
        // Verify file integrity (checksum, size, etc.)
        return true
    }

    static func revalidate(url: URL, completion: @escaping (Bool) -> Void) {
        // Perform server revalidation (ETag, Last-Modified)
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"

        URLSession.shared.dataTask(with: request) { _, response, error in
            guard error == nil,
                  let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 304 else {
                completion(false)
                return
            }

            completion(true)
        }.resume()
    }
}
```

## Cache Policies and Strategies

### Intelligent Cache Policy

```swift
class IntelligentCachePolicy {
    enum ContentType {
        case userAvatar
        case productImage
        case temporaryContent
        case editorial
        case advertisement
    }

    static func policy(for type: ContentType) -> CachePolicy {
        switch type {
        case .userAvatar:
            return CachePolicy(
                memoryTTL: 3600,      // 1 hour
                diskTTL: 86400 * 30,  // 30 days
                priority: .high,
                shouldPersist: true
            )

        case .productImage:
            return CachePolicy(
                memoryTTL: 1800,      // 30 minutes
                diskTTL: 86400 * 7,   // 7 days
                priority: .normal,
                shouldPersist: true
            )

        case .temporaryContent:
            return CachePolicy(
                memoryTTL: 300,       // 5 minutes
                diskTTL: nil,         // No disk cache
                priority: .low,
                shouldPersist: false
            )

        case .editorial:
            return CachePolicy(
                memoryTTL: 3600,      // 1 hour
                diskTTL: 86400,       // 1 day
                priority: .normal,
                shouldPersist: true
            )

        case .advertisement:
            return CachePolicy(
                memoryTTL: 600,       // 10 minutes
                diskTTL: 3600,        // 1 hour
                priority: .low,
                shouldPersist: false
            )
        }
    }

    struct CachePolicy {
        let memoryTTL: TimeInterval?
        let diskTTL: TimeInterval?
        let priority: PKSImagePriority
        let shouldPersist: Bool
    }
}
```

### LRU Cache Implementation

```swift
class LRUImageCache {
    private var cache: [URL: CacheEntry] = [:]
    private var accessOrder: [URL] = []
    private let maxSize: Int
    private let lock = NSLock()

    struct CacheEntry {
        let data: Data
        let timestamp: Date
        var accessCount: Int
    }

    init(maxSize: Int) {
        self.maxSize = maxSize
    }

    func store(_ data: Data, for url: URL) {
        lock.lock()
        defer { lock.unlock() }

        // Remove if at capacity
        if cache.count >= maxSize {
            evictLeastRecentlyUsed()
        }

        cache[url] = CacheEntry(
            data: data,
            timestamp: Date(),
            accessCount: 0
        )

        // Update access order
        accessOrder.removeAll { $0 == url }
        accessOrder.append(url)
    }

    func retrieve(for url: URL) -> Data? {
        lock.lock()
        defer { lock.unlock() }

        guard var entry = cache[url] else { return nil }

        // Update access count and order
        entry.accessCount += 1
        cache[url] = entry

        accessOrder.removeAll { $0 == url }
        accessOrder.append(url)

        return entry.data
    }

    private func evictLeastRecentlyUsed() {
        guard let lru = accessOrder.first else { return }

        cache.removeValue(forKey: lru)
        accessOrder.removeFirst()
    }

    func clear() {
        lock.lock()
        defer { lock.unlock() }

        cache.removeAll()
        accessOrder.removeAll()
    }
}
```

## Cache Monitoring and Analytics

### Cache Performance Monitor

```swift
class CachePerformanceMonitor: ObservableObject {
    @Published var metrics = CacheMetrics()
    private var startTime = Date()

    struct CacheMetrics: Codable {
        var requests: Int = 0
        var hits: Int = 0
        var misses: Int = 0
        var evictions: Int = 0
        var bytesServedFromCache: Int64 = 0
        var bytesDownloaded: Int64 = 0
        var averageRetrievalTime: TimeInterval = 0

        var hitRate: Double {
            guard requests > 0 else { return 0 }
            return Double(hits) / Double(requests)
        }

        var bandwidthSaved: Int64 {
            return bytesServedFromCache
        }

        var efficiency: Double {
            let total = bytesServedFromCache + bytesDownloaded
            guard total > 0 else { return 0 }
            return Double(bytesServedFromCache) / Double(total)
        }
    }

    func recordRequest(cached: Bool, size: Int64, retrievalTime: TimeInterval) {
        metrics.requests += 1

        if cached {
            metrics.hits += 1
            metrics.bytesServedFromCache += size
        } else {
            metrics.misses += 1
            metrics.bytesDownloaded += size
        }

        // Update average retrieval time
        let currentAverage = metrics.averageRetrievalTime
        let newAverage = (currentAverage * Double(metrics.requests - 1) + retrievalTime) / Double(metrics.requests)
        metrics.averageRetrievalTime = newAverage
    }

    func recordEviction(count: Int = 1) {
        metrics.evictions += count
    }

    func generateReport() -> String {
        let runtime = Date().timeIntervalSince(startTime)
        let runtimeHours = runtime / 3600

        return """
        Cache Performance Report
        ========================
        Runtime: \(String(format: "%.1f", runtimeHours)) hours

        Requests: \(metrics.requests)
        Cache Hits: \(metrics.hits) (\(String(format: "%.1f%%", metrics.hitRate * 100)))
        Cache Misses: \(metrics.misses)
        Evictions: \(metrics.evictions)

        Data Served from Cache: \(formatBytes(metrics.bytesServedFromCache))
        Data Downloaded: \(formatBytes(metrics.bytesDownloaded))
        Bandwidth Saved: \(formatBytes(metrics.bandwidthSaved))
        Cache Efficiency: \(String(format: "%.1f%%", metrics.efficiency * 100))

        Average Retrieval Time: \(String(format: "%.3f", metrics.averageRetrievalTime))s

        Recommendations:
        \(generateRecommendations())
        """
    }

    private func generateRecommendations() -> String {
        var recommendations: [String] = []

        if metrics.hitRate < 0.5 {
            recommendations.append("• Low hit rate - consider increasing cache size")
        }

        if metrics.evictions > metrics.hits {
            recommendations.append("• High eviction rate - cache may be too small")
        }

        if metrics.averageRetrievalTime > 1.0 {
            recommendations.append("• Slow retrieval - check disk I/O performance")
        }

        if metrics.efficiency < 0.7 {
            recommendations.append("• Low efficiency - review caching policies")
        }

        return recommendations.isEmpty
            ? "Cache is performing optimally"
            : recommendations.joined(separator: "\n")
    }

    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .binary
        return formatter.string(fromByteCount: bytes)
    }
}
```

### Cache Health Check

```swift
class CacheHealthChecker {
    enum HealthStatus {
        case healthy
        case warning(String)
        case critical(String)
    }

    static func checkHealth() -> HealthStatus {
        let manager = PKSImageCacheManager.shared

        // Check cache sizes
        let (memorySize, diskSize) = (manager.memoryCacheSize, manager.diskCacheSize)

        // Check available storage
        let availableStorage = getAvailableStorage()

        // Check memory pressure
        let memoryPressure = getMemoryPressure()

        // Evaluate health
        if memoryPressure > 0.9 {
            return .critical("Critical memory pressure detected")
        }

        if availableStorage < 100 * 1024 * 1024 { // Less than 100MB
            return .critical("Critically low storage space")
        }

        if Double(diskSize) > Double(availableStorage) * 0.5 {
            return .warning("Cache using >50% of available storage")
        }

        if memoryPressure > 0.7 {
            return .warning("High memory pressure detected")
        }

        return .healthy
    }

    private static func getAvailableStorage() -> Int64 {
        let documentsURL = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!

        do {
            let values = try documentsURL.resourceValues(
                forKeys: [.volumeAvailableCapacityKey]
            )
            return Int64(values.volumeAvailableCapacity ?? 0)
        } catch {
            return 0
        }
    }

    private static func getMemoryPressure() -> Double {
        let memoryUsage = ProcessInfo.processInfo.physicalMemory
        // Simplified calculation
        return Double(memoryUsage) / Double(ProcessInfo.processInfo.physicalMemory)
    }
}
```

## Cache Cleanup Strategies

### Scheduled Cleanup

```swift
class CacheCleanupScheduler {
    private var cleanupTimer: Timer?
    private let cleanupInterval: TimeInterval

    init(interval: TimeInterval = 3600) { // Default 1 hour
        self.cleanupInterval = interval
        scheduleCleanup()
    }

    private func scheduleCleanup() {
        cleanupTimer = Timer.scheduledTimer(
            withTimeInterval: cleanupInterval,
            repeats: true
        ) { _ in
            self.performCleanup()
        }
    }

    private func performCleanup() {
        Task {
            await cleanupExpiredItems()
            await trimCacheIfNeeded()
            await defragmentCache()
        }
    }

    private func cleanupExpiredItems() async {
        // Remove expired items
        PKSImageCacheManager.shared.removeExpiredItems()
    }

    private func trimCacheIfNeeded() async {
        let manager = PKSImageCacheManager.shared
        let maxSize = 500 * 1024 * 1024 // 500MB

        if manager.diskCacheSize > maxSize {
            manager.trimCache(toSize: maxSize)
        }
    }

    private func defragmentCache() async {
        // Reorganize cache for better performance
        // Implementation depends on cache structure
    }

    func stop() {
        cleanupTimer?.invalidate()
        cleanupTimer = nil
    }
}
```

### Smart Cleanup

```swift
class SmartCacheCleanup {
    static func cleanup(basedOn usage: AppUsagePattern) {
        switch usage {
        case .heavy:
            // Keep more in cache for heavy users
            cleanupConservatively()

        case .moderate:
            // Standard cleanup
            cleanupStandard()

        case .light:
            // Aggressive cleanup for light users
            cleanupAggressively()
        }
    }

    private static func cleanupConservatively() {
        let manager = PKSImageCacheManager.shared

        // Keep last 7 days
        manager.removeItems(olderThan: 86400 * 7)

        // Keep up to 1GB
        if manager.diskCacheSize > 1024 * 1024 * 1024 {
            manager.trimCache(toSize: 1024 * 1024 * 1024)
        }
    }

    private static func cleanupStandard() {
        let manager = PKSImageCacheManager.shared

        // Keep last 3 days
        manager.removeItems(olderThan: 86400 * 3)

        // Keep up to 500MB
        if manager.diskCacheSize > 500 * 1024 * 1024 {
            manager.trimCache(toSize: 500 * 1024 * 1024)
        }
    }

    private static func cleanupAggressively() {
        let manager = PKSImageCacheManager.shared

        // Keep last 1 day
        manager.removeItems(olderThan: 86400)

        // Keep up to 100MB
        if manager.diskCacheSize > 100 * 1024 * 1024 {
            manager.trimCache(toSize: 100 * 1024 * 1024)
        }
    }

    enum AppUsagePattern {
        case heavy
        case moderate
        case light
    }
}
```

## User-Facing Cache Controls

### Cache Settings View

```swift
struct CacheSettingsView: View {
    @StateObject private var cacheManager = CustomCacheManager.shared
    @State private var showingClearConfirmation = false

    var body: some View {
        Form {
            Section("Cache Usage") {
                HStack {
                    Text("Memory Cache")
                    Spacer()
                    Text(formatBytes(cacheManager.statistics.currentMemoryUsage))
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("Disk Cache")
                    Spacer()
                    Text(formatBytes(cacheManager.statistics.currentDiskUsage))
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("Cache Hit Rate")
                    Spacer()
                    Text("\(Int(cacheManager.statistics.hitRate * 100))%")
                        .foregroundColor(.secondary)
                }
            }

            Section("Cache Settings") {
                Picker("Cache Mode", selection: $cacheManager.configuration) {
                    Text("Aggressive").tag(PKSImageCacheConfiguration.aggressive)
                    Text("Default").tag(PKSImageCacheConfiguration.default)
                    Text("Conservative").tag(PKSImageCacheConfiguration.conservative)
                    Text("Disabled").tag(PKSImageCacheConfiguration.disabled)
                }

                Toggle("Progressive Loading", isOn: .constant(cacheManager.configuration.isProgressiveDecodingEnabled))

                Toggle("Resumable Downloads", isOn: .constant(cacheManager.configuration.isResumableDataEnabled))
            }

            Section("Maintenance") {
                Button("Clear Memory Cache") {
                    cacheManager.clearMemoryCache()
                }

                Button("Clear Disk Cache") {
                    showingClearConfirmation = true
                }
                .foregroundColor(.red)

                if let lastCleanup = cacheManager.statistics.lastCleanup {
                    HStack {
                        Text("Last Cleanup")
                        Spacer()
                        Text(lastCleanup, style: .relative)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Cache Management")
        .confirmationDialog(
            "Clear Disk Cache?",
            isPresented: $showingClearConfirmation
        ) {
            Button("Clear", role: .destructive) {
                cacheManager.clearDiskCache()
            }
        } message: {
            Text("This will remove all cached images from disk.")
        }
    }

    private func formatBytes(_ bytes: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .binary
        return formatter.string(fromByteCount: Int64(bytes))
    }
}
```

## Best Practices

### DO's

1. **Monitor cache performance** regularly
2. **Implement appropriate cleanup strategies**
3. **Validate cache integrity** periodically
4. **Provide user controls** for cache management
5. **React to system events** (memory warnings, low storage)
6. **Use appropriate TTL values** for different content types
7. **Track cache metrics** for optimization

### DON'Ts

1. **Don't ignore cache size limits** - Respect device constraints
2. **Don't cache sensitive data** without encryption
3. **Don't forget cleanup** on app termination
4. **Don't use same policy** for all content types
5. **Don't ignore cache corruption** - Validate and recover

## See Also

- ``PKSImageCacheManager``
- <doc:PKSImageCacheConfiguration>
- <doc:PKSImagePerformanceOptimization>
- ``PKSImageCacheConfiguration``
