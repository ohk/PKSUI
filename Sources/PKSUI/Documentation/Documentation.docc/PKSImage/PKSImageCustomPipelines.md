# PKSImage Custom Pipelines

Create specialized image processing pipelines for advanced transformations, filters, and optimizations.

## Overview

Custom pipelines in PKSImage enable you to create sophisticated image processing workflows tailored to your specific needs. From applying filters and transformations to implementing custom caching strategies, pipelines provide complete control over the image loading process.

## Understanding Image Pipelines

### Pipeline Architecture

```
┌─────────────────────────────────────────────────┐
│                  Image Pipeline                  │
│                                                  │
│  ┌──────────┐  ┌──────────┐  ┌──────────────┐  │
│  │  Fetch   │─►│  Decode  │─►│  Transform   │  │
│  └──────────┘  └──────────┘  └──────────────┘  │
│       │             │              │            │
│       ▼             ▼              ▼            │
│  ┌──────────┐  ┌──────────┐  ┌──────────────┐  │
│  │  Cache   │  │ Progress │  │   Display    │  │
│  └──────────┘  └──────────┘  └──────────────┘  │
└─────────────────────────────────────────────────┘
```

## Creating Custom Pipelines

### Basic Custom Pipeline

```swift
import Nuke
import NukeUI

class CustomImagePipeline {
    static func create() -> ImagePipeline {
        var configuration = ImagePipeline.Configuration()

        // Custom data loader
        configuration.dataLoader = customDataLoader()

        // Custom data cache
        configuration.dataCache = customDataCache()

        // Custom image cache
        configuration.imageCache = customImageCache()

        // Custom processors
        configuration.makeImageDecoder = { context in
            CustomImageDecoder(context: context)
        }

        // Progressive decoding
        configuration.isProgressiveDecodingEnabled = true

        // Resumable data
        configuration.isResumableDataEnabled = true

        // Task coalescing
        configuration.isTaskCoalescingEnabled = true

        return ImagePipeline(configuration: configuration)
    }

    private static func customDataLoader() -> DataLoader {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        configuration.httpMaximumConnectionsPerHost = 6

        // Custom headers
        configuration.httpAdditionalHeaders = [
            "User-Agent": "PKSImage/1.0",
            "Accept": "image/*"
        ]

        return DataLoader(configuration: configuration)
    }

    private static func customDataCache() -> DataCache? {
        let cachesURL = FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        ).first!

        let dataCache = try? DataCache(
            path: cachesURL.appendingPathComponent("com.pksui.imagecache").path
        )

        // Configure size limits
        dataCache?.sizeLimit = 500 * 1024 * 1024 // 500 MB

        return dataCache
    }

    private static func customImageCache() -> ImageCache {
        let cache = ImageCache()
        cache.costLimit = 200 * 1024 * 1024 // 200 MB
        cache.countLimit = 100
        cache.ttl = 300 // 5 minutes
        return cache
    }
}
```

### Image Processing Pipeline

```swift
class ImageProcessingPipeline {
    enum ProcessingOption {
        case resize(CGSize)
        case crop(CGRect)
        case roundCorners(CGFloat)
        case blur(radius: CGFloat)
        case grayscale
        case sepia
        case adjustColors(brightness: CGFloat, contrast: CGFloat, saturation: CGFloat)
        case watermark(image: UIImage, position: CGPoint, alpha: CGFloat)
    }

    static func createProcessor(options: [ProcessingOption]) -> ImageProcessing {
        return ImageProcessors.Composition(processors: options.map { option in
            switch option {
            case .resize(let size):
                return ImageProcessors.Resize(size: size)

            case .crop(let rect):
                return ImageProcessors.Crop(rect: rect)

            case .roundCorners(let radius):
                return ImageProcessors.RoundedCorners(radius: radius)

            case .blur(let radius):
                return BlurProcessor(radius: radius)

            case .grayscale:
                return GrayscaleProcessor()

            case .sepia:
                return SepiaProcessor()

            case .adjustColors(let brightness, let contrast, let saturation):
                return ColorAdjustmentProcessor(
                    brightness: brightness,
                    contrast: contrast,
                    saturation: saturation
                )

            case .watermark(let image, let position, let alpha):
                return WatermarkProcessor(
                    watermark: image,
                    position: position,
                    alpha: alpha
                )
            }
        })
    }
}

// Custom Processors

struct BlurProcessor: ImageProcessing {
    let radius: CGFloat

    func process(_ image: UIImage) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }

        let filter = CIFilter(name: "CIGaussianBlur")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setValue(radius, forKey: kCIInputRadiusKey)

        guard let outputImage = filter?.outputImage else { return nil }

        let context = CIContext()
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }

        return UIImage(cgImage: cgImage)
    }

    var identifier: String {
        "blur-\(radius)"
    }
}

struct GrayscaleProcessor: ImageProcessing {
    func process(_ image: UIImage) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }

        let filter = CIFilter(name: "CIColorMonochrome")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setValue(CIColor.gray, forKey: kCIInputColorKey)
        filter?.setValue(1.0, forKey: kCIInputIntensityKey)

        guard let outputImage = filter?.outputImage else { return nil }

        let context = CIContext()
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }

        return UIImage(cgImage: cgImage)
    }

    var identifier: String { "grayscale" }
}
```

### Specialized Pipelines

#### Thumbnail Pipeline

```swift
class ThumbnailPipeline {
    static func create() -> ImagePipeline {
        var configuration = ImagePipeline.Configuration()

        // Optimize for small images
        configuration.dataCachePolicy = .automatic

        // Aggressive memory caching for thumbnails
        let imageCache = ImageCache()
        imageCache.costLimit = 100 * 1024 * 1024 // 100 MB
        imageCache.countLimit = 500 // Many small images
        configuration.imageCache = imageCache

        // Thumbnail processor
        configuration.makeImageDecoder = { context in
            ImageDecoders.Default(context: context)
        }

        // Disable progressive loading for small images
        configuration.isProgressiveDecodingEnabled = false

        return ImagePipeline(configuration: configuration)
    }

    static func thumbnailProcessor(size: CGSize) -> ImageProcessing {
        return ImageProcessors.Composition([
            ImageProcessors.Resize(
                size: size,
                contentMode: .aspectFill
            ),
            ImageProcessors.RoundedCorners(radius: 8)
        ])
    }
}
```

#### High-Quality Pipeline

```swift
class HighQualityPipeline {
    static func create() -> ImagePipeline {
        var configuration = ImagePipeline.Configuration()

        // No size limits for high quality
        configuration.imageCache?.costLimit = 500 * 1024 * 1024 // 500 MB

        // Custom decoder for maximum quality
        configuration.makeImageDecoder = { context in
            HighQualityImageDecoder(context: context)
        }

        // Enable progressive loading for better UX
        configuration.isProgressiveDecodingEnabled = true
        configuration.isStoringPreviewsInMemoryCache = true

        return ImagePipeline(configuration: configuration)
    }
}

class HighQualityImageDecoder: ImageDecoding {
    private let context: ImageDecodingContext

    init(context: ImageDecodingContext) {
        self.context = context
    }

    func decode(_ data: Data) throws -> UIImage {
        guard let image = UIImage(data: data) else {
            throw ImageDecodingError.invalidData
        }

        // Ensure maximum quality
        UIGraphicsBeginImageContextWithOptions(
            image.size,
            false,
            UIScreen.main.scale
        )

        image.draw(at: .zero)
        let highQualityImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return highQualityImage ?? image
    }

    enum ImageDecodingError: Error {
        case invalidData
    }
}
```

#### Security Pipeline

```swift
class SecurePipeline {
    static func create(authToken: String) -> ImagePipeline {
        var configuration = ImagePipeline.Configuration()

        // Custom data loader with authentication
        configuration.dataLoader = AuthenticatedDataLoader(token: authToken)

        // Encrypted cache
        configuration.dataCache = EncryptedDataCache()

        // Memory-only for sensitive images
        configuration.imageCache = ImageCache()
        configuration.dataCachePolicy = .storeEncodedImages

        return ImagePipeline(configuration: configuration)
    }
}

class AuthenticatedDataLoader: DataLoading {
    private let token: String
    private let session: URLSession

    init(token: String) {
        self.token = token

        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = [
            "Authorization": "Bearer \(token)"
        ]

        self.session = URLSession(configuration: configuration)
    }

    func loadData(with request: URLRequest,
                  didReceiveData: @escaping (Data, URLResponse) -> Void,
                  completion: @escaping (Error?) -> Void) -> Cancellable {
        var modifiedRequest = request
        modifiedRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let task = session.dataTask(with: modifiedRequest) { data, response, error in
            if let data = data, let response = response {
                didReceiveData(data, response)
            }
            completion(error)
        }

        task.resume()
        return task
    }
}

class EncryptedDataCache: DataCaching {
    private let cache = NSCache<NSString, NSData>()
    private let encryptionKey: Data

    init(key: Data = Data(repeating: 0, count: 32)) {
        self.encryptionKey = key
    }

    func cachedData(for key: String) -> Data? {
        guard let encryptedData = cache.object(forKey: key as NSString) as Data? else {
            return nil
        }
        return decrypt(encryptedData)
    }

    func storeData(_ data: Data, for key: String) {
        let encrypted = encrypt(data)
        cache.setObject(encrypted as NSData, forKey: key as NSString)
    }

    func removeData(for key: String) {
        cache.removeObject(forKey: key as NSString)
    }

    func removeAll() {
        cache.removeAllObjects()
    }

    private func encrypt(_ data: Data) -> Data {
        // Implement encryption
        return data // Placeholder
    }

    private func decrypt(_ data: Data) -> Data {
        // Implement decryption
        return data // Placeholder
    }
}
```

## Using Custom Pipelines with PKSImage

### Integration

```swift
// Set custom pipeline globally
PKSImageCacheManager.shared.imagePipeline = CustomImagePipeline.create()

// Or use per-image
struct CustomPipelineImage: View {
    let url: URL?
    let pipeline: ImagePipeline

    var body: some View {
        LazyImage(
            request: ImageRequest(url: url),
            transaction: Transaction()
        ) { state in
            if let image = state.image {
                image
            } else {
                ProgressView()
            }
        }
        .pipeline(pipeline)
    }
}
```

### Pipeline Selection Strategy

```swift
class PipelineSelector {
    static func selectPipeline(for content: ContentType) -> ImagePipeline {
        switch content {
        case .thumbnail:
            return ThumbnailPipeline.create()

        case .fullResolution:
            return HighQualityPipeline.create()

        case .secure:
            return SecurePipeline.create(authToken: getAuthToken())

        case .userGenerated:
            return FilterPipeline.create()

        default:
            return ImagePipeline.shared
        }
    }

    enum ContentType {
        case thumbnail
        case fullResolution
        case secure
        case userGenerated
    }
}
```

## Advanced Processing Techniques

### Real-time Filters

```swift
class RealtimeFilterPipeline {
    @Published var currentFilter: FilterType = .none

    enum FilterType {
        case none
        case vintage
        case noir
        case vivid
        case dramatic
    }

    func createProcessor() -> ImageProcessing? {
        switch currentFilter {
        case .none:
            return nil

        case .vintage:
            return ImageProcessors.Composition([
                SepiaProcessor(intensity: 0.5),
                ColorAdjustmentProcessor(
                    brightness: -0.1,
                    contrast: 1.1,
                    saturation: 0.8
                ),
                VignetteProcessor(intensity: 0.3)
            ])

        case .noir:
            return ImageProcessors.Composition([
                GrayscaleProcessor(),
                ColorAdjustmentProcessor(
                    brightness: 0,
                    contrast: 1.3,
                    saturation: 0
                )
            ])

        case .vivid:
            return ColorAdjustmentProcessor(
                brightness: 0.05,
                contrast: 1.1,
                saturation: 1.3
            )

        case .dramatic:
            return ImageProcessors.Composition([
                ColorAdjustmentProcessor(
                    brightness: -0.2,
                    contrast: 1.4,
                    saturation: 1.1
                ),
                VignetteProcessor(intensity: 0.5)
            ])
        }
    }
}

struct VignetteProcessor: ImageProcessing {
    let intensity: CGFloat

    func process(_ image: UIImage) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }

        let filter = CIFilter(name: "CIVignette")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setValue(intensity, forKey: kCIInputIntensityKey)
        filter?.setValue(2.0, forKey: kCIInputRadiusKey)

        guard let outputImage = filter?.outputImage else { return nil }

        let context = CIContext()
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }

        return UIImage(cgImage: cgImage)
    }

    var identifier: String {
        "vignette-\(intensity)"
    }
}
```

### Machine Learning Pipeline

```swift
import CoreML
import Vision

class MLProcessingPipeline {
    static func createWithStyleTransfer(model: MLModel) -> ImageProcessing {
        return StyleTransferProcessor(model: model)
    }

    static func createWithObjectDetection() -> ImageProcessing {
        return ObjectDetectionProcessor()
    }
}

struct StyleTransferProcessor: ImageProcessing {
    let model: MLModel

    func process(_ image: UIImage) -> UIImage? {
        guard let pixelBuffer = image.pixelBuffer() else { return nil }

        do {
            let prediction = try model.prediction(from: pixelBuffer)
            return prediction.styledImage
        } catch {
            print("Style transfer failed: \(error)")
            return nil
        }
    }

    var identifier: String {
        "style-transfer"
    }
}

struct ObjectDetectionProcessor: ImageProcessing {
    func process(_ image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }

        let request = VNDetectRectanglesRequest { request, error in
            guard let observations = request.results as? [VNRectangleObservation] else {
                return
            }

            // Draw bounding boxes
            UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
            image.draw(at: .zero)

            let context = UIGraphicsGetCurrentContext()
            context?.setStrokeColor(UIColor.red.cgColor)
            context?.setLineWidth(2.0)

            for observation in observations {
                let rect = observation.boundingBox.scaled(to: image.size)
                context?.stroke(rect)
            }

            let processedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return processedImage
        }

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try? handler.perform([request])

        return image // Return with overlays
    }

    var identifier: String {
        "object-detection"
    }
}
```

## Performance Optimization

### Pipeline Benchmarking

```swift
class PipelineBenchmark {
    struct BenchmarkResult {
        let pipelineName: String
        let averageLoadTime: TimeInterval
        let memoryUsage: Int
        let cacheHitRate: Double
    }

    static func benchmark(pipelines: [String: ImagePipeline],
                          testURLs: [URL],
                          completion: @escaping ([BenchmarkResult]) -> Void) {
        var results: [BenchmarkResult] = []

        for (name, pipeline) in pipelines {
            var loadTimes: [TimeInterval] = []
            var cacheHits = 0
            let startMemory = getMemoryUsage()

            let group = DispatchGroup()

            for url in testURLs {
                group.enter()
                let startTime = Date()

                pipeline.loadImage(with: url) { result in
                    let loadTime = Date().timeIntervalSince(startTime)
                    loadTimes.append(loadTime)

                    if loadTime < 0.1 { // Heuristic for cache hit
                        cacheHits += 1
                    }

                    group.leave()
                }
            }

            group.notify(queue: .main) {
                let endMemory = getMemoryUsage()
                let averageTime = loadTimes.reduce(0, +) / Double(loadTimes.count)
                let hitRate = Double(cacheHits) / Double(testURLs.count)

                results.append(BenchmarkResult(
                    pipelineName: name,
                    averageLoadTime: averageTime,
                    memoryUsage: endMemory - startMemory,
                    cacheHitRate: hitRate
                ))

                if results.count == pipelines.count {
                    completion(results)
                }
            }
        }
    }

    private static func getMemoryUsage() -> Int {
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

        return result == KERN_SUCCESS ? Int(info.resident_size) : 0
    }
}
```

## Best Practices

### DO's

1. **Choose appropriate pipeline** for content type
2. **Reuse pipeline instances** - They're expensive to create
3. **Profile pipeline performance** before deployment
4. **Implement proper error handling** in custom processors
5. **Cache processed images** to avoid reprocessing
6. **Use composition** for complex transformations
7. **Test on various image formats** and sizes

### DON'Ts

1. **Don't create pipelines frequently** - Create once and reuse
2. **Don't process on main thread** - Use background queues
3. **Don't ignore memory limits** - Monitor usage
4. **Don't chain too many processors** - Impacts performance
5. **Don't forget cleanup** - Release resources properly

## Debugging Custom Pipelines

```swift
extension ImagePipeline {
    func debugConfiguration() {
        print("""
        Pipeline Configuration:
        =======================
        Progressive Decoding: \(configuration.isProgressiveDecodingEnabled)
        Resumable Data: \(configuration.isResumableDataEnabled)
        Task Coalescing: \(configuration.isTaskCoalescingEnabled)
        Memory Cache Limit: \(configuration.imageCache?.costLimit ?? 0)
        Data Cache Policy: \(configuration.dataCachePolicy)
        """)
    }
}

// Usage
let pipeline = CustomImagePipeline.create()
pipeline.debugConfiguration()
```

## See Also

- <doc:PKSImagePerformanceOptimization>
- <doc:PKSImageCacheConfiguration>
