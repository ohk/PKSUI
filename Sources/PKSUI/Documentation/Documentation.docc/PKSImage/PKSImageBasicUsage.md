# PKSImage Basic Usage

Comprehensive guide to using PKSImage in common scenarios with detailed examples.

## Overview

This guide covers the fundamental usage patterns of ``PKSImage``, from simple image loading to handling complex scenarios with custom configurations, error handling, and progress tracking.

## Simple Image Loading

### Basic Implementation

The most straightforward way to load an image:

```swift
PKSImage(url: URL(string: "https://api.example.com/image.jpg"))
```

### With Fixed Dimensions

```swift
PKSImage(url: imageURL)
    .frame(width: 300, height: 200)
    .clipped()
```

### With Aspect Ratio

```swift
PKSImage(url: imageURL) { image in
    image
        .resizable()
        .aspectRatio(contentMode: .fit)
}
.frame(maxWidth: .infinity)
```

## Working with Placeholders

### System Image Placeholder

```swift
PKSImage(url: imageURL) { image in
    image.resizable()
} placeholder: {
    Image(systemName: "photo")
        .font(.largeTitle)
        .foregroundColor(.secondary)
}
```

### Animated Loading Placeholder

```swift
PKSImage(url: imageURL) { image in
    image.resizable()
} placeholder: {
    VStack {
        ProgressView()
        Text("Loading...")
            .font(.caption)
            .foregroundColor(.secondary)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.gray.opacity(0.1))
}
```

### Skeleton Placeholder

```swift
PKSImage(url: imageURL) { image in
    image.resizable()
} placeholder: {
    Rectangle()
        .fill(Color.gray.opacity(0.3))
        .overlay(
            LinearGradient(
                colors: [.clear, .white.opacity(0.5), .clear],
                startPoint: .leading,
                endPoint: .trailing
            )
            .rotationEffect(.degrees(30))
            .offset(x: animationOffset)
            .animation(
                .linear(duration: 1.5).repeatForever(autoreverses: false),
                value: animationOffset
            )
        )
}
```

## Handling Loading Phases

### Complete Phase Handling

```swift
PKSImage(url: imageURL) { phase in
    switch phase {
    case .empty:
        // Initial state or URL is nil
        Color.gray.opacity(0.2)

    case .success(let image):
        // Image loaded successfully
        image
            .resizable()
            .transition(.opacity.combined(with: .scale))

    case .failure(let error):
        // Loading failed
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.red)

            Text("Failed to load image")
                .font(.caption)

            Text(error.localizedDescription)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button("Retry") {
                // Trigger reload
            }
            .buttonStyle(.bordered)
        }
        .padding()

    @unknown default:
        // Future-proof for new phases
        EmptyView()
    }
}
```

### Conditional Content Based on Phase

```swift
PKSImage(url: imageURL) { phase in
    if let image = phase.image {
        // Image is available (success case)
        image
            .resizable()
            .aspectRatio(contentMode: .fill)
    } else if let error = phase.error {
        // An error occurred
        ErrorView(error: error)
    } else {
        // Loading or empty state
        LoadingView()
    }
}
```

## Adding Transitions

### Fade In Animation

```swift
PKSImage(
    url: imageURL,
    transaction: Transaction(animation: .easeInOut(duration: 0.3))
) { phase in
    switch phase {
    case .success(let image):
        image
            .resizable()
            .transition(.opacity)
    case .failure:
        Image(systemName: "photo")
            .foregroundColor(.red)
    case .empty:
        ProgressView()
    @unknown default:
        EmptyView()
    }
}
```

### Scale and Fade Transition

```swift
PKSImage(
    url: imageURL,
    transaction: Transaction(animation: .spring())
) { phase in
    if let image = phase.image {
        image
            .resizable()
            .transition(
                .asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 0.8)),
                    removal: .opacity
                )
            )
    } else {
        Rectangle()
            .fill(Color.gray.opacity(0.2))
    }
}
```

## Progress Tracking

### Simple Progress Indicator

```swift
struct ProgressiveImage: View {
    let url: URL?
    @State private var progress: Double = 0

    var body: some View {
        PKSImage(url: url) { image in
            image.resizable()
        } placeholder: {
            ZStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.1))

                CircularProgressView(progress: progress)
            }
        }
        .onProgress { imageProgress in
            progress = imageProgress.fractionCompleted
        }
    }
}

struct CircularProgressView: View {
    let progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 4)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.blue, lineWidth: 4)
                .rotationEffect(.degrees(-90))
                .animation(.linear, value: progress)

            Text("\(Int(progress * 100))%")
                .font(.caption2)
                .fontWeight(.semibold)
        }
        .frame(width: 40, height: 40)
    }
}
```

### Detailed Progress Information

```swift
struct DetailedProgressImage: View {
    let url: URL?
    @State private var downloadedKB: Double = 0
    @State private var totalKB: Double?
    @State private var isFromCache = false

    var body: some View {
        VStack {
            PKSImage(url: url) { image in
                image.resizable()
            } placeholder: {
                VStack(spacing: 8) {
                    ProgressView()

                    if !isFromCache {
                        HStack {
                            Text("\(String(format: "%.1f", downloadedKB)) KB")

                            if let total = totalKB {
                                Text("of \(String(format: "%.1f", total)) KB")
                            }
                        }
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    } else {
                        Label("From Cache", systemImage: "checkmark.circle")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.gray.opacity(0.1))
            }
            .onProgress { progress in
                downloadedKB = progress.downloadedKB
                totalKB = progress.totalKB
                isFromCache = progress.isFromCache
            }
        }
    }
}
```

## Status Monitoring

### Complete Status Handling

```swift
struct StatusAwareImage: View {
    let url: URL?
    @State private var status: String = "Idle"
    @State private var statusColor: Color = .gray

    var body: some View {
        VStack {
            PKSImage(url: url) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
            .onStatusChange { imageStatus in
                switch imageStatus {
                case .idle:
                    status = "Ready"
                    statusColor = .gray

                case .loading(let progress):
                    status = "Loading... \(Int(progress.fractionCompleted * 100))%"
                    statusColor = .blue

                case .success:
                    status = "Loaded Successfully"
                    statusColor = .green

                case .failure(let error):
                    status = "Failed: \(error.localizedDescription)"
                    statusColor = .red

                case .cancelled:
                    status = "Cancelled"
                    statusColor = .orange
                }
            }

            // Status indicator
            HStack {
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)

                Text(status)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
        }
    }
}
```

## Error Handling

### Retry Mechanism

```swift
struct RetryableImage: View {
    @State private var url: URL?
    @State private var retryCount = 0
    @State private var lastError: Error?

    let originalURL: URL?
    let maxRetries = 3

    var body: some View {
        PKSImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .onAppear {
                        // Reset retry count on success
                        retryCount = 0
                    }

            case .failure(let error):
                VStack(spacing: 16) {
                    Image(systemName: "wifi.slash")
                        .font(.largeTitle)
                        .foregroundColor(.red)

                    Text("Failed to load image")
                        .font(.headline)

                    if retryCount < maxRetries {
                        Button("Retry (\(maxRetries - retryCount) left)") {
                            retry()
                        }
                        .buttonStyle(.borderedProminent)
                    } else {
                        Text("Max retries reached")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .onAppear {
                    lastError = error
                    if retryCount < maxRetries {
                        // Auto-retry with exponential backoff
                        DispatchQueue.main.asyncAfter(
                            deadline: .now() + Double(pow(2, Double(retryCount)))
                        ) {
                            retry()
                        }
                    }
                }

            case .empty:
                ProgressView()
                    .onAppear {
                        url = originalURL
                    }

            @unknown default:
                EmptyView()
            }
        }
    }

    private func retry() {
        retryCount += 1
        // Force reload by changing URL
        url = nil
        DispatchQueue.main.async {
            url = originalURL
        }
    }
}
```

### Fallback Image

```swift
struct FallbackImage: View {
    let primaryURL: URL?
    let fallbackURL: URL?
    @State private var useFallback = false

    var body: some View {
        PKSImage(url: useFallback ? fallbackURL : primaryURL) { phase in
            if let image = phase.image {
                image.resizable()
            } else if phase.error != nil && !useFallback {
                // Primary failed, try fallback
                Color.clear
                    .onAppear {
                        useFallback = true
                    }
            } else if phase.error != nil && useFallback {
                // Both failed, show error
                Image(systemName: "photo")
                    .foregroundColor(.red)
            } else {
                ProgressView()
            }
        }
    }
}
```

## Advanced Configurations

### Custom Cache Per Image

```swift
PKSImage(url: imageURL)
    .cacheConfiguration(
        PKSImageCacheConfiguration(
            memoryCache: .aggressive,
            diskCache: .conservative,
            policy: .automatic,
            isProgressiveDecodingEnabled: true
        )
    )
```

### Priority-Based Loading

```swift
struct PriorityGallery: View {
    let images: [(url: URL, priority: PKSImagePriority)]

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(images, id: \.url) { item in
                    PKSImage(url: item.url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                    }
                    .priority(item.priority)
                    .frame(height: 200)
                }
            }
        }
    }
}
```

## Performance Optimization

### Lazy Loading in Lists

```swift
struct OptimizedList: View {
    let items: [ImageItem]

    var body: some View {
        List(items) { item in
            HStack {
                PKSImage(url: item.thumbnailURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                }
                .frame(width: 60, height: 60)
                .clipped()
                .priority(.high) // Visible items are high priority

                VStack(alignment: .leading) {
                    Text(item.title)
                        .font(.headline)
                    Text(item.subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
            .padding(.vertical, 4)
            .onAppear {
                // Prefetch next items
                prefetchNextItems(after: item)
            }
        }
    }

    private func prefetchNextItems(after item: ImageItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }

        let nextItems = items.dropFirst(index + 1).prefix(5)
        let urls = nextItems.compactMap { $0.thumbnailURL }

        PKSImageManager.prefetch(urls: urls, priority: .low)
    }
}
```

## Best Practices Summary

1. **Always handle all loading phases** for the best user experience
2. **Use appropriate priorities** based on content visibility
3. **Implement progress indicators** for large images
4. **Cache strategically** based on image importance and size
5. **Prefetch intelligently** in scrollable content
6. **Provide meaningful error states** with recovery options
7. **Add transitions** for smooth visual feedback
8. **Monitor status changes** for analytics or debugging

## See Also

- <doc:PKSImageGettingStarted>
- <doc:PKSImageCacheConfiguration>
- <doc:PKSImagePrefetchingGuide>
- <doc:PKSImagePerformanceOptimization>
