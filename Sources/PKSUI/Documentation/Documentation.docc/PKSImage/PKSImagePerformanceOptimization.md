# PKSImage Performance Optimization

Maximize PKSImage performance through advanced techniques, profiling, and best practices for smooth, responsive image loading.

## Overview

Performance optimization is crucial for delivering a fluid user experience. This guide covers comprehensive strategies to optimize image loading, reduce memory footprint, minimize latency, and ensure smooth scrolling even with hundreds of images.

## Performance Fundamentals

### Key Performance Metrics

```swift
struct PerformanceMetrics {
    // Latency Metrics
    let timeToFirstByte: TimeInterval      // Network response time
    let timeToDisplay: TimeInterval        // Total load time
    let decodingTime: TimeInterval        // Image processing time

    // Resource Metrics
    let memoryUsage: Int                  // Bytes in memory
    let diskUsage: Int                    // Bytes on disk
    let networkBandwidth: Int             // Bytes transferred

    // User Experience Metrics
    let frameRate: Double                 // FPS during scrolling
    let scrollJank: Int                   // Number of frame drops
    let perceivedLoadTime: TimeInterval   // User-perceived speed
}
```

## Memory Optimization

### Efficient Memory Management

```swift
class MemoryOptimizedImageLoader: ObservableObject {
    private let memoryLimit: Int
    private var memoryPressureObserver: NSObjectProtocol?

    init(memoryLimitMB: Int = 100) {
        self.memoryLimit = memoryLimitMB * 1024 * 1024
        setupMemoryPressureHandling()
    }

    private func setupMemoryPressureHandling() {
        #if os(iOS) || os(tvOS)
        memoryPressureObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleMemoryPressure()
        }
        #endif
    }

    private func handleMemoryPressure() {
        // Immediately clear memory cache
        PKSImageCacheManager.shared.clearMemoryCache()

        // Switch to conservative configuration
        PKSImageCacheManager.shared.configure(
            with: .conservative
        )

        // Cancel non-critical prefetches
        PKSImageManager.cancelAllPrefetches()

        print("⚠️ Memory pressure handled: Cache cleared")
    }

    func optimizedImageView(url: URL?, priority: PKSImagePriority = .normal) -> some View {
        PKSImage(url: url)
            .priority(priority)
            .cacheConfiguration(memoryOptimizedConfig())
    }

    private func memoryOptimizedConfig() -> PKSImageCacheConfiguration {
        let availableMemory = ProcessInfo.processInfo.physicalMemory
        let memoryFraction = availableMemory / (1024 * 1024 * 1024) // GB

        if memoryFraction < 2 {
            // Low memory device (< 2GB)
            return .conservative
        } else if memoryFraction < 4 {
            // Medium memory device (2-4GB)
            return .default
        } else {
            // High memory device (> 4GB)
            return .performance
        }
    }
}
```

### Image Downsampling

```swift
struct DownsampledImage: View {
    let url: URL?
    let targetSize: CGSize

    var body: some View {
        GeometryReader { geometry in
            PKSImage(url: downsampledURL(for: geometry.size)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
            }
        }
    }

    private func downsampledURL(for size: CGSize) -> URL? {
        guard let url = url else { return nil }

        // If your server supports dynamic resizing
        let scale = UIScreen.main.scale
        let pixelWidth = Int(size.width * scale)
        let pixelHeight = Int(size.height * scale)

        // Example: Add size parameters to URL
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "w", value: "\(pixelWidth)"),
            URLQueryItem(name: "h", value: "\(pixelHeight)"),
            URLQueryItem(name: "fit", value: "crop")
        ]

        return components?.url ?? url
    }
}
```

## Network Optimization

### Adaptive Quality Loading

```swift
class AdaptiveQualityLoader: ObservableObject {
    enum Quality: String {
        case low = "low"
        case medium = "medium"
        case high = "high"
        case original = "original"

        var sizeFactor: CGFloat {
            switch self {
            case .low: return 0.25
            case .medium: return 0.5
            case .high: return 0.75
            case .original: return 1.0
            }
        }
    }

    @Published var currentQuality: Quality = .medium
    private let monitor = NWPathMonitor()

    init() {
        setupNetworkMonitoring()
    }

    private func setupNetworkMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.updateQuality(for: path)
            }
        }
        monitor.start(queue: .global())
    }

    private func updateQuality(for path: NWPath) {
        if path.usesInterfaceType(.wifi) && !path.isExpensive {
            currentQuality = .high
        } else if path.usesInterfaceType(.cellular) {
            currentQuality = path.isExpensive ? .low : .medium
        } else {
            currentQuality = .low
        }
    }

    func imageURL(base: URL, for size: CGSize) -> URL {
        var components = URLComponents(url: base, resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "quality", value: currentQuality.rawValue),
            URLQueryItem(name: "w", value: "\(Int(size.width * currentQuality.sizeFactor))"),
            URLQueryItem(name: "h", value: "\(Int(size.height * currentQuality.sizeFactor))")
        ]
        return components?.url ?? base
    }
}
```

### Progressive Loading Strategy

```swift
struct ProgressiveImageLoader: View {
    let highQualityURL: URL?
    let lowQualityURL: URL?

    @State private var loadHighQuality = false

    var body: some View {
        ZStack {
            // Load low quality first
            if let lowURL = lowQualityURL {
                PKSImage(url: lowURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .priority(.veryHigh)
                .onCompletion { result in
                    if case .success = result {
                        // Start loading high quality after low quality loads
                        loadHighQuality = true
                    }
                }
            }

            // Overlay high quality when ready
            if loadHighQuality, let highURL = highQualityURL {
                PKSImage(url: highURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .transition(.opacity.animation(.easeIn(duration: 0.3)))
                } placeholder: {
                    Color.clear
                }
                .priority(.normal)
            }
        }
    }
}
```

## Scroll Performance

### Optimized List/Grid Loading

```swift
struct OptimizedScrollView<Content: View>: View {
    let content: Content
    @State private var scrollOffset: CGFloat = 0
    @State private var scrollVelocity: CGFloat = 0
    @State private var lastScrollTime = Date()

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ScrollView {
            GeometryReader { geometry in
                Color.clear.preference(
                    key: ScrollOffsetPreferenceKey.self,
                    value: geometry.frame(in: .named("scroll")).minY
                )
            }
            .frame(height: 0)

            content
        }
        .coordinateSpace(name: "scroll")
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
            let now = Date()
            let timeDiff = now.timeIntervalSince(lastScrollTime)

            if timeDiff > 0 {
                scrollVelocity = abs(value - scrollOffset) / CGFloat(timeDiff)
            }

            scrollOffset = value
            lastScrollTime = now

            adjustImageLoadingStrategy()
        }
    }

    private func adjustImageLoadingStrategy() {
        if scrollVelocity > 1000 {
            // Fast scrolling - pause non-critical loads
            PKSImageCacheManager.shared.pauseNonCriticalLoads()
        } else if scrollVelocity < 100 {
            // Slow/stopped - resume all loads
            PKSImageCacheManager.shared.resumeAllLoads()
        }
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
```

### Cell Reuse Optimization

```swift
struct OptimizedImageCell: View {
    let imageURL: URL?
    let index: Int

    @State private var imageTask: UUID?

    var body: some View {
        PKSImage(url: imageURL) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            Rectangle()
                .fill(Color.gray.opacity(0.2))
        }
        .priority(priorityForIndex(index))
        .onAppear {
            imageTask = UUID()
        }
        .onDisappear {
            // Cancel load if cell is reused quickly
            if let task = imageTask {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [task] in
                    if self.imageTask == task {
                        // Cell wasn't reused, don't cancel
                    } else {
                        // Cell was reused, cancel old load
                        PKSImageManager.cancelPrefetch(url: imageURL)
                    }
                }
            }
        }
    }

    private func priorityForIndex(_ index: Int) -> PKSImagePriority {
        // First few items get highest priority
        if index < 3 {
            return .veryHigh
        } else if index < 10 {
            return .high
        } else {
            return .normal
        }
    }
}
```

## CPU Optimization

### Batch Processing

```swift
class BatchImageProcessor {
    private let processingQueue = OperationQueue()
    private var pendingOperations: [URL: Operation] = [:]

    init() {
        processingQueue.maxConcurrentOperationCount = 2
        processingQueue.qualityOfService = .userInitiated
    }

    func processBatch(urls: [URL], completion: @escaping ([URL: Result<Void, Error>]) -> Void) {
        var results: [URL: Result<Void, Error>] = [:]
        let group = DispatchGroup()

        for url in urls {
            group.enter()

            let operation = BlockOperation {
                // Process image
                PKSImageManager.prefetch(url: url, priority: .normal)

                DispatchQueue.main.async {
                    results[url] = .success(())
                    group.leave()
                }
            }

            pendingOperations[url] = operation
            processingQueue.addOperation(operation)
        }

        group.notify(queue: .main) {
            completion(results)
            self.pendingOperations.removeAll()
        }
    }

    func cancelBatch() {
        processingQueue.cancelAllOperations()
        pendingOperations.removeAll()
    }
}
```

### Decode Optimization

```swift
struct OptimizedDecoding {
    static func configureForPerformance() -> PKSImageCacheConfiguration {
        return PKSImageCacheConfiguration(
            memoryCache: .default,
            diskCache: .default,
            policy: .storeDecodedImages, // Store decoded to avoid re-decoding
            isProgressiveDecodingEnabled: true, // Progressive for perceived speed
            isStoringPreviewsInMemoryCache: false, // Save memory
            isResumableDataEnabled: true // Resume interrupted downloads
        )
    }

    static func configureForMemory() -> PKSImageCacheConfiguration {
        return PKSImageCacheConfiguration(
            memoryCache: .conservative,
            diskCache: .aggressive,
            policy: .storeOriginalData, // Store original, decode on demand
            isProgressiveDecodingEnabled: false, // Save CPU
            isStoringPreviewsInMemoryCache: false, // Save memory
            isResumableDataEnabled: true
        )
    }
}
```

## Profiling and Monitoring

### Performance Monitor

```swift
class ImagePerformanceMonitor: ObservableObject {
    @Published var metrics = PerformanceMetrics()

    struct PerformanceMetrics {
        var averageLoadTime: TimeInterval = 0
        var cacheHitRate: Double = 0
        var memoryUsageMB: Double = 0
        var activeDownloads: Int = 0
        var failureRate: Double = 0

        var totalRequests: Int = 0
        var cacheHits: Int = 0
        var failures: Int = 0

        private var loadTimes: [TimeInterval] = []

        mutating func recordLoad(time: TimeInterval, cached: Bool, failed: Bool) {
            totalRequests += 1

            if cached {
                cacheHits += 1
            }

            if failed {
                failures += 1
            } else {
                loadTimes.append(time)
                if loadTimes.count > 100 {
                    loadTimes.removeFirst()
                }
            }

            // Update computed metrics
            averageLoadTime = loadTimes.isEmpty ? 0 : loadTimes.reduce(0, +) / Double(loadTimes.count)
            cacheHitRate = totalRequests > 0 ? Double(cacheHits) / Double(totalRequests) : 0
            failureRate = totalRequests > 0 ? Double(failures) / Double(totalRequests) : 0
        }
    }

    func monitoredImage(url: URL?) -> some View {
        let startTime = Date()

        return PKSImage(url: url)
            .onStatusChange { status in
                if case .loading = status {
                    self.metrics.activeDownloads += 1
                } else {
                    self.metrics.activeDownloads = max(0, self.metrics.activeDownloads - 1)
                }
            }
            .onCompletion { result in
                let loadTime = Date().timeIntervalSince(startTime)
                let cached = loadTime < 0.1 // Heuristic
                let failed = result.isFailure

                self.metrics.recordLoad(
                    time: loadTime,
                    cached: cached,
                    failed: failed
                )
            }
    }

    func generateReport() -> String {
        """
        Performance Report
        ==================
        Average Load Time: \(String(format: "%.2f", metrics.averageLoadTime))s
        Cache Hit Rate: \(Int(metrics.cacheHitRate * 100))%
        Failure Rate: \(Int(metrics.failureRate * 100))%
        Active Downloads: \(metrics.activeDownloads)
        Memory Usage: \(String(format: "%.1f", metrics.memoryUsageMB)) MB

        Recommendations:
        \(generateRecommendations())
        """
    }

    private func generateRecommendations() -> String {
        var recommendations: [String] = []

        if metrics.averageLoadTime > 2.0 {
            recommendations.append("• Consider implementing prefetching")
        }

        if metrics.cacheHitRate < 0.5 {
            recommendations.append("• Increase cache size or TTL")
        }

        if metrics.failureRate > 0.1 {
            recommendations.append("• Implement retry logic")
        }

        if metrics.memoryUsageMB > 100 {
            recommendations.append("• Use more conservative cache settings")
        }

        return recommendations.isEmpty ? "Performance is optimal" : recommendations.joined(separator: "\n")
    }
}
```

### Debug Performance Overlay

```swift
struct PerformanceDebugOverlay: ViewModifier {
    @StateObject private var monitor = ImagePerformanceMonitor()

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .topTrailing) {
                #if DEBUG
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Load: \(String(format: "%.2f", monitor.metrics.averageLoadTime))s")
                    Text("Cache: \(Int(monitor.metrics.cacheHitRate * 100))%")
                    Text("Active: \(monitor.metrics.activeDownloads)")
                    Text("Mem: \(String(format: "%.1f", monitor.metrics.memoryUsageMB))MB")
                }
                .font(.caption2)
                .padding(8)
                .background(Color.black.opacity(0.7))
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding()
                #endif
            }
    }
}

extension View {
    func performanceDebugOverlay() -> some View {
        modifier(PerformanceDebugOverlay())
    }
}
```

## Optimization Strategies by Use Case

### Social Media Feed

```swift
struct OptimizedSocialFeed {
    static func configuration() -> PKSImageCacheConfiguration {
        PKSImageCacheConfiguration(
            memoryCache: PKSMemoryCacheConfiguration(
                costLimit: 200 * 1024 * 1024, // 200MB
                countLimit: 100,
                ttl: 300 // 5 minutes
            ),
            diskCache: PKSDiskCacheConfiguration(
                sizeLimit: 500 * 1024 * 1024, // 500MB
                ttl: 86400 // 1 day
            ),
            policy: .storeDecodedImages,
            isProgressiveDecodingEnabled: true
        )
    }

    static func loadStrategy(for post: Post, isVisible: Bool) -> PKSImagePriority {
        if isVisible {
            return .veryHigh
        } else if post.isVideo {
            return .low // Video thumbnails are less critical
        } else if post.isSponsored {
            return .high // Sponsors get priority
        } else {
            return .normal
        }
    }
}
```

### E-Commerce Catalog

```swift
struct OptimizedProductCatalog {
    static func configuration() -> PKSImageCacheConfiguration {
        PKSImageCacheConfiguration(
            memoryCache: PKSMemoryCacheConfiguration(
                costLimit: 100 * 1024 * 1024, // 100MB
                countLimit: 50,
                ttl: 3600 // 1 hour - products change
            ),
            diskCache: PKSDiskCacheConfiguration(
                sizeLimit: 1024 * 1024 * 1024, // 1GB
                ttl: 3600 * 24 // 24 hours
            ),
            policy: .storeAll, // Store everything for offline
            isProgressiveDecodingEnabled: false // Quality matters
        )
    }

    static func prefetchStrategy(for category: ProductCategory) {
        // Prefetch based on user behavior
        let urls = category.products.prefix(10).compactMap { $0.thumbnailURL }
        PKSImageManager.prefetch(urls: urls, priority: .normal)

        // Prefetch hero images for top products
        let heroURLs = category.featuredProducts.compactMap { $0.heroImageURL }
        PKSImageManager.prefetch(urls: heroURLs, priority: .high)
    }
}
```

### Photo Gallery

```swift
struct OptimizedPhotoGallery {
    static func configuration() -> PKSImageCacheConfiguration {
        PKSImageCacheConfiguration(
            memoryCache: PKSMemoryCacheConfiguration(
                costLimit: 500 * 1024 * 1024, // 500MB for high-res
                countLimit: 20, // Fewer but larger images
                ttl: nil // No expiration
            ),
            diskCache: PKSDiskCacheConfiguration(
                sizeLimit: 5 * 1024 * 1024 * 1024, // 5GB
                ttl: nil // Permanent cache
            ),
            policy: .storeAll,
            isProgressiveDecodingEnabled: true
        )
    }

    static func loadThumbnailsFirst(photos: [Photo]) {
        // Load thumbnails with high priority
        let thumbnails = photos.compactMap { $0.thumbnailURL }
        PKSImageManager.prefetch(urls: thumbnails, priority: .high)

        // Queue full resolution for later
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let fullRes = photos.prefix(5).compactMap { $0.fullResolutionURL }
            PKSImageManager.prefetch(urls: fullRes, priority: .low)
        }
    }
}
```

## Best Practices Summary

### DO's

1. **Profile before optimizing** - Measure to identify actual bottlenecks
2. **Use appropriate image sizes** - Don't load 4K images for thumbnails
3. **Implement progressive loading** - Show something quickly
4. **Monitor memory pressure** - React to system warnings
5. **Batch operations** - Group network requests and processing
6. **Cache strategically** - Different content needs different strategies
7. **Prefetch intelligently** - Anticipate user behavior
8. **Test on real devices** - Simulators don't show real performance

### DON'Ts

1. **Don't over-optimize** - Premature optimization is evil
2. **Don't ignore errors** - Failed loads impact performance
3. **Don't cache everything** - Balance memory vs speed
4. **Don't prefetch aggressively** on cellular
5. **Don't decode large images** on the main thread
6. **Don't keep unused images** in memory
7. **Don't ignore scroll performance** - It's the most visible metric

## Performance Checklist

- [ ] Implemented appropriate cache configuration
- [ ] Added priority management for images
- [ ] Configured prefetching strategy
- [ ] Optimized image sizes/quality
- [ ] Added memory pressure handling
- [ ] Implemented scroll performance optimizations
- [ ] Added performance monitoring
- [ ] Tested on various devices
- [ ] Profiled with Instruments
- [ ] Documented performance targets

## See Also

- <doc:PKSImageCacheConfiguration>
- <doc:PKSImagePrefetchingGuide>
- <doc:PKSImageConfiguringPriority>
- <doc:PKSImageTroubleshooting>
