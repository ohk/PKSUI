//
//  PKSImage+Prefetching.swift
//  PKSUI
//
//  Created on 9/15/25.
//

import SwiftUI
import Nuke

// MARK: - Prefetching

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
@MainActor
public struct PKSImageManager {
    private init() {}
    
    /// Prefetches an image from the specified URL with the given priority.
    ///
    /// This is a fire-and-forget method that starts loading the image in the background
    /// so it's ready when needed. The image will be cached according to the configured caching policies.
    ///
    /// - Parameters:
    ///   - url: The URL of the image to prefetch.
    ///   - priority: The priority for the prefetch request. Default is `.low`.
    ///
    /// Example:
    /// ```swift
    /// // Prefetch a single image
    /// PKSImageManager.prefetch(url: URL(string: "https://example.com/image.jpg"))
    ///
    /// // Prefetch with high priority
    /// PKSImageManager.prefetch(
    ///     url: URL(string: "https://example.com/important.jpg"),
    ///     priority: .high
    /// )
    /// ```
    public static func prefetch(url: URL?, priority: PKSImagePriority = .low) {
        guard let url = url else { return }

        var request = ImageRequest(url: url)
        request.priority = priority.nukeImagePriority

        sharedPrefetcher.startPrefetching(with: [request])
    }

    /// Prefetches multiple images from the specified URLs with the given priority.
    ///
    /// This is a fire-and-forget method that starts loading multiple images in the background
    /// so they're ready when needed. Images will be cached according to the configured caching policies.
    ///
    /// - Parameters:
    ///   - urls: An array of URLs to prefetch.
    ///   - priority: The priority for all prefetch requests. Default is `.low`.
    ///
    /// Example:
    /// ```swift
    /// // Prefetch multiple images
    /// let urls = [
    ///     URL(string: "https://example.com/image1.jpg"),
    ///     URL(string: "https://example.com/image2.jpg"),
    ///     URL(string: "https://example.com/image3.jpg")
    /// ].compactMap { $0 }
    ///
    /// PKSImageManager.prefetch(urls: urls, priority: .background)
    /// ```
    public static func prefetch(urls: [URL], priority: PKSImagePriority = .low) {
        guard !urls.isEmpty else { return }

        let requests = urls.map { url -> ImageRequest in
            var request = ImageRequest(url: url)
            request.priority = priority.nukeImagePriority
            return request
        }

        sharedPrefetcher.startPrefetching(with: requests)
    }

    /// Cancels prefetching for the specified URL.
    ///
    /// Use this method to stop a prefetch operation that's no longer needed,
    /// freeing up resources for other operations.
    ///
    /// - Parameter url: The URL of the image to stop prefetching.
    ///
    /// Example:
    /// ```swift
    /// // Cancel prefetching for a single URL
    /// PKSImageManager.cancelPrefetch(url: URL(string: "https://example.com/image.jpg"))
    /// ```
    public static func cancelPrefetch(url: URL?) {
        guard let url = url else { return }

        let request = ImageRequest(url: url)
        sharedPrefetcher.stopPrefetching(with: [request])
    }

    /// Cancels prefetching for multiple URLs.
    ///
    /// Use this method to stop multiple prefetch operations that are no longer needed,
    /// freeing up resources for other operations.
    ///
    /// - Parameter urls: An array of URLs to stop prefetching.
    ///
    /// Example:
    /// ```swift
    /// // Cancel prefetching for multiple URLs
    /// let urls = [
    ///     URL(string: "https://example.com/image1.jpg"),
    ///     URL(string: "https://example.com/image2.jpg")
    /// ].compactMap { $0 }
    ///
    /// PKSImageManager.cancelPrefetch(urls: urls)
    /// ```
    public static func cancelPrefetch(urls: [URL]) {
        guard !urls.isEmpty else { return }

        let requests = urls.map { ImageRequest(url: $0) }
        sharedPrefetcher.stopPrefetching(with: requests)
    }

    /// Cancels all ongoing prefetch operations.
    ///
    /// Use this method to stop all prefetch operations, for example when cleaning up
    /// resources or when the user navigates away from a screen.
    ///
    /// Example:
    /// ```swift
    /// // Cancel all prefetch operations
    /// PKSImageManager.cancelAllPrefetches()
    /// ```
    public static func cancelAllPrefetches() {
        sharedPrefetcher.stopPrefetching()
    }
}
