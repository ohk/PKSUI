# ``PKSUI``

A comprehensive SwiftUI component library providing powerful, customizable UI components for modern iOS, macOS, tvOS, and watchOS applications.

## Overview

PKSUI is a professionally designed component library that extends SwiftUI with advanced, production-ready UI components. Each component is carefully crafted to provide both powerful functionality and seamless integration with SwiftUI's declarative syntax.

## Featured Components

### PKSImage
An advanced asynchronous image loading view that surpasses SwiftUI's AsyncImage with enterprise-grade features including intelligent caching, priority management, prefetching, and progress tracking.

- **Intelligent Multi-tier Caching**: Memory and disk caching with configurable strategies
- **Priority-based Loading**: Fine-grained control over loading priorities
- **Progress Monitoring**: Real-time download progress tracking
- **Prefetching Support**: Proactive image loading for optimal performance
- **Comprehensive Status Handling**: Complete lifecycle event management

### PKSPill
A customizable pill-shaped selection component perfect for modern, compact UI designs.

- **Flexible Selection Management**: Single and multiple selection modes
- **Customizable Appearance**: Fully styleable with SwiftUI modifiers
- **Section Support**: Group related pills with PKSPillSection
- **Action Integration**: Built-in support for selection actions and callbacks

## Requirements

- **iOS** 15.0+ / **macOS** 12.0+ / **tvOS** 15.0+ / **watchOS** 8.0+
- **Swift** 5.5+
- **Xcode** 13.0+

## Installation

### Swift Package Manager

Add PKSUI to your project using Swift Package Manager:

1. In Xcode, select **File > Add Package Dependencies**
2. Enter the repository URL: `https://github.com/yourusername/PKSUI`
3. Select the version you want to use
4. Add PKSUI to your target

### Package.swift

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/PKSUI", from: "1.0.0")
]
```

## Getting Started

Import PKSUI in your SwiftUI files:

```swift
import SwiftUI
import PKSUI
```

### Quick Examples

#### Loading Images with PKSImage

```swift
// Simple image loading
PKSImage(url: URL(string: "https://example.com/image.jpg"))
    .frame(width: 200, height: 200)

// Advanced configuration
PKSImage(url: imageURL) { image in
    image
        .resizable()
        .aspectRatio(contentMode: .fit)
} placeholder: {
    ProgressView()
}
.priority(.high)
.onProgress { progress in
    print("Downloaded: \(progress.completedUnitCount) bytes")
}
```

#### Creating Selection Pills

```swift
// Single selection pill
PKSPill("Option 1", isSelected: $isSelected) {
    // Action when tapped
}

// Multiple pills in a section
PKSPillSection(
    items: ["Option A", "Option B", "Option C"],
    selection: $selectedOptions
)
```

## Topics

### Components

- ``PKSImage``
- ``PKSImageManager``
- ``PKSPill``
- ``PKSPillSection``

### Image Loading

- <doc:PKSImage/PKSImageGettingStarted>
- <doc:PKSImage/PKSImageBasicUsage>
- <doc:PKSImage/PKSImageMigrationFromAsyncImage>
- <doc:PKSImage/PKSImageCacheConfiguration>
- <doc:PKSImage/PKSImagePrefetchingGuide>
- <doc:PKSImage/PKSImagePerformanceOptimization>

### Configuration Types

- ``PKSImagePriority``
- ``PKSImageStatus``
- ``PKSImageProgress``
- ``PKSImageCacheConfiguration``
- ``PKSMemoryCacheConfiguration``
- ``PKSDiskCacheConfiguration``

### Cache Management

- ``PKSImageCacheManager``
- <doc:PKSImage/PKSImageCacheManagement>

## Architecture

PKSUI follows SwiftUI best practices and design patterns:

- **Declarative API**: All components use SwiftUI's declarative syntax
- **Composable Design**: Components can be easily combined and customized
- **Performance Optimized**: Built with performance in mind, using lazy loading and efficient caching
- **Platform Adaptive**: Components automatically adapt to different Apple platforms
- **Accessibility Ready**: Full support for VoiceOver and accessibility features

## Contributing

We welcome contributions! Please see our [Contributing Guidelines](https://github.com/yourusername/PKSUI/blob/main/CONTRIBUTING.md) for details.

## License

PKSUI is available under the MIT license. See the [LICENSE](https://github.com/yourusername/PKSUI/blob/main/LICENSE) file for more information.
