//
//  PKSImageProgress.swift
//  PKSUI
//
//  Created by Omer Hamid Kamisli on 9/12/25.
//

import Foundation

/// A structure that represents the progress of an image download.
///
/// Use `PKSImageProgress` to track the download status of an image,
/// including the total size, downloaded bytes, and cache status.
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public struct PKSImageProgress: Sendable {
    /// The total size of the image in bytes, if known.
    public let totalBytes: Int64?
    
    /// The number of bytes that have been downloaded.
    public let downloadedBytes: Int64
    
    /// Indicates whether the image was loaded from cache.
    public let isFromCache: Bool
    
    /// The fraction of the download completed (0.0 to 1.0).
    public var fractionCompleted: Double {
        guard let totalBytes = totalBytes, totalBytes > 0 else { return 0 }
        return min(1.0, Double(downloadedBytes) / Double(totalBytes))
    }
    
    /// The total size in kilobytes, if known.
    public var totalKB: Double? {
        guard let totalBytes = totalBytes else { return nil }
        return Double(totalBytes) / 1024.0
    }
    
    /// The downloaded size in kilobytes.
    public var downloadedKB: Double {
        return Double(downloadedBytes) / 1024.0
    }
    
    /// Creates a new image progress instance.
    ///
    /// - Parameters:
    ///   - totalBytes: The total size of the image in bytes, if known.
    ///   - downloadedBytes: The number of bytes that have been downloaded.
    ///   - isFromCache: Whether the image was loaded from cache.
    public init(totalBytes: Int64? = nil, downloadedBytes: Int64 = 0, isFromCache: Bool = false) {
        self.totalBytes = totalBytes
        self.downloadedBytes = downloadedBytes
        self.isFromCache = isFromCache
    }
}