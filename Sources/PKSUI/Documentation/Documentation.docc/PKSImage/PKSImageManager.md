# PKSImageManager

A centralized manager for image prefetching and cache management operations.

## Overview

``PKSImageManager`` provides static methods to manage image loading operations globally across your application. It offers powerful prefetching capabilities and comprehensive cache management tools to optimize image loading performance.

## Key Responsibilities

The ``PKSImageManager`` handles:
- **Image Prefetching**: Proactively load images before they're needed
- **Cache Management**: Control memory and disk caching behavior
- **Resource Optimization**: Manage system resources efficiently
- **Global Configuration**: Apply cache settings across all PKSImage instances

## Prefetching Images

### Why Use Prefetching?

Prefetching dramatically improves user experience by loading images before they're visible. This is especially valuable for:
- List and grid views where users scroll through content
- Image carousels and galleries
- Tab-based interfaces where content is predictable
- Onboarding flows with sequential images

### Basic Prefetching

```swift
// Prefetch a single image
PKSImageManager.prefetch(
    url: URL(string: "https://example.com/image.jpg")
)

// Prefetch with specific priority
PKSImageManager.prefetch(
    url: URL(string: "https://example.com/important.jpg"),
    priority: .high
)
```

### Batch Prefetching

For optimal performance when dealing with multiple images:

```swift
// Prefetch multiple images at once
let imageURLs = [
    URL(string: "https://example.com/image1.jpg"),
    URL(string: "https://example.com/image2.jpg"),
    URL(string: "https://example.com/image3.jpg")
].compactMap { $0 }

PKSImageManager.prefetch(urls: imageURLs, priority: .low)
```

### Prefetching in Lists

```swift
struct ImageList: View {
    let items: [ImageItem]
    @State private var visibleRange = 0..<10

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(items.indices, id: \.self) { index in
                    ImageRow(item: items[index])
                        .onAppear {
                            prefetchNearbyImages(around: index)
                        }
                }
            }
        }
    }

    func prefetchNearbyImages(around index: Int) {
        let prefetchRange = max(0, index - 5)..<min(items.count, index + 10)
        let urlsToPrefetch = prefetchRange.compactMap { items[$0].imageURL }
        PKSImageManager.prefetch(urls: urlsToPrefetch, priority: .low)
    }
}
```

### Canceling Prefetch Operations

Free up resources when prefetching is no longer needed:

```swift
// Cancel specific prefetch
PKSImageManager.cancelPrefetch(url: imageURL)

// Cancel multiple prefetches
PKSImageManager.cancelPrefetch(urls: imageURLs)

// Cancel all ongoing prefetches
PKSImageManager.cancelAllPrefetches()
```

## Cache Management

### Global Cache Configuration

Configure caching behavior for all PKSImage instances:

```swift
// In your app initialization
@main
struct MyApp: App {
    init() {
        // Set aggressive caching for better performance
        PKSImageManager.configureCacheGlobally(.aggressive)

        // Or use a custom configuration
        let customConfig = PKSImageCacheConfiguration(
            memoryCache: PKSMemoryCacheConfiguration(
                costLimit: 200_000_000,  // 200 MB
                countLimit: 1000
            ),
            diskCache: PKSDiskCacheConfiguration(
                sizeLimit: 1_000_000_000,  // 1 GB
                expiration: .days(30)
            )
        )
        PKSImageManager.configureCacheGlobally(customConfig)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### Cache Maintenance

#### Clearing Caches

```swift
// Clear memory cache (e.g., on memory warning)
PKSImageManager.clearMemoryCache()

// Clear disk cache (e.g., on app maintenance)
PKSImageManager.clearDiskCache()

// Clear everything (e.g., on user logout)
PKSImageManager.clearAllCaches()
```

#### Selective Cache Removal

```swift
// Remove specific image from cache
if let outdatedImageURL = userProfile.oldAvatarURL {
    PKSImageManager.removeFromCache(url: outdatedImageURL)
}
```

### Monitoring Cache Performance

```swift
// Get cache statistics
let stats = PKSImageManager.cacheStatistics

print("Memory Cache:")
print("  Items: \(stats.memoryCacheTotalCount)")
print("  Size: \(stats.memoryCacheTotalCost) bytes")

print("Disk Cache:")
print("  Items: \(stats.diskCacheTotalCount)")
print("  Size: \(stats.diskCacheTotalSize) bytes")

// Use statistics for debugging or analytics
if stats.memoryCacheTotalCost > 100_000_000 {  // Over 100MB
    // Consider clearing memory cache
    PKSImageManager.clearMemoryCache()
}
```

## Best Practices

### 1. Strategic Prefetching

```swift
struct SmartGallery: View {
    let images: [URL]
    @State private var currentIndex = 0

    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(images.indices, id: \.self) { index in
                PKSImage(url: images[index])
                    .tag(index)
            }
        }
        .onChange(of: currentIndex) { newIndex in
            // Prefetch next and previous images
            prefetchAdjacentImages(around: newIndex)
        }
        .onAppear {
            // Initial prefetch
            prefetchAdjacentImages(around: 0)
        }
    }

    func prefetchAdjacentImages(around index: Int) {
        var urlsToPrefetch: [URL] = []

        // Previous image
        if index > 0 {
            urlsToPrefetch.append(images[index - 1])
        }

        // Next two images
        for offset in 1...2 {
            if index + offset < images.count {
                urlsToPrefetch.append(images[index + offset])
            }
        }

        PKSImageManager.prefetch(urls: urlsToPrefetch, priority: .high)
    }
}
```

### 2. Memory Management

```swift
class ImageViewController: ObservableObject {

    func handleMemoryWarning() {
        // Clear memory cache but keep disk cache
        PKSImageManager.clearMemoryCache()

        // Cancel non-essential prefetches
        PKSImageManager.cancelAllPrefetches()
    }

    func applicationDidEnterBackground() {
        // Reduce memory footprint when backgrounded
        PKSImageManager.clearMemoryCache()
    }
}
```

### 3. Cache Lifecycle Management

```swift
struct UserProfileManager {

    func userDidLogin(user: User) {
        // Configure cache for logged-in user
        PKSImageManager.configureCacheGlobally(.performance)

        // Prefetch user's frequently accessed images
        let importantImages = [
            user.avatarURL,
            user.coverPhotoURL
        ].compactMap { $0 }

        PKSImageManager.prefetch(urls: importantImages, priority: .high)
    }

    func userDidLogout() {
        // Clear all caches on logout for privacy
        PKSImageManager.clearAllCaches()

        // Cancel any ongoing operations
        PKSImageManager.cancelAllPrefetches()

        // Switch to conservative caching for logged-out state
        PKSImageManager.configureCacheGlobally(.conservative)
    }

    func userProfileUpdated(oldAvatarURL: URL?, newAvatarURL: URL?) {
        // Remove old avatar from cache
        if let oldURL = oldAvatarURL {
            PKSImageManager.removeFromCache(url: oldURL)
        }

        // Prefetch new avatar with high priority
        if let newURL = newAvatarURL {
            PKSImageManager.prefetch(url: newURL, priority: .veryHigh)
        }
    }
}
```

### 4. Performance Monitoring

```swift
class PerformanceMonitor {

    func logCachePerformance() {
        let stats = PKSImageManager.cacheStatistics

        // Log to analytics
        Analytics.log("cache_performance", [
            "memory_items": stats.memoryCacheTotalCount,
            "memory_bytes": stats.memoryCacheTotalCost,
            "disk_items": stats.diskCacheTotalCount,
            "disk_bytes": stats.diskCacheTotalSize,
            "hit_rate": stats.hitRate
        ])

        // Alert if cache is too large
        let maxDiskSize = 500_000_000  // 500 MB
        if stats.diskCacheTotalSize > maxDiskSize {
            // Trigger maintenance
            performCacheMaintenance()
        }
    }

    func performCacheMaintenance() {
        // Clear old disk cache entries
        PKSImageManager.clearDiskCache()

        // Reconfigure with appropriate limits
        PKSImageManager.configureCacheGlobally(.balanced)
    }
}
```

## Common Patterns

### Prefetching for Collection Views

```swift
struct OptimizedGrid: View {
    let items: [Item]
    let columns = [GridItem(.adaptive(minimum: 100))]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(items.indices, id: \.self) { index in
                    ItemCell(item: items[index])
                        .onAppear {
                            // Prefetch next batch when approaching end
                            if index == items.count - 10 {
                                prefetchNextBatch(from: index)
                            }
                        }
                }
            }
        }
        .onAppear {
            // Initial prefetch
            prefetchInitialBatch()
        }
    }

    func prefetchInitialBatch() {
        let urls = items.prefix(20).compactMap { $0.imageURL }
        PKSImageManager.prefetch(urls: urls, priority: .normal)
    }

    func prefetchNextBatch(from index: Int) {
        let startIndex = index + 1
        let endIndex = min(startIndex + 20, items.count)
        let urls = items[startIndex..<endIndex].compactMap { $0.imageURL }
        PKSImageManager.prefetch(urls: urls, priority: .low)
    }
}
```

### Dynamic Priority Management

```swift
struct PriorityAwareGallery: View {
    let images: [ImageData]

    var body: some View {
        ScrollView {
            VStack {
                // Hero image - highest priority
                if let hero = images.first {
                    PKSImage(url: hero.url)
                        .priority(.veryHigh)
                }

                // Featured images - high priority
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(images.prefix(5)) { image in
                            PKSImage(url: image.url)
                                .priority(.high)
                        }
                    }
                }

                // Regular content - normal priority
                LazyVStack {
                    ForEach(images.dropFirst(5)) { image in
                        PKSImage(url: image.url)
                            .priority(.normal)
                    }
                }
            }
        }
    }
}
```

## See Also

- ``PKSImage``
- ``PKSImageCacheConfiguration``
- ``PKSImagePriority``
- <doc:PKSImagePrefetchingGuide>
- <doc:PKSImageCacheManagement>