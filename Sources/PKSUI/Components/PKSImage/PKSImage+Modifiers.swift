//
//  PKSImage+Modifiers.swift
//  PKSUI
//
//  Created on 9/15/25.
//

import SwiftUI

// MARK: - Modifiers

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
extension PKSImage {

    /// Sets the priority for the image loading request.
    ///
    /// - Parameter priority: The priority level for loading the image.
    /// - Returns: A modified ``PKSImage`` with the specified priority.
    public func priority(_ priority: PKSImagePriority) -> PKSImage {
        var modified = self
        modified.priority = priority
        return modified
    }

    /// Adds a completion handler that is called when the image loading completes.
    ///
    /// - Parameter action: A closure that receives the result of the image loading operation.
    /// - Returns: A modified ``PKSImage`` with the completion handler.
    public func onCompletion(_ action: @escaping (Result<Image, Error>) -> Void) -> PKSImage {
        var modified = self
        modified.onCompletion = action
        return modified
    }

    /// Adds a status change handler that is called when the loading status changes.
    ///
    /// - Parameter action: A closure that receives the new status.
    /// - Returns: A modified ``PKSImage`` with the status change handler.
    public func onStatusChange(_ action: @escaping (PKSImageStatus) -> Void) -> PKSImage {
        var modified = self
        modified.onStatusChange = action
        return modified
    }

    /// Adds a progress handler that is called during the image download.
    ///
    /// - Parameter action: A closure that receives progress updates.
    /// - Returns: A modified ``PKSImage`` with the progress handler.
    public func onProgress(_ action: @escaping (PKSImageProgress) -> Void) -> PKSImage {
        var modified = self
        modified.onProgress = action
        return modified
    }

    /// Configures the caching behavior for this specific image.
    ///
    /// Use this modifier to override the global cache configuration for a specific image.
    /// This is useful when you need different caching strategies for different images.
    ///
    /// Example:
    /// ```swift
    /// PKSImage(url: profileImageURL)
    ///     .cacheConfiguration(.aggressive)
    ///
    /// PKSImage(url: temporaryImageURL)
    ///     .cacheConfiguration(.memoryOnly)
    /// ```
    ///
    /// - Parameter configuration: The cache configuration to use for this image.
    /// - Returns: A modified ``PKSImage`` with the specified cache configuration.
    public func cacheConfiguration(_ configuration: PKSImageCacheConfiguration) -> PKSImage {
        var modified = self
        modified.cacheConfiguration = configuration
        modified.useCustomPipeline = true

        // Apply the configuration to the shared manager if needed
        PKSImageCacheManager.shared.configure(with: configuration)

        return modified
    }

    /// Disables caching for this specific image.
    ///
    /// Use this when you want to ensure an image is always fetched fresh from the network.
    ///
    /// Example:
    /// ```swift
    /// PKSImage(url: dynamicContentURL)
    ///     .disableCache()
    /// ```
    ///
    /// - Returns: A modified ``PKSImage`` with caching disabled.
    public func disableCache() -> PKSImage {
        return cacheConfiguration(.disabled)
    }
}
