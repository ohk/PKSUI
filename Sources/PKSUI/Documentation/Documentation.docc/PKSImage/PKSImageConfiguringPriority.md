# PKSImage Configuring Priority

Master the art of priority management to optimize image loading performance and user experience.

## Overview

`PKSImagePriority` provides fine-grained control over the order in which images are loaded. By strategically assigning priorities, you can ensure critical content loads first while deferring less important images, resulting in a responsive and smooth user experience.

## Understanding Priority Levels

### Priority Scale

PKSImage uses a numeric priority scale from 0 to 1000:

- **0-200**: Very Low Priority
- **201-400**: Low Priority
- **401-600**: Normal Priority (default)
- **601-800**: High Priority
- **801-1000**: Very High Priority

### Predefined Priority Levels

```swift
// Standard priority levels
PKSImagePriority.veryLow    // 0
PKSImagePriority.low         // 250
PKSImagePriority.normal      // 500 (default)
PKSImagePriority.high        // 750
PKSImagePriority.veryHigh    // 1000
```

### Custom Priority Values

```swift
// Create custom priority levels
let customPriority = PKSImagePriority(rawValue: 850)
let backgroundPriority = PKSImagePriority(rawValue: 100)
let criticalPriority = PKSImagePriority(rawValue: 950)
```

## Priority Usage Patterns

### Hero Images

The main focal point of your screen should load first:

```swift
struct ProductDetailView: View {
    let product: Product

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                // Hero image - highest priority
                PKSImage(url: product.heroImageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                }
                .priority(.veryHigh)
                .frame(height: 400)

                // Secondary images - normal priority
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(product.additionalImages, id: \.self) { url in
                            PKSImage(url: url)
                                .priority(.normal)
                                .frame(width: 80, height: 80)
                        }
                    }
                }
            }
        }
    }
}
```

### List Optimization

Prioritize visible and near-visible content:

```swift
struct OptimizedListView: View {
    let items: [Item]
    @State private var visibleIndices: Set<Int> = []

    var body: some View {
        ScrollViewReader { proxy in
            List(items.indices, id: \.self) { index in
                ItemRow(
                    item: items[index],
                    priority: priorityForIndex(index)
                )
                .onAppear {
                    visibleIndices.insert(index)
                    updateNearbyPriorities(around: index)
                }
                .onDisappear {
                    visibleIndices.remove(index)
                }
            }
        }
    }

    private func priorityForIndex(_ index: Int) -> PKSImagePriority {
        if visibleIndices.contains(index) {
            return .high // Currently visible
        } else if visibleIndices.contains { abs($0 - index) <= 2 } {
            return .normal // Near visible items
        } else {
            return .low // Far from visible area
        }
    }

    private func updateNearbyPriorities(around index: Int) {
        // Prefetch nearby items with appropriate priority
        let nearbyRange = max(0, index - 3)..<min(items.count, index + 4)
        for i in nearbyRange where !visibleIndices.contains(i) {
            if let url = items[i].imageURL {
                PKSImageManager.prefetch(
                    url: url,
                    priority: abs(i - index) <= 1 ? .normal : .low
                )
            }
        }
    }
}

struct ItemRow: View {
    let item: Item
    let priority: PKSImagePriority

    var body: some View {
        HStack {
            PKSImage(url: item.imageURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
            }
            .priority(priority)
            .frame(width: 60, height: 60)
            .clipped()

            Text(item.title)
            Spacer()
        }
    }
}
```

### Carousel/PageView Priority

Optimize for current and adjacent pages:

```swift
struct PrioritizedCarousel: View {
    let imageURLs: [URL]
    @State private var currentIndex = 0

    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(imageURLs.indices, id: \.self) { index in
                PKSImage(url: imageURLs[index]) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    ProgressView()
                }
                .priority(priorityForCarouselIndex(index))
                .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .onChange(of: currentIndex) { _ in
            prefetchAdjacentImages()
        }
        .onAppear {
            prefetchAdjacentImages()
        }
    }

    private func priorityForCarouselIndex(_ index: Int) -> PKSImagePriority {
        let distance = abs(index - currentIndex)
        switch distance {
        case 0:
            return .veryHigh // Current image
        case 1:
            return .high // Adjacent images
        case 2:
            return .normal // Two steps away
        default:
            return .low // Far images
        }
    }

    private func prefetchAdjacentImages() {
        // Prefetch next and previous images
        let indicesToPrefetch = [
            currentIndex - 2,
            currentIndex - 1,
            currentIndex + 1,
            currentIndex + 2
        ].filter { $0 >= 0 && $0 < imageURLs.count }

        for index in indicesToPrefetch {
            let priority: PKSImagePriority = abs(index - currentIndex) == 1 ? .high : .normal
            PKSImageManager.prefetch(url: imageURLs[index], priority: priority)
        }
    }
}
```

### Dynamic Priority Adjustment

Adjust priorities based on user interaction:

```swift
struct DynamicPriorityView: View {
    @State private var selectedCategory: String = "Featured"
    @State private var isLoadingCategory = false

    let categories: [Category]

    var body: some View {
        VStack {
            // Category picker
            Picker("Category", selection: $selectedCategory) {
                ForEach(categories, id: \.name) { category in
                    Text(category.name).tag(category.name)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .onChange(of: selectedCategory) { newCategory in
                isLoadingCategory = true
                updatePrioritiesForCategory(newCategory)
            }

            // Content grid
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))]) {
                ForEach(currentItems) { item in
                    ItemCard(
                        item: item,
                        priority: item.category == selectedCategory ? .high : .low
                    )
                }
            }
        }
    }

    private func updatePrioritiesForCategory(_ category: String) {
        // Cancel low priority loads
        let lowPriorityURLs = categories
            .filter { $0.name != category }
            .flatMap { $0.items }
            .compactMap { $0.imageURL }

        PKSImageManager.cancelPrefetch(urls: lowPriorityURLs)

        // Prefetch new category with high priority
        let highPriorityURLs = categories
            .first { $0.name == category }?
            .items
            .compactMap { $0.imageURL } ?? []

        PKSImageManager.prefetch(urls: highPriorityURLs, priority: .high)
    }
}
```

## Priority Strategies

### 1. Viewport-Based Priority

```swift
struct ViewportPriorityStrategy {
    static func priority(for position: CGPoint, in viewport: CGRect) -> PKSImagePriority {
        if viewport.contains(position) {
            return .veryHigh // In viewport
        }

        let distance = min(
            abs(position.y - viewport.minY),
            abs(position.y - viewport.maxY)
        )

        switch distance {
        case 0..<100:
            return .high
        case 100..<300:
            return .normal
        case 300..<500:
            return .low
        default:
            return .veryLow
        }
    }
}
```

### 2. Time-Based Priority

```swift
struct TimeSensitivePriority {
    static func priority(for event: Event) -> PKSImagePriority {
        let timeUntilEvent = event.date.timeIntervalSinceNow

        switch timeUntilEvent {
        case ..<0:
            return .low // Past event
        case 0..<3600:
            return .veryHigh // Within next hour
        case 3600..<86400:
            return .high // Today
        case 86400..<604800:
            return .normal // This week
        default:
            return .low // Future
        }
    }
}
```

### 3. User Interaction Priority

```swift
struct InteractionBasedPriority: View {
    @State private var focusedItemID: String?
    let items: [Item]

    var body: some View {
        ScrollView {
            ForEach(items) { item in
                ItemView(item: item)
                    .priority(
                        focusedItemID == item.id ? .veryHigh : .normal
                    )
                    .onTapGesture {
                        focusedItemID = item.id
                    }
                    .onHover { isHovering in
                        if isHovering {
                            focusedItemID = item.id
                        }
                    }
            }
        }
    }
}
```

### 4. Network-Aware Priority

```swift
import Network

class NetworkAwarePriorityManager: ObservableObject {
    @Published var priorityMultiplier: Double = 1.0
    private let monitor = NWPathMonitor()

    init() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.updatePriorityMultiplier(for: path)
            }
        }
        monitor.start(queue: .global())
    }

    private func updatePriorityMultiplier(for path: NWPath) {
        if path.usesInterfaceType(.wifi) {
            priorityMultiplier = 1.0 // Full priority on WiFi
        } else if path.usesInterfaceType(.cellular) {
            priorityMultiplier = 0.7 // Reduced priority on cellular
        } else {
            priorityMultiplier = 0.5 // Conservative on unknown
        }
    }

    func adjustedPriority(_ base: PKSImagePriority) -> PKSImagePriority {
        let adjusted = Int(Double(base.rawValue) * priorityMultiplier)
        return PKSImagePriority(rawValue: adjusted)
    }
}
```

## Custom Priority Extensions

### Creating Domain-Specific Priorities

```swift
extension PKSImagePriority {
    // E-commerce specific priorities
    static let productHero = PKSImagePriority(rawValue: 950)
    static let productThumbnail = PKSImagePriority(rawValue: 700)
    static let relatedProduct = PKSImagePriority(rawValue: 400)
    static let advertisement = PKSImagePriority(rawValue: 200)

    // Social media specific priorities
    static let profilePicture = PKSImagePriority(rawValue: 900)
    static let feedImage = PKSImagePriority(rawValue: 600)
    static let storyThumbnail = PKSImagePriority(rawValue: 500)
    static let suggestedContent = PKSImagePriority(rawValue: 300)

    // News app specific priorities
    static let breakingNews = PKSImagePriority(rawValue: 1000)
    static let headline = PKSImagePriority(rawValue: 800)
    static let article = PKSImagePriority(rawValue: 500)
    static let related = PKSImagePriority(rawValue: 250)
}
```

### Priority Queue Management

```swift
class ImagePriorityQueue {
    private var queue: [(url: URL, priority: PKSImagePriority)] = []

    func enqueue(url: URL, priority: PKSImagePriority) {
        queue.append((url, priority))
        queue.sort { $0.priority > $1.priority }
    }

    func dequeue() -> URL? {
        guard !queue.isEmpty else { return nil }
        return queue.removeFirst().url
    }

    func reprioritize(url: URL, newPriority: PKSImagePriority) {
        if let index = queue.firstIndex(where: { $0.url == url }) {
            queue[index].priority = newPriority
            queue.sort { $0.priority > $1.priority }
        }
    }

    func cancelAll(below priority: PKSImagePriority) {
        let toCancel = queue.filter { $0.priority < priority }.map { $0.url }
        PKSImageManager.cancelPrefetch(urls: toCancel)
        queue.removeAll { $0.priority < priority }
    }
}
```

## Performance Monitoring

### Priority Effectiveness Tracking

```swift
class PriorityPerformanceMonitor: ObservableObject {
    struct LoadMetrics {
        let url: URL
        let priority: PKSImagePriority
        let loadTime: TimeInterval
        let fromCache: Bool
        let timestamp: Date
    }

    @Published private(set) var metrics: [LoadMetrics] = []

    func track(url: URL, priority: PKSImagePriority) -> some View {
        let startTime = Date()

        return PKSImage(url: url)
            .priority(priority)
            .onCompletion { result in
                let loadTime = Date().timeIntervalSince(startTime)
                self.recordMetric(
                    url: url,
                    priority: priority,
                    loadTime: loadTime,
                    success: result.isSuccess
                )
            }
    }

    private func recordMetric(url: URL, priority: PKSImagePriority, loadTime: TimeInterval, success: Bool) {
        // Record and analyze priority effectiveness
        let metric = LoadMetrics(
            url: url,
            priority: priority,
            loadTime: loadTime,
            fromCache: loadTime < 0.1, // Heuristic for cache hit
            timestamp: Date()
        )
        metrics.append(metric)

        // Log if high priority items are loading slowly
        if priority.rawValue > 700 && loadTime > 2.0 {
            print("⚠️ High priority image took \(loadTime)s: \(url)")
        }
    }

    var averageLoadTimeByPriority: [PKSImagePriority: TimeInterval] {
        Dictionary(grouping: metrics, by: { $0.priority })
            .mapValues { metrics in
                metrics.map { $0.loadTime }.reduce(0, +) / Double(metrics.count)
            }
    }
}
```

## Best Practices

### DO's

1. **Assign priorities based on user visibility** - What users see first should load first
2. **Adjust priorities dynamically** - Respond to user interactions and navigation
3. **Cancel low-priority loads** when they're no longer needed
4. **Use consistent priority schemes** across your app
5. **Monitor priority effectiveness** and adjust strategies based on metrics

### DON'Ts

1. **Don't use veryHigh for everything** - It defeats the purpose of prioritization
2. **Don't ignore network conditions** - Adjust priorities based on connection quality
3. **Don't set and forget** - Priorities should be dynamic
4. **Don't overload the queue** - Cancel unnecessary loads
5. **Don't assume cache hits** - Priorities matter even with good caching

## Debugging Priority Issues

### Priority Logging

```swift
extension PKSImage {
    func debugPriority(_ label: String) -> some View {
        self.onStatusChange { status in
            #if DEBUG
            print("[\(label)] Priority: \(priority.rawValue), Status: \(status)")
            #endif
        }
    }
}

// Usage
PKSImage(url: imageURL)
    .priority(.high)
    .debugPriority("HeroImage")
```

## See Also

- ``PKSImagePriority``
- <doc:PKSImagePrefetchingGuide>
- <doc:PKSImagePerformanceOptimization>
- <doc:PKSImageCacheConfiguration>
