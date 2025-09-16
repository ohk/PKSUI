# PKSImage Troubleshooting

Diagnose and resolve common issues with PKSImage, from loading failures to performance problems.

## Overview

This comprehensive troubleshooting guide helps you identify, diagnose, and resolve issues with PKSImage. Whether you're dealing with images that won't load, performance problems, or unexpected behavior, this guide provides solutions and debugging techniques.

## Common Issues and Solutions

### Images Not Loading

#### Issue: Images show placeholder but never load

**Symptoms:**
- Placeholder appears indefinitely
- No error state shown
- No network activity detected

**Possible Causes & Solutions:**

```swift
// 1. Check URL validity
PKSImage(url: imageURL)
    .onCompletion { result in
        switch result {
        case .failure(let error):
            print("❌ Load failed: \(error)")
            // Common errors:
            // - Invalid URL
            // - URL is nil
            // - Malformed URL string
        case .success:
            print("✅ Load succeeded")
        }
    }

// 2. Verify network connectivity
import Network

class NetworkChecker {
    static func checkConnectivity() {
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                print("✅ Network available")
            } else {
                print("❌ No network connection")
            }
        }
        monitor.start(queue: .global())
    }
}

// 3. Check for HTTPS requirement (iOS 14+)
// Add to Info.plist if using HTTP:
/*
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
*/

// 4. Debug with status monitoring
PKSImage(url: imageURL)
    .onStatusChange { status in
        print("Status: \(status)")
        switch status {
        case .idle:
            print("Not started")
        case .loading(let progress):
            print("Loading: \(progress.fractionCompleted * 100)%")
        case .success:
            print("Loaded successfully")
        case .failure(let error):
            print("Failed: \(error.localizedDescription)")
        case .cancelled:
            print("Cancelled")
        }
    }
```

#### Issue: Images load in simulator but not on device

**Solutions:**

```swift
// 1. Check for case-sensitive URLs
// iOS devices are case-sensitive, simulators may not be
let url = URL(string: "https://example.com/Image.jpg") // Exact case

// 2. Verify SSL certificate
// Self-signed certificates need special handling
class CustomSessionDelegate: NSObject, URLSessionDelegate {
    func urlSession(_ session: URLSession,
                   didReceive challenge: URLAuthenticationChallenge,
                   completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        // Handle self-signed certificates (DEVELOPMENT ONLY)
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(.useCredential, credential)
        }
    }
}

// 3. Check memory constraints
// Devices have less memory than simulators
PKSImage(url: imageURL)
    .cacheConfiguration(.conservative) // Use less memory
```

### Performance Issues

#### Issue: Slow image loading

**Diagnostic Steps:**

```swift
struct PerformanceDiagnostic: View {
    let url: URL?
    @State private var loadTime: TimeInterval = 0
    @State private var fromCache = false

    var body: some View {
        let startTime = Date()

        return PKSImage(url: url) { image in
            image.resizable()
        } placeholder: {
            ProgressView()
        }
        .onProgress { progress in
            fromCache = progress.isFromCache
        }
        .onCompletion { _ in
            loadTime = Date().timeIntervalSince(startTime)
            diagnosePerformance()
        }
    }

    private func diagnosePerformance() {
        print("""
        Performance Analysis:
        - Load time: \(String(format: "%.2f", loadTime))s
        - From cache: \(fromCache)
        - Expected: < 0.1s (cache) or < 2s (network)

        Recommendations:
        \(getRecommendations())
        """)
    }

    private func getRecommendations() -> String {
        if loadTime > 3 && !fromCache {
            return """
            • Image size may be too large
            • Check network speed
            • Consider using lower resolution
            • Enable prefetching
            """
        } else if loadTime > 0.5 && fromCache {
            return """
            • Disk I/O may be slow
            • Consider using memory cache
            • Check device storage space
            """
        }
        return "Performance is acceptable"
    }
}
```

**Optimization Solutions:**

```swift
// 1. Implement size-appropriate loading
func optimizedImageURL(for size: CGSize) -> URL? {
    guard let baseURL = originalURL else { return nil }

    // Request appropriately sized image
    var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
    let scale = UIScreen.main.scale
    components?.queryItems = [
        URLQueryItem(name: "w", value: "\(Int(size.width * scale))"),
        URLQueryItem(name: "h", value: "\(Int(size.height * scale))")
    ]
    return components?.url
}

// 2. Use aggressive caching for frequently accessed images
PKSImage(url: frequentlyUsedImageURL)
    .cacheConfiguration(.aggressive)
    .priority(.high)

// 3. Prefetch upcoming images
ScrollView {
    LazyVStack {
        ForEach(items.indices, id: \.self) { index in
            ImageRow(item: items[index])
                .onAppear {
                    // Prefetch next 5 images
                    let upcoming = items[index+1..<min(index+6, items.count)]
                    let urls = upcoming.compactMap { $0.imageURL }
                    PKSImageManager.prefetch(urls: urls, priority: .low)
                }
        }
    }
}
```

### Memory Issues

#### Issue: App crashes or receives memory warnings

**Diagnostic Code:**

```swift
class MemoryDiagnostic: ObservableObject {
    @Published var memoryUsage: String = ""
    @Published var cacheSize: String = ""

    func diagnose() {
        // Get memory usage
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4

        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }

        if result == KERN_SUCCESS {
            let usedMB = Double(info.resident_size) / 1024.0 / 1024.0
            memoryUsage = String(format: "%.1f MB", usedMB)
        }

        // Get cache size
        let manager = PKSImageCacheManager.shared
        let (memory, disk) = (manager.memoryCacheSize, manager.diskCacheSize)
        cacheSize = "Memory: \(memory / 1024 / 1024)MB, Disk: \(disk / 1024 / 1024)MB"

        print("""
        Memory Diagnostic:
        - App Memory: \(memoryUsage)
        - Cache: \(cacheSize)
        - Available: \(ProcessInfo.processInfo.physicalMemory / 1024 / 1024)MB
        """)
    }
}
```

**Solutions:**

```swift
// 1. Implement memory pressure handling
class MemoryManager {
    static func setupMemoryWarningHandler() {
        #if os(iOS) || os(tvOS)
        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { _ in
            handleMemoryWarning()
        }
        #endif
    }

    static func handleMemoryWarning() {
        // Clear memory cache
        PKSImageCacheManager.shared.clearMemoryCache()

        // Cancel non-essential prefetches
        PKSImageManager.cancelAllPrefetches()

        // Switch to conservative configuration
        PKSImageCacheManager.shared.configure(with: .conservative)

        print("⚠️ Memory warning handled")
    }
}

// 2. Use appropriate cache configuration
let deviceMemory = ProcessInfo.processInfo.physicalMemory
let configuration: PKSImageCacheConfiguration

if deviceMemory < 2 * 1024 * 1024 * 1024 { // < 2GB
    configuration = .conservative
} else if deviceMemory < 4 * 1024 * 1024 * 1024 { // < 4GB
    configuration = .default
} else {
    configuration = .aggressive
}

PKSImageCacheManager.shared.configure(with: configuration)

// 3. Downsample large images
struct DownsampledImageView: View {
    let url: URL?
    let targetSize: CGSize

    var body: some View {
        GeometryReader { geometry in
            PKSImage(url: url)
                .cacheConfiguration(
                    PKSImageCacheConfiguration(
                        memoryCache: .conservative,
                        diskCache: .default,
                        policy: .diskOnly // Prefer disk for large images
                    )
                )
        }
    }
}
```

### Cache Issues

#### Issue: Images not caching properly

**Diagnostic Tools:**

```swift
struct CacheDiagnostic {
    static func diagnose(url: URL) {
        let manager = PKSImageCacheManager.shared

        print("""
        Cache Diagnostic for: \(url.lastPathComponent)
        =====================================
        Cached: \(manager.isCached(url: url))
        Memory Cache Size: \(manager.memoryCacheSize / 1024)KB
        Disk Cache Size: \(manager.diskCacheSize / 1024 / 1024)MB
        Configuration: \(manager.currentConfiguration)
        """)

        // Test cache operations
        testCacheOperations(url: url)
    }

    static func testCacheOperations(url: URL) {
        // Test store and retrieve
        let testData = Data("test".utf8)

        // Store in cache
        manager.store(testData, for: url)

        // Retrieve from cache
        if let retrieved = manager.retrieve(for: url) {
            print("✅ Cache store/retrieve working")
        } else {
            print("❌ Cache store/retrieve failed")
        }

        // Check cache location
        checkCacheLocation()
    }

    static func checkCacheLocation() {
        let cacheDir = FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        ).first!

        do {
            let contents = try FileManager.default.contentsOfDirectory(
                at: cacheDir,
                includingPropertiesForKeys: [.fileSizeKey]
            )
            print("Cache directory contents: \(contents.count) items")
        } catch {
            print("❌ Cannot access cache directory: \(error)")
        }
    }
}
```

**Solutions:**

```swift
// 1. Ensure cache is not disabled
PKSImage(url: imageURL)
    .cacheConfiguration(.default) // Not .disabled

// 2. Check cache configuration
if PKSImageCacheManager.shared.currentConfiguration == .disabled {
    PKSImageCacheManager.shared.configure(with: .default)
}

// 3. Verify disk space
struct DiskSpaceChecker {
    static var availableSpace: Int64 {
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

    static func hasEnoughSpace() -> Bool {
        return availableSpace > 100 * 1024 * 1024 // 100MB minimum
    }
}
```

## Debugging Techniques

### Enable Verbose Logging

```swift
extension PKSImage {
    func verboseDebug(_ label: String = "") -> some View {
        self
            .onStatusChange { status in
                print("[\(label)] Status: \(status)")
            }
            .onProgress { progress in
                print("[\(label)] Progress: \(progress.fractionCompleted * 100)%")
                print("[\(label)] From cache: \(progress.isFromCache)")
            }
            .onCompletion { result in
                switch result {
                case .success:
                    print("[\(label)] ✅ Success")
                case .failure(let error):
                    print("[\(label)] ❌ Error: \(error)")
                }
            }
    }
}

// Usage
PKSImage(url: imageURL)
    .verboseDebug("ProductImage")
```

### Network Debugging

```swift
class NetworkDebugger {
    static func enableNetworkLogging() {
        // Use Charles Proxy or similar
        // Set proxy in Network settings

        // Or implement URLSession logging
        URLSession.shared.configuration.urlCache?.removeAllCachedResponses()

        // Log all requests
        class LoggingDelegate: NSObject, URLSessionTaskDelegate {
            func urlSession(_ session: URLSession,
                          task: URLSessionTask,
                          didFinishCollecting metrics: URLSessionTaskMetrics) {
                print("""
                Network Request:
                URL: \(task.originalRequest?.url?.absoluteString ?? "")
                Duration: \(metrics.taskInterval.duration)s
                Redirects: \(metrics.redirectCount)
                """)
            }
        }
    }
}
```

### Performance Profiling

```swift
struct PerformanceProfiler: View {
    let url: URL?
    @State private var metrics = LoadMetrics()

    struct LoadMetrics {
        var startTime: Date?
        var firstByteTime: Date?
        var completionTime: Date?
        var decodingTime: TimeInterval = 0
        var renderTime: TimeInterval = 0
    }

    var body: some View {
        PKSImage(url: url) { phase in
            Group {
                switch phase {
                case .empty:
                    Color.gray
                        .onAppear { metrics.startTime = Date() }
                case .success(let image):
                    image
                        .onAppear { recordSuccess() }
                case .failure:
                    Color.red
                        .onAppear { recordFailure() }
                @unknown default:
                    EmptyView()
                }
            }
        }
        .onProgress { progress in
            if metrics.firstByteTime == nil && progress.downloadedBytes > 0 {
                metrics.firstByteTime = Date()
            }
        }
    }

    private func recordSuccess() {
        metrics.completionTime = Date()
        generateReport()
    }

    private func recordFailure() {
        print("❌ Load failed after \(Date().timeIntervalSince(metrics.startTime ?? Date()))s")
    }

    private func generateReport() {
        guard let start = metrics.startTime,
              let completion = metrics.completionTime else { return }

        let totalTime = completion.timeIntervalSince(start)
        let ttfb = metrics.firstByteTime?.timeIntervalSince(start) ?? 0

        print("""
        Performance Profile:
        ====================
        Total Time: \(String(format: "%.3f", totalTime))s
        Time to First Byte: \(String(format: "%.3f", ttfb))s
        Download Time: \(String(format: "%.3f", totalTime - ttfb))s

        Performance Grade: \(getGrade(for: totalTime))
        """)
    }

    private func getGrade(for time: TimeInterval) -> String {
        switch time {
        case ..<0.5: return "A+ (Excellent)"
        case ..<1.0: return "A (Very Good)"
        case ..<2.0: return "B (Good)"
        case ..<3.0: return "C (Acceptable)"
        case ..<5.0: return "D (Poor)"
        default: return "F (Unacceptable)"
        }
    }
}
```

## Error Recovery Strategies

### Automatic Retry

```swift
struct RetryableImage: View {
    let url: URL?
    @State private var attempt = 0
    @State private var loadFailed = false

    let maxRetries = 3
    let retryDelay: TimeInterval = 2

    var body: some View {
        PKSImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .onAppear { attempt = 0 } // Reset on success

            case .failure(let error):
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.orange)

                    Text("Load failed")
                        .font(.caption)

                    if attempt < maxRetries {
                        ProgressView()
                            .onAppear { scheduleRetry() }
                    } else {
                        Button("Retry") {
                            attempt = 0
                            loadFailed = false
                        }
                    }
                }
                .onAppear {
                    print("Attempt \(attempt + 1) failed: \(error)")
                    loadFailed = true
                }

            case .empty:
                ProgressView()

            @unknown default:
                EmptyView()
            }
        }
        .id(attempt) // Force reload on retry
    }

    private func scheduleRetry() {
        DispatchQueue.main.asyncAfter(deadline: .now() + retryDelay) {
            if loadFailed {
                attempt += 1
                loadFailed = false
            }
        }
    }
}
```

### Fallback Images

```swift
struct FallbackImage: View {
    let primaryURL: URL?
    let fallbackURL: URL?
    let placeholderName: String

    @State private var currentURL: URL?
    @State private var failureCount = 0

    var body: some View {
        PKSImage(url: currentURL) { phase in
            switch phase {
            case .success(let image):
                image.resizable()

            case .failure:
                Image(systemName: placeholderName)
                    .font(.largeTitle)
                    .foregroundColor(.gray)
                    .onAppear { tryFallback() }

            case .empty:
                ProgressView()
                    .onAppear { currentURL = primaryURL }

            @unknown default:
                EmptyView()
            }
        }
    }

    private func tryFallback() {
        failureCount += 1

        if failureCount == 1 && fallbackURL != nil {
            // Try fallback URL
            currentURL = fallbackURL
        }
        // After fallback fails, show placeholder
    }
}
```

## Platform-Specific Issues

### iOS/iPadOS

```swift
// Handle scene-based lifecycle
class SceneAwareImageCache {
    static func setupSceneHandlers() {
        NotificationCenter.default.addObserver(
            forName: UIScene.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { _ in
            // Reduce cache size when entering background
            PKSImageCacheManager.shared.configure(with: .conservative)
        }

        NotificationCenter.default.addObserver(
            forName: UIScene.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { _ in
            // Restore cache configuration
            PKSImageCacheManager.shared.configure(with: .default)
        }
    }
}
```

### macOS

```swift
#if os(macOS)
// Handle window focus changes
class WindowAwareImageLoader {
    static func adjustPriorityForWindow(_ window: NSWindow?) {
        NotificationCenter.default.addObserver(
            forName: NSWindow.didBecomeKeyNotification,
            object: window,
            queue: .main
        ) { _ in
            // Increase priority for active window
            // Implement priority adjustment
        }
    }
}
#endif
```

## Diagnostic Checklist

### Quick Diagnostic Steps

1. **Verify URL**
   ```swift
   print("URL: \(imageURL?.absoluteString ?? "nil")")
   ```

2. **Check Network**
   ```swift
   URLSession.shared.dataTask(with: imageURL!) { data, response, error in
       print("Network test: \(error == nil ? "✅" : "❌")")
   }.resume()
   ```

3. **Test Cache**
   ```swift
   PKSImageCacheManager.shared.isCached(url: imageURL!)
   ```

4. **Monitor Memory**
   ```swift
   print("Memory: \(ProcessInfo.processInfo.physicalMemory / 1024 / 1024)MB")
   ```

5. **Check Configuration**
   ```swift
   print("Config: \(PKSImageCacheManager.shared.currentConfiguration)")
   ```

## Getting Help

If you continue to experience issues:

1. **Enable verbose logging** using the debug methods above
2. **Collect diagnostic information** using the provided tools
3. **Check the documentation** for configuration options
4. **File an issue** with diagnostic output at the project repository

Include in your report:
- Device/OS version
- PKSImage version
- Diagnostic output
- Sample code reproducing the issue
- Network conditions

## See Also

- <doc:PKSImagePerformanceOptimization>
- <doc:PKSImageCacheConfiguration>
- <doc:PKSImageBasicUsage>
- <doc:PKSImageMigrationFromAsyncImage>
