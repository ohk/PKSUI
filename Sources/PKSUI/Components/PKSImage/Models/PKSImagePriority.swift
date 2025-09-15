//
//  PKSImagePriority.swift
//  PKSUI
//
//  Created by Omer Hamid Kamisli on 9/12/25.
//

import Foundation
import Nuke
import os

/// The priority level for image loading requests.
///
/// Use `PKSImagePriority` to control the order in which images are loaded
/// when multiple requests are pending. Higher priority images will be
/// loaded before lower priority ones.
///
/// Priority values range from 0 to 1000, where:
/// - 0 represents very low priority
/// - 1000 represents very high priority
///
/// You can extend this struct with custom priority levels:
/// ```swift
/// extension PKSImagePriority {
///     static let critical = PKSImagePriority(rawValue: 900)
///     static let background = PKSImagePriority(rawValue: 100)
/// }
/// ```
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public struct PKSImagePriority: Equatable, Sendable {
    /// The raw priority value (0-1000)
    public let rawValue: Int
    
    /// Creates a new priority with the specified raw value.
    ///
    /// - Parameter rawValue: The priority value (recommended range: 0-1000)
    /// - Note: Values outside 0-1000 will be clamped and a warning will be logged
    public init(rawValue: Int) {
        if rawValue < 0 {
            let logger = Logger(subsystem: "PKSUI", category: "PKSImagePriority")
            logger.warning("Value \(rawValue) is less than 0, clamping to 0")
            self.rawValue = 0
        } else if rawValue > 1000 {
            let logger = Logger(subsystem: "PKSUI", category: "PKSImagePriority")
            logger.warning("Value \(rawValue) is greater than 1000, clamping to 1000")
            self.rawValue = 1000
        } else {
            self.rawValue = rawValue
        }
    }
    
    /// Internal: Converts this priority to the image request priority.
    ///
    /// Maps the 0-1000 range to the internal priority system.
    /// This is an internal implementation detail.
    internal var nukeImagePriority: ImageRequest.Priority {
        switch rawValue {
        case 0...200:
            return .veryLow
        case 201...400:
            return .low
        case 401...600:
            return .normal
        case 601...800:
            return .high
        case 801...1000:
            return .veryHigh
        default:
            // This shouldn't happen due to clamping in init, but handle it anyway
            return .normal
        }
    }
    
    /// Internal: Converts this priority to raw priority value.
    ///
    /// Scales the 0-1000 range to the internal priority range.
    internal var nukeRawPriority: ImageRequest.Priority.RawValue {
        // Map to Nuke's specific priority values
        switch rawValue {
        case 0...200:
            return ImageRequest.Priority.veryLow.rawValue
        case 201...400:
            return ImageRequest.Priority.low.rawValue
        case 401...600:
            return ImageRequest.Priority.normal.rawValue
        case 601...800:
            return ImageRequest.Priority.high.rawValue
        case 801...1000:
            return ImageRequest.Priority.veryHigh.rawValue
        default:
            return ImageRequest.Priority.normal.rawValue
        }
    }
}

// MARK: - Common Priorities

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public extension PKSImagePriority {
    /// Very low priority (0), used for preloading or background loading.
    static let veryLow = PKSImagePriority(rawValue: 0)
    
    /// Low priority (250), used for non-visible content.
    static let low = PKSImagePriority(rawValue: 250)
    
    /// Normal priority (500), the default for most image loads.
    static let normal = PKSImagePriority(rawValue: 500)
    
    /// High priority (750), used for visible content.
    static let high = PKSImagePriority(rawValue: 750)
    
    /// Very high priority (1000), used for critical user-facing content.
    static let veryHigh = PKSImagePriority(rawValue: 1000)
}

// MARK: - Comparable

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
extension PKSImagePriority: Comparable {
    public static func < (lhs: PKSImagePriority, rhs: PKSImagePriority) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}