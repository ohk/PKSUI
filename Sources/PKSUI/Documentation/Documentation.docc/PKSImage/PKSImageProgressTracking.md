# PKSImage Progress Tracking

Monitor and display real-time image download progress for enhanced user feedback.

## Overview

`PKSImageProgress` provides detailed information about ongoing image downloads, including bytes transferred, total size, completion percentage, and cache status. This enables you to create rich, informative loading experiences that keep users engaged during image downloads.

## Understanding PKSImageProgress

### Progress Properties

```swift
public struct PKSImageProgress {
    /// Total size of the image in bytes (nil if unknown)
    public let totalBytes: Int64?

    /// Number of bytes downloaded so far
    public let downloadedBytes: Int64

    /// Whether the image was loaded from cache
    public let isFromCache: Bool

    /// Fraction of download completed (0.0 to 1.0)
    public var fractionCompleted: Double

    /// Total size in kilobytes
    public var totalKB: Double?

    /// Downloaded size in kilobytes
    public var downloadedKB: Double
}
```

## Basic Progress Tracking

### Simple Progress Display

```swift
struct SimpleProgressImage: View {
    let url: URL?
    @State private var progress: Double = 0

    var body: some View {
        PKSImage(url: url) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
        } placeholder: {
            ZStack {
                Color.gray.opacity(0.1)

                VStack {
                    ProgressView(value: progress)
                        .progressViewStyle(LinearProgressViewStyle())

                    Text("\(Int(progress * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
        }
        .onProgress { imageProgress in
            withAnimation {
                progress = imageProgress.fractionCompleted
            }
        }
    }
}
```

### Detailed Progress Information

```swift
struct DetailedProgressView: View {
    let url: URL?
    @State private var progressInfo = ProgressInfo()

    struct ProgressInfo {
        var downloadedKB: Double = 0
        var totalKB: Double?
        var percentage: Int = 0
        var isFromCache = false
        var downloadSpeed: Double = 0
    }

    var body: some View {
        PKSImage(url: url) { image in
            image.resizable()
        } placeholder: {
            VStack(spacing: 16) {
                if !progressInfo.isFromCache {
                    // Progress ring
                    ProgressRing(progress: Double(progressInfo.percentage) / 100)
                        .frame(width: 80, height: 80)

                    // Download details
                    VStack(spacing: 4) {
                        Text("\(progressInfo.percentage)%")
                            .font(.title2)
                            .fontWeight(.semibold)

                        HStack {
                            Text(formatBytes(progressInfo.downloadedKB * 1024))

                            if let total = progressInfo.totalKB {
                                Text("of \(formatBytes(total * 1024))")
                            }
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)

                        if progressInfo.downloadSpeed > 0 {
                            Text("\(formatSpeed(progressInfo.downloadSpeed))")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.green)

                    Text("Loaded from cache")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.gray.opacity(0.05))
        }
        .onProgress { progress in
            updateProgressInfo(progress)
        }
    }

    private func updateProgressInfo(_ progress: PKSImageProgress) {
        progressInfo.downloadedKB = progress.downloadedKB
        progressInfo.totalKB = progress.totalKB
        progressInfo.percentage = Int(progress.fractionCompleted * 100)
        progressInfo.isFromCache = progress.isFromCache

        // Calculate download speed (simplified)
        if progress.downloadedBytes > 0 {
            // This is a simplified calculation
            // In production, track time elapsed
            progressInfo.downloadSpeed = Double(progress.downloadedBytes) / 1024.0
        }
    }

    private func formatBytes(_ bytes: Double) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .binary
        return formatter.string(fromByteCount: Int64(bytes))
    }

    private func formatSpeed(_ kbps: Double) -> String {
        if kbps > 1024 {
            return String(format: "%.1f MB/s", kbps / 1024)
        } else {
            return String(format: "%.0f KB/s", kbps)
        }
    }
}
```

## Custom Progress Indicators

### Circular Progress Ring

```swift
struct ProgressRing: View {
    let progress: Double
    let lineWidth: CGFloat = 4

    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(
                    Color.gray.opacity(0.2),
                    lineWidth: lineWidth
                )

            // Progress ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(), value: progress)

            // Center text
            Text("\(Int(progress * 100))")
                .font(.system(.title3, design: .rounded))
                .fontWeight(.semibold)
        }
    }
}
```

### Wave Progress Indicator

```swift
struct WaveProgressView: View {
    let progress: Double
    @State private var phase: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Container
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.blue.opacity(0.3), lineWidth: 2)

                // Wave fill
                WaveShape(phase: phase, progress: progress)
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.6), .blue],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .mask(
                        RoundedRectangle(cornerRadius: 18)
                    )

                // Progress text
                VStack {
                    Text("\(Int(progress * 100))%")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("Loading")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .onAppear {
                withAnimation(
                    .linear(duration: 2)
                    .repeatForever(autoreverses: false)
                ) {
                    phase = .pi * 2
                }
            }
        }
    }
}

struct WaveShape: Shape {
    var phase: CGFloat
    var progress: Double

    var animatableData: AnimatablePair<CGFloat, Double> {
        get { AnimatablePair(phase, progress) }
        set {
            phase = newValue.first
            progress = newValue.second
        }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let waveHeight: CGFloat = 10
        let yOffset = rect.height * (1 - CGFloat(progress))

        path.move(to: CGPoint(x: 0, y: rect.height))

        for x in stride(from: 0, through: rect.width, by: 1) {
            let relativeX = x / rect.width
            let y = yOffset + sin(relativeX * .pi * 2 + phase) * waveHeight
            path.addLine(to: CGPoint(x: x, y: y))
        }

        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.closeSubpath()

        return path
    }
}
```

### Segmented Progress Bar

```swift
struct SegmentedProgressBar: View {
    let progress: Double
    let segments: Int = 10

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<segments, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(fillColor(for: index))
                    .frame(height: 8)
                    .animation(.easeInOut(duration: 0.3), value: progress)
            }
        }
    }

    private func fillColor(for index: Int) -> Color {
        let threshold = Double(index + 1) / Double(segments)
        if progress >= threshold {
            return .blue
        } else if progress > Double(index) / Double(segments) {
            return .blue.opacity(0.5)
        } else {
            return .gray.opacity(0.2)
        }
    }
}
```

## Advanced Progress Tracking

### Download Speed Calculation

```swift
class DownloadSpeedTracker: ObservableObject {
    @Published var currentSpeed: Double = 0
    @Published var averageSpeed: Double = 0
    @Published var estimatedTimeRemaining: TimeInterval?

    private var startTime: Date?
    private var lastUpdateTime: Date?
    private var lastBytes: Int64 = 0
    private var speedHistory: [Double] = []

    func update(with progress: PKSImageProgress) {
        let now = Date()

        if startTime == nil {
            startTime = now
        }

        if let lastTime = lastUpdateTime, lastBytes > 0 {
            let timeDiff = now.timeIntervalSince(lastTime)
            let bytesDiff = progress.downloadedBytes - lastBytes

            if timeDiff > 0 {
                // Calculate current speed in bytes per second
                currentSpeed = Double(bytesDiff) / timeDiff

                // Track speed history for average
                speedHistory.append(currentSpeed)
                if speedHistory.count > 10 {
                    speedHistory.removeFirst()
                }

                // Calculate average speed
                averageSpeed = speedHistory.reduce(0, +) / Double(speedHistory.count)

                // Estimate time remaining
                if let total = progress.totalBytes, averageSpeed > 0 {
                    let remainingBytes = total - progress.downloadedBytes
                    estimatedTimeRemaining = Double(remainingBytes) / averageSpeed
                }
            }
        }

        lastUpdateTime = now
        lastBytes = progress.downloadedBytes
    }

    func reset() {
        startTime = nil
        lastUpdateTime = nil
        lastBytes = 0
        speedHistory.removeAll()
        currentSpeed = 0
        averageSpeed = 0
        estimatedTimeRemaining = nil
    }
}
```

### Progress with Speed Display

```swift
struct ProgressWithSpeed: View {
    let url: URL?
    @StateObject private var speedTracker = DownloadSpeedTracker()
    @State private var progress: Double = 0

    var body: some View {
        PKSImage(url: url) { image in
            image.resizable()
        } placeholder: {
            VStack(spacing: 20) {
                // Main progress
                CircularProgressView(progress: progress)
                    .frame(width: 100, height: 100)

                // Speed information
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "speedometer")
                        Text(formatSpeed(speedTracker.currentSpeed))
                    }
                    .font(.caption)

                    if let eta = speedTracker.estimatedTimeRemaining {
                        HStack {
                            Image(systemName: "clock")
                            Text(formatTime(eta))
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12)
        }
        .onProgress { imageProgress in
            progress = imageProgress.fractionCompleted
            speedTracker.update(with: imageProgress)
        }
    }

    private func formatSpeed(_ bytesPerSecond: Double) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .binary
        let speed = formatter.string(fromByteCount: Int64(bytesPerSecond))
        return "\(speed)/s"
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        if seconds < 60 {
            return "\(Int(seconds))s"
        } else if seconds < 3600 {
            return "\(Int(seconds / 60))m \(Int(seconds.truncatingRemainder(dividingBy: 60)))s"
        } else {
            return ">1h"
        }
    }
}
```

### Multi-Image Progress Tracking

```swift
class BatchProgressTracker: ObservableObject {
    struct ImageProgress: Identifiable {
        let id = UUID()
        let url: URL
        var progress: Double = 0
        var isComplete = false
        var error: Error?
    }

    @Published var images: [ImageProgress] = []

    var overallProgress: Double {
        guard !images.isEmpty else { return 0 }
        let total = images.map { $0.progress }.reduce(0, +)
        return total / Double(images.count)
    }

    var completedCount: Int {
        images.filter { $0.isComplete }.count
    }

    func track(url: URL) {
        images.append(ImageProgress(url: url))
    }

    func update(url: URL, progress: Double) {
        if let index = images.firstIndex(where: { $0.url == url }) {
            images[index].progress = progress
            images[index].isComplete = progress >= 1.0
        }
    }

    func setError(url: URL, error: Error) {
        if let index = images.firstIndex(where: { $0.url == url }) {
            images[index].error = error
            images[index].isComplete = true
        }
    }
}

struct BatchImageLoader: View {
    let urls: [URL]
    @StateObject private var tracker = BatchProgressTracker()

    var body: some View {
        VStack {
            // Overall progress
            VStack(alignment: .leading) {
                Text("Loading \(tracker.completedCount) of \(urls.count) images")
                    .font(.headline)

                ProgressView(value: tracker.overallProgress)
                    .progressViewStyle(LinearProgressViewStyle())

                Text("\(Int(tracker.overallProgress * 100))% complete")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()

            // Individual images
            ScrollView {
                LazyVStack {
                    ForEach(urls, id: \.self) { url in
                        HStack {
                            PKSImage(url: url) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            } placeholder: {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                            }
                            .frame(width: 60, height: 60)
                            .onProgress { progress in
                                tracker.update(
                                    url: url,
                                    progress: progress.fractionCompleted
                                )
                            }
                            .onCompletion { result in
                                if case .failure(let error) = result {
                                    tracker.setError(url: url, error: error)
                                }
                            }

                            VStack(alignment: .leading) {
                                Text(url.lastPathComponent)
                                    .font(.caption)
                                    .lineLimit(1)

                                if let imageProgress = tracker.images.first(where: { $0.url == url }) {
                                    if let error = imageProgress.error {
                                        Text("Failed")
                                            .font(.caption2)
                                            .foregroundColor(.red)
                                    } else {
                                        ProgressView(value: imageProgress.progress)
                                            .progressViewStyle(LinearProgressViewStyle())
                                    }
                                }
                            }

                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
        .onAppear {
            urls.forEach { tracker.track(url: $0) }
        }
    }
}
```

## Cache Status Indication

### Cache-Aware Progress View

```swift
struct CacheAwareProgressView: View {
    let url: URL?
    @State private var loadingState = LoadingState()

    struct LoadingState {
        var isFromCache = false
        var progress: Double = 0
        var cacheType: CacheType = .none

        enum CacheType {
            case none, memory, disk
        }
    }

    var body: some View {
        PKSImage(url: url) { image in
            image
                .resizable()
                .overlay(alignment: .topTrailing) {
                    if loadingState.isFromCache {
                        CacheBadge(type: loadingState.cacheType)
                            .padding(8)
                    }
                }
        } placeholder: {
            LoadingPlaceholder(state: loadingState)
        }
        .onProgress { progress in
            loadingState.progress = progress.fractionCompleted
            loadingState.isFromCache = progress.isFromCache

            // Determine cache type based on load speed
            if progress.isFromCache {
                if progress.fractionCompleted == 1.0 && progress.downloadedBytes > 0 {
                    // Instant load usually means memory cache
                    loadingState.cacheType = .memory
                } else {
                    // Slower cache load usually means disk
                    loadingState.cacheType = .disk
                }
            }
        }
    }
}

struct CacheBadge: View {
    let type: CacheAwareProgressView.LoadingState.CacheType

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)

            Text(label)
                .font(.caption2)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(backgroundColor)
        .foregroundColor(.white)
        .cornerRadius(4)
    }

    private var icon: String {
        switch type {
        case .memory:
            return "memorychip"
        case .disk:
            return "internaldrive"
        case .none:
            return "network"
        }
    }

    private var label: String {
        switch type {
        case .memory:
            return "Memory"
        case .disk:
            return "Disk"
        case .none:
            return "Network"
        }
    }

    private var backgroundColor: Color {
        switch type {
        case .memory:
            return .green
        case .disk:
            return .blue
        case .none:
            return .orange
        }
    }
}

struct LoadingPlaceholder: View {
    let state: CacheAwareProgressView.LoadingState

    var body: some View {
        ZStack {
            Color.gray.opacity(0.1)

            if state.isFromCache {
                VStack {
                    Image(systemName: "bolt.fill")
                        .font(.largeTitle)
                        .foregroundColor(.green)

                    Text("Loading from cache")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else {
                VStack {
                    ProgressView(value: state.progress)
                        .progressViewStyle(CircularProgressViewStyle())

                    Text("\(Int(state.progress * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
        }
    }
}
```

## Best Practices

### DO's

1. **Show progress for large images** - Users appreciate feedback during long downloads
2. **Indicate cache hits** - Let users know when content loads instantly
3. **Display download speed** for very large files
4. **Use smooth animations** for progress updates
5. **Provide time estimates** when possible

### DON'Ts

1. **Don't show progress for tiny images** - It adds unnecessary UI complexity
2. **Don't update too frequently** - Throttle updates to avoid UI jank
3. **Don't show misleading progress** - If size is unknown, use indeterminate indicators
4. **Don't forget error states** - Always handle failed downloads gracefully
5. **Don't block interaction** - Let users cancel or navigate away

## Performance Considerations

### Throttling Progress Updates

```swift
class ThrottledProgressHandler {
    private var lastUpdateTime: Date?
    private let minimumInterval: TimeInterval = 0.1 // 100ms

    func handleProgress(_ progress: PKSImageProgress, action: (PKSImageProgress) -> Void) {
        let now = Date()

        if let last = lastUpdateTime,
           now.timeIntervalSince(last) < minimumInterval {
            return // Skip this update
        }

        lastUpdateTime = now
        action(progress)
    }
}
```

## See Also

- ``PKSImageProgress``
- ``PKSImageStatus``
- <doc:PKSImageBasicUsage>
- <doc:PKSImagePerformanceOptimization>
