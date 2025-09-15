# PKSImage Prefetching Guide

Optimize user experience by loading images before they're needed, ensuring instant display when users navigate to new content.

## Overview

Prefetching is a powerful optimization technique that loads images in the background before they become visible. ``PKSImage`` provides comprehensive prefetching APIs that work seamlessly with the caching system to deliver lightning-fast image display.

## Understanding Prefetching

### How Prefetching Works

```
User browses content → Predict next images → Load in background → Images ready when needed
        ↓                      ↓                     ↓                      ↓
   [Current View]      [Analysis Engine]      [Prefetch Queue]       [Instant Display]
```

### Benefits of Prefetching

- **Instant image display** when users navigate
- **Smooth scrolling** without loading delays
- **Reduced perceived latency** in the app
- **Better resource utilization** during idle time
- **Improved user satisfaction** with responsive UI

## Basic Prefetching

### Single Image Prefetching

```swift
// Prefetch a single image
PKSImageManager.prefetch(url: URL(string: "https://example.com/next-image.jpg"))

// Prefetch with specific priority
PKSImageManager.prefetch(
    url: URL(string: "https://example.com/important.jpg"),
    priority: .high
)
```

### Multiple Images Prefetching

```swift
// Prefetch multiple images
let imageURLs = [
    URL(string: "https://example.com/image1.jpg"),
    URL(string: "https://example.com/image2.jpg"),
    URL(string: "https://example.com/image3.jpg")
].compactMap { $0 }

PKSImageManager.prefetch(urls: imageURLs, priority: .normal)
```

### Canceling Prefetch Operations

```swift
// Cancel single prefetch
PKSImageManager.cancelPrefetch(url: imageURL)

// Cancel multiple prefetches
PKSImageManager.cancelPrefetch(urls: imageURLs)

// Cancel all ongoing prefetches
PKSImageManager.cancelAllPrefetches()
```

## Prefetching Strategies

### 1. List/Collection Prefetching

```swift
struct OptimizedImageList: View {
    let items: [ImageItem]
    @State private var visibleRange: Range<Int> = 0..<0

    var body: some View {
        ScrollViewReader { proxy in
            List(items.indices, id: \.self) { index in
                ImageRow(item: items[index])
                    .id(index)
                    .onAppear {
                        updateVisibleRange(index)
                        prefetchNearbyImages(around: index)
                    }
                    .onDisappear {
                        // Optional: Cancel far away prefetches
                        cancelDistantPrefetches(from: index)
                    }
            }
        }
    }

    private func updateVisibleRange(_ index: Int) {
        let start = max(0, index - 2)
        let end = min(items.count, index + 3)
        visibleRange = start..<end
    }

    private func prefetchNearbyImages(around index: Int) {
        // Prefetch strategy: Load 5 images ahead, 2 behind
        let prefetchRange = max(0, index - 2)..<min(items.count, index + 6)

        for i in prefetchRange where !visibleRange.contains(i) {
            if let url = items[i].imageURL {
                let priority: PKSImagePriority = {
                    let distance = abs(i - index)
                    switch distance {
                    case 0...1: return .high
                    case 2...3: return .normal
                    default: return .low
                    }
                }()

                PKSImageManager.prefetch(url: url, priority: priority)
            }
        }
    }

    private func cancelDistantPrefetches(from index: Int) {
        // Cancel prefetches for items far from current position
        let cancelThreshold = 10

        let distantURLs = items.enumerated().compactMap { i, item -> URL? in
            if abs(i - index) > cancelThreshold {
                return item.imageURL
            }
            return nil
        }

        if !distantURLs.isEmpty {
            PKSImageManager.cancelPrefetch(urls: distantURLs)
        }
    }
}
```

### 2. Page-Based Prefetching

```swift
struct PagedImageViewer: View {
    let pages: [PageContent]
    @State private var currentPage = 0

    var body: some View {
        TabView(selection: $currentPage) {
            ForEach(pages.indices, id: \.self) { index in
                PageView(content: pages[index])
                    .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .onChange(of: currentPage) { newPage in
            prefetchAdjacentPages(current: newPage)
        }
        .onAppear {
            // Initial prefetch
            prefetchAdjacentPages(current: 0)
        }
    }

    private func prefetchAdjacentPages(current: Int) {
        // Cancel all existing prefetches first
        PKSImageManager.cancelAllPrefetches()

        // Prefetch pattern for pages
        let prefetchPattern = [
            (offset: -2, priority: PKSImagePriority.low),
            (offset: -1, priority: PKSImagePriority.high),
            (offset: 1, priority: PKSImagePriority.veryHigh),
            (offset: 2, priority: PKSImagePriority.normal),
            (offset: 3, priority: PKSImagePriority.low)
        ]

        for pattern in prefetchPattern {
            let pageIndex = current + pattern.offset
            if pageIndex >= 0 && pageIndex < pages.count {
                if let urls = pages[pageIndex].imageURLs {
                    PKSImageManager.prefetch(urls: urls, priority: pattern.priority)
                }
            }
        }
    }
}
```

### 3. Grid Prefetching

```swift
struct ImageGrid: View {
    let images: [ImageData]
    let columns = 3

    var body: some View {
        ScrollView {
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible()), count: columns),
                spacing: 10
            ) {
                ForEach(images.indices, id: \.self) { index in
                    GridImageCell(imageData: images[index])
                        .onAppear {
                            prefetchForGrid(currentIndex: index)
                        }
                }
            }
        }
    }

    private func prefetchForGrid(currentIndex: Int) {
        // Calculate which images are likely to appear next
        let currentRow = currentIndex / columns
        let prefetchRows = 3 // Number of rows to prefetch ahead

        let startIndex = currentIndex
        let endIndex = min(images.count, (currentRow + prefetchRows + 1) * columns)

        let urlsToPrefetch = (startIndex..<endIndex).compactMap { index in
            images[safe: index]?.url
        }

        // Batch prefetch with appropriate priority
        if !urlsToPrefetch.isEmpty {
            let priority: PKSImagePriority = {
                let rowDistance = (currentIndex / columns) - currentRow
                switch rowDistance {
                case 0: return .high
                case 1: return .normal
                default: return .low
                }
            }()

            PKSImageManager.prefetch(urls: urlsToPrefetch, priority: priority)
        }
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
```

### 4. Predictive Prefetching

```swift
class PredictivePrefetcher: ObservableObject {
    private var viewHistory: [URL] = []
    private var prefetchedURLs: Set<URL> = []

    func recordView(url: URL) {
        viewHistory.append(url)
        if viewHistory.count > 100 {
            viewHistory.removeFirst()
        }

        // Predict and prefetch next likely images
        predictAndPrefetch()
    }

    private func predictAndPrefetch() {
        // Simple pattern matching (can be replaced with ML model)
        let predictions = predictNextImages()

        for prediction in predictions {
            if !prefetchedURLs.contains(prediction.url) {
                PKSImageManager.prefetch(url: prediction.url, priority: prediction.priority)
                prefetchedURLs.insert(prediction.url)
            }
        }

        // Clean up old prefetched URLs
        if prefetchedURLs.count > 50 {
            prefetchedURLs.removeFirst()
        }
    }

    private func predictNextImages() -> [(url: URL, priority: PKSImagePriority)] {
        // Implement prediction logic based on patterns
        // This is a simplified example
        guard viewHistory.count > 2 else { return [] }

        // Look for patterns in recent history
        let recent = viewHistory.suffix(5)

        // Return predicted URLs with confidence-based priority
        return [] // Implement actual prediction
    }
}
```

## Advanced Prefetching Techniques

### Intelligent Prefetch Manager

```swift
class IntelligentPrefetchManager: ObservableObject {
    private var activePrefetches: [URL: PrefetchTask] = [:]
    private let maxConcurrentPrefetches = 5
    private let networkMonitor = NWPathMonitor()
    private var isWiFiAvailable = true

    struct PrefetchTask {
        let url: URL
        let priority: PKSImagePriority
        let timestamp: Date
        var attempts: Int = 0
    }

    init() {
        setupNetworkMonitoring()
    }

    private func setupNetworkMonitoring() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            self?.isWiFiAvailable = path.usesInterfaceType(.wifi)
            self?.adjustPrefetchingStrategy()
        }
        networkMonitor.start(queue: .global())
    }

    func intelligentPrefetch(urls: [URL], context: PrefetchContext) {
        // Determine optimal prefetch strategy
        let strategy = selectStrategy(for: context)

        // Filter URLs based on strategy
        let urlsToFetch = filterURLs(urls, using: strategy)

        // Queue prefetches with appropriate priorities
        for url in urlsToFetch {
            queuePrefetch(url: url, priority: strategy.priority)
        }

        // Manage queue size
        trimPrefetchQueue()
    }

    private func selectStrategy(for context: PrefetchContext) -> PrefetchStrategy {
        if !isWiFiAvailable {
            // Conservative on cellular
            return .conservative
        }

        switch context {
        case .scrolling(let velocity):
            if velocity > 1000 {
                return .minimal // Fast scrolling
            } else {
                return .aggressive // Slow scrolling
            }

        case .idle:
            return .aggressive // User not interacting

        case .navigation:
            return .focused // About to navigate

        case .background:
            return .opportunistic // App in background
        }
    }

    private func filterURLs(_ urls: [URL], using strategy: PrefetchStrategy) -> [URL] {
        switch strategy {
        case .aggressive:
            return urls // Prefetch all

        case .conservative:
            return Array(urls.prefix(3)) // Only first few

        case .minimal:
            return Array(urls.prefix(1)) // Only first

        case .focused:
            return Array(urls.prefix(5)) // Reasonable amount

        case .opportunistic:
            // Only prefetch if not already cached
            return urls.filter { !PKSImageCacheManager.shared.isCached(url: $0) }
        }
    }

    private func queuePrefetch(url: URL, priority: PKSImagePriority) {
        let task = PrefetchTask(
            url: url,
            priority: priority,
            timestamp: Date()
        )

        activePrefetches[url] = task

        PKSImageManager.prefetch(url: url, priority: priority)
    }

    private func trimPrefetchQueue() {
        if activePrefetches.count > maxConcurrentPrefetches {
            // Cancel oldest, lowest priority prefetches
            let toCancel = activePrefetches.values
                .sorted { $0.priority < $1.priority }
                .prefix(activePrefetches.count - maxConcurrentPrefetches)

            for task in toCancel {
                PKSImageManager.cancelPrefetch(url: task.url)
                activePrefetches.removeValue(forKey: task.url)
            }
        }
    }

    private func adjustPrefetchingStrategy() {
        if !isWiFiAvailable {
            // Reduce prefetching on cellular
            let lowPriorityTasks = activePrefetches.values
                .filter { $0.priority.rawValue < 500 }
                .map { $0.url }

            PKSImageManager.cancelPrefetch(urls: lowPriorityTasks)
            lowPriorityTasks.forEach { activePrefetches.removeValue(forKey: $0) }
        }
    }

    enum PrefetchContext {
        case scrolling(velocity: CGFloat)
        case idle
        case navigation
        case background
    }

    enum PrefetchStrategy {
        case aggressive
        case conservative
        case minimal
        case focused
        case opportunistic

        var priority: PKSImagePriority {
            switch self {
            case .aggressive: return .normal
            case .conservative: return .low
            case .minimal: return .veryLow
            case .focused: return .high
            case .opportunistic: return .veryLow
            }
        }
    }
}
```

### Scroll Velocity-Based Prefetching

```swift
struct VelocityAwarePrefetching: View {
    let items: [Item]
    @State private var scrollVelocity: CGFloat = 0
    @State private var lastOffset: CGFloat = 0

    var body: some View {
        ScrollView {
            GeometryReader { geometry in
                Color.clear.preference(
                    key: ScrollOffsetKey.self,
                    value: geometry.frame(in: .global).minY
                )
            }
            .frame(height: 0)

            LazyVStack {
                ForEach(items.indices, id: \.self) { index in
                    ItemView(item: items[index])
                        .onAppear {
                            adaptivePrefetch(for: index)
                        }
                }
            }
        }
        .onPreferenceChange(ScrollOffsetKey.self) { offset in
            scrollVelocity = abs(offset - lastOffset)
            lastOffset = offset
        }
    }

    private func adaptivePrefetch(for index: Int) {
        let prefetchCount: Int
        let priority: PKSImagePriority

        // Adjust based on scroll velocity
        if scrollVelocity < 100 {
            // Slow or no scrolling - prefetch more
            prefetchCount = 10
            priority = .normal
        } else if scrollVelocity < 500 {
            // Moderate scrolling
            prefetchCount = 5
            priority = .low
        } else {
            // Fast scrolling - minimal prefetch
            prefetchCount = 2
            priority = .veryLow
        }

        let endIndex = min(items.count, index + prefetchCount)
        let urls = items[index..<endIndex].compactMap { $0.imageURL }

        PKSImageManager.prefetch(urls: urls, priority: priority)
    }
}

struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
```

### Conditional Prefetching

```swift
struct ConditionalPrefetcher {
    static func shouldPrefetch(
        url: URL,
        batteryLevel: Float,
        isLowPowerMode: Bool,
        availableStorage: Int64,
        networkType: NetworkType
    ) -> Bool {
        // Don't prefetch in low power mode with low battery
        if isLowPowerMode && batteryLevel < 0.2 {
            return false
        }

        // Don't prefetch if storage is critically low
        if availableStorage < 100 * 1024 * 1024 { // Less than 100MB
            return false
        }

        // Don't prefetch large images on cellular
        if networkType == .cellular {
            // Check estimated size if available
            return shouldPrefetchOnCellular(url: url)
        }

        return true
    }

    private static func shouldPrefetchOnCellular(url: URL) -> Bool {
        // Implement logic to determine if URL should be prefetched on cellular
        // Could check URL patterns, known sizes, etc.
        return true // Simplified
    }

    enum NetworkType {
        case wifi
        case cellular
        case none
    }
}
```

## Prefetching Performance Monitoring

### Prefetch Analytics

```swift
class PrefetchAnalytics: ObservableObject {
    struct PrefetchMetric {
        let url: URL
        let startTime: Date
        var endTime: Date?
        var wasUsed: Bool = false
        var displayTime: Date?

        var prefetchDuration: TimeInterval? {
            guard let end = endTime else { return nil }
            return end.timeIntervalSince(startTime)
        }

        var timeToDisplay: TimeInterval? {
            guard let display = displayTime else { return nil }
            return display.timeIntervalSince(startTime)
        }

        var effectiveness: Float {
            guard wasUsed else { return 0 }
            guard let timeToDisplay = timeToDisplay else { return 0 }
            // If displayed within 5 seconds, highly effective
            return max(0, min(1, 5.0 / Float(timeToDisplay)))
        }
    }

    @Published private(set) var metrics: [URL: PrefetchMetric] = [:]

    func startPrefetch(url: URL) {
        metrics[url] = PrefetchMetric(url: url, startTime: Date())
    }

    func completePrefetch(url: URL) {
        metrics[url]?.endTime = Date()
    }

    func recordDisplay(url: URL) {
        metrics[url]?.wasUsed = true
        metrics[url]?.displayTime = Date()
    }

    func generateReport() -> PrefetchReport {
        let totalPrefetches = metrics.count
        let usedPrefetches = metrics.values.filter { $0.wasUsed }.count
        let averageEffectiveness = metrics.values
            .map { $0.effectiveness }
            .reduce(0, +) / Float(max(1, metrics.count))

        return PrefetchReport(
            totalPrefetches: totalPrefetches,
            usedPrefetches: usedPrefetches,
            hitRate: Float(usedPrefetches) / Float(max(1, totalPrefetches)),
            averageEffectiveness: averageEffectiveness,
            wastedPrefetches: totalPrefetches - usedPrefetches
        )
    }

    struct PrefetchReport {
        let totalPrefetches: Int
        let usedPrefetches: Int
        let hitRate: Float
        let averageEffectiveness: Float
        let wastedPrefetches: Int

        var summary: String {
            """
            Prefetch Performance:
            - Total: \(totalPrefetches)
            - Used: \(usedPrefetches) (\(Int(hitRate * 100))%)
            - Wasted: \(wastedPrefetches)
            - Effectiveness: \(Int(averageEffectiveness * 100))%
            """
        }
    }
}
```

## Best Practices

### DO's

1. **Prefetch based on user behavior** - Anticipate what users will see next
2. **Use appropriate priorities** - Critical content should prefetch first
3. **Cancel unnecessary prefetches** - Free up resources when direction changes
4. **Monitor network conditions** - Reduce prefetching on cellular/limited connections
5. **Track effectiveness** - Measure and optimize your prefetching strategy

### DON'Ts

1. **Don't prefetch everything** - Be selective to avoid wasting resources
2. **Don't ignore battery life** - Reduce prefetching in low power mode
3. **Don't prefetch on fast scrolling** - Users won't see the images
4. **Don't keep stale prefetches** - Cancel old operations
5. **Don't prefetch without monitoring** - Track what works and what doesn't

## Debugging Prefetch Operations

```swift
extension PKSImage {
    static func debugPrefetch(url: URL, label: String) {
        #if DEBUG
        print("🔄 Prefetching [\(label)]: \(url.lastPathComponent)")
        #endif

        prefetch(url: url, priority: .normal)
    }

    static func debugCancelPrefetch(url: URL, label: String) {
        #if DEBUG
        print("❌ Canceling prefetch [\(label)]: \(url.lastPathComponent)")
        #endif

        cancelPrefetch(url: url)
    }
}
```

## See Also

- ``PKSImage/prefetch(url:priority:)``
- ``PKSImage/prefetch(urls:priority:)``
- ``PKSImage/cancelPrefetch(url:)``
- ``PKSImage/cancelPrefetch(urls:)``
- ``PKSImage/cancelAllPrefetches()``
- <doc:PKSImageCacheConfiguration>
- <doc:PKSImagePerformanceOptimization>
