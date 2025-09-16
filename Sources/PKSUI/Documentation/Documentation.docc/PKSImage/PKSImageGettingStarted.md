# Getting Started with PKSImage

Learn how to integrate PKSImage into your SwiftUI application for powerful image loading capabilities.

## Overview

``PKSImage`` provides a drop-in replacement for SwiftUI's `AsyncImage` with significantly enhanced capabilities. This guide will walk you through the initial setup and basic implementation to get you started quickly.

## Installation Requirements

Before using ``PKSImage``, ensure your project meets these requirements:

- **iOS** 15.0+ / **macOS** 12.0+ / **tvOS** 15.0+ / **watchOS** 8.0+
- **Swift** 5.5+
- **Xcode** 13.0+

## Basic Setup

### Step 1: Import the Framework

Add the PKSUI import statement to your Swift file:

```swift
import PKSUI
import SwiftUI
```

### Step 2: Your First PKSImage

The simplest way to display an image from a URL:

```swift
struct ContentView: View {
    var body: some View {
        PKSImage(url: URL(string: "https://example.com/image.jpg"))
            .frame(width: 200, height: 200)
    }
}
```

### Step 3: Adding a Custom Placeholder

Provide a custom placeholder while the image loads:

```swift
PKSImage(url: URL(string: "https://example.com/image.jpg")) { image in
    image
        .resizable()
        .aspectRatio(contentMode: .fit)
} placeholder: {
    ProgressView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.1))
}
```

## Understanding the Loading Process

``PKSImage`` follows a sophisticated loading pipeline:

1. **Request Initiation**: The view creates an image request with the provided URL
2. **Cache Check**: The system first checks memory cache, then disk cache
3. **Network Request**: If not cached, downloads the image from the network
4. **Progressive Decoding**: Optionally displays partial images during download
5. **Processing**: Applies any configured image transformations
6. **Display**: Renders the final image in your view
7. **Cache Storage**: Stores the image in configured cache tiers

## Configuration Options

### Global Configuration

Set up a default configuration for all ``PKSImage`` instances in your app:

```swift
@main
struct MyApp: App {
    init() {
        // Configure global image cache settings
        PKSImageCacheManager.shared.configure(
            with: .performance
        )
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### Per-Image Configuration

Override global settings for specific images:

```swift
PKSImage(url: profileImageURL)
    .priority(.high)
    .cacheConfiguration(.aggressive)
    .onProgress { progress in
        print("Downloaded: \(progress.downloadedKB) KB")
    }
```

## Common Patterns

### Loading User Avatars

```swift
struct UserAvatar: View {
    let userImageURL: URL?

    var body: some View {
        PKSImage(url: userImageURL) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(.gray)
        }
        .frame(width: 50, height: 50)
        .clipShape(Circle())
        .priority(.high) // User avatars are high priority
    }
}
```

### Gallery Grid

```swift
struct ImageGallery: View {
    let imageURLs: [URL]

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]) {
            ForEach(imageURLs, id: \.self) { url in
                PKSImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        Image(systemName: "photo")
                            .foregroundColor(.red)
                    case .empty:
                        Rectangle()
                            .foregroundColor(.gray.opacity(0.2))
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 100, height: 100)
                .clipped()
            }
        }
        .onAppear {
            // Prefetch visible images
            PKSImageManager.prefetch(urls: Array(imageURLs.prefix(20)))
        }
    }
}
```

## Best Practices

### 1. Choose Appropriate Priorities

- **`.veryHigh`**: Hero images, currently visible content
- **`.high`**: About-to-be-visible content (e.g., next carousel item)
- **`.normal`**: Standard content loading (default)
- **`.low`**: Off-screen content that might be needed soon
- **`.veryLow`**: Prefetching, speculative loading

### 2. Optimize Cache Configuration

- Use **`.aggressive`** for frequently accessed images
- Use **`.memoryOnly`** for temporary or sensitive images
- Use **`.conservative`** for large images or limited storage

### 3. Handle Loading States

Always provide appropriate UI for different loading phases:

```swift
PKSImage(url: imageURL) { phase in
    if let image = phase.image {
        image // Success state
    } else if phase.error != nil {
        ErrorView() // Error state
    } else {
        LoadingView() // Loading state
    }
}
```

### 4. Implement Error Recovery

```swift
PKSImage(url: imageURL)
    .onCompletion { result in
        switch result {
        case .failure(let error):
            // Log error or attempt retry
            logError(error)
        case .success:
            // Track successful loads if needed
            break
        }
    }
```

## Memory Management

``PKSImage`` automatically manages memory efficiently:

- **Automatic cache eviction** when memory pressure is detected
- **Intelligent preloading** that respects system resources
- **Progressive image loading** reduces memory spikes
- **Configurable cache limits** prevent excessive memory usage

## Next Steps

Now that you understand the basics, explore these advanced topics:

- <doc:PKSImageBasicUsage> - Detailed usage examples
- <doc:PKSImageCacheConfiguration> - Advanced caching strategies
- <doc:PKSImagePrefetchingGuide> - Optimize with prefetching
- <doc:PKSImagePerformanceOptimization> - Performance best practices

## See Also

- ```PKSImage```
- ``PKSImagePriority``
- ``PKSImageCacheConfiguration``
