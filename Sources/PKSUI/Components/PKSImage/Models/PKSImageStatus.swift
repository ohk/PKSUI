//
//  PKSImageStatus.swift
//  PKSUI
//
//  Created by Omer Hamid Kamisli on 9/12/25.
//

import Foundation

/// The status of an image loading operation.
///
/// Use `PKSImageStatus` to track the different states of an image
/// loading operation, from initial request through completion.
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public enum PKSImageStatus: Sendable {
    /// The image loading has not started yet.
    case idle
    
    /// The image is currently being loaded.
    case loading(PKSImageProgress)
    
    /// The image was successfully loaded.
    case success
    
    /// The image failed to load.
    case failure(any Error)
    
    /// The image loading was cancelled.
    case cancelled
    
    /// Indicates whether the status represents a loading state.
    public var isLoading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }
    
    /// Indicates whether the status represents a final state (success, failure, or cancelled).
    public var isFinal: Bool {
        switch self {
        case .success, .failure, .cancelled:
            return true
        case .idle, .loading:
            return false
        }
    }
    
    /// The progress information if the status is loading.
    public var progress: PKSImageProgress? {
        if case .loading(let progress) = self {
            return progress
        }
        return nil
    }
    
    /// The error if the status is failure.
    public var error: (any Error)? {
        if case .failure(let error) = self {
            return error
        }
        return nil
    }
}