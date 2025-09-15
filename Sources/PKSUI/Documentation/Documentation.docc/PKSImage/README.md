# PKSImage

An advanced asynchronous image loading view with comprehensive caching, prefetching, and progress tracking capabilities.

## Overview

``PKSImage`` is a powerful replacement for SwiftUI's `AsyncImage` that provides enterprise-grade image loading capabilities. Built on top of the Nuke image loading framework, it offers sophisticated features while maintaining a simple, SwiftUI-native API.

### Key Features

- **Intelligent Caching**: Multi-tier caching system with memory and disk storage
- **Priority Management**: Fine-grained control over image loading priorities
- **Progress Tracking**: Real-time download progress monitoring
- **Prefetching**: Proactive image loading for optimal performance
- **Status Callbacks**: Comprehensive lifecycle event handling
- **Progressive Loading**: Display partial images as they download
- **Resumable Downloads**: Automatically resume interrupted downloads
- **Custom Pipelines**: Configure dedicated image processing pipelines

## Topics

### Essentials

- <doc:PKSImageGettingStarted>
- <doc:PKSImageBasicUsage>
- <doc:PKSImageMigrationFromAsyncImage>

### Creating an Image View

- ``PKSImage/init(url:scale:)``
- ``PKSImage/init(url:scale:content:placeholder:)``
- ``PKSImage/init(url:scale:transaction:content:)``

### Configuration

- <doc:PKSImageConfiguringPriority>
- <doc:PKSImageCacheConfiguration>
- <doc:PKSImageProgressTracking>

### View Modifiers

- ``PKSImage/priority(_:)``
- ``PKSImage/onCompletion(_:)``
- ``PKSImage/onStatusChange(_:)``
- ``PKSImage/onProgress(_:)``
- ``PKSImage/cacheConfiguration(_:)``
- ``PKSImage/disableCache()``

### Prefetching

- <doc:PKSImagePrefetchingGuide>
- ``PKSImageManager/prefetch(url:priority:)``
- ``PKSImageManager/prefetch(urls:priority:)``
- ``PKSImageManager/cancelPrefetch(url:)``
- ``PKSImageManager/cancelPrefetch(urls:)``
- ``PKSImageManager/cancelAllPrefetches()``

### Supporting Types

- ``PKSImagePriority``
- ``PKSImageStatus``
- ``PKSImageProgress``
- ``PKSImageCacheConfiguration``
- ``PKSMemoryCacheConfiguration``
- ``PKSDiskCacheConfiguration``

### Cache Management

- <doc:PKSImageCacheManagement>
- ``PKSImageCacheManager``
- ``PKSImageManager/configureCacheGlobally(_:)``
- ``PKSImageManager/clearMemoryCache()``
- ``PKSImageManager/clearDiskCache()``
- ``PKSImageManager/clearAllCaches()``
- ``PKSImageManager/removeFromCache(url:)``
- ``PKSImageManager/cacheStatistics``

### Advanced Topics

- <doc:PKSImagePerformanceOptimization>
- <doc:PKSImageCustomPipelines>
- <doc:PKSImageTroubleshooting>
