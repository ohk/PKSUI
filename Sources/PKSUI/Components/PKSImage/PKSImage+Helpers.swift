//
//  PKSImage+Helpers.swift
//  PKSUI
//
//  Created on 9/15/25.
//

import SwiftUI
import NukeUI
import Nuke

// MARK: - Helper Methods

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
extension PKSImage {

    func updateProgress(completed: Int64, total: Int64) {
        let progress = PKSImageProgress(
            totalBytes: total > 0 ? total : nil,
            downloadedBytes: completed,
            isFromCache: false
        )
        currentProgress = progress
        onProgress?(progress)

        // Update status with progress
        if lastStatus.isLoading {
            lastStatus = .loading(progress)
            onStatusChange?(.loading(progress))
        }
    }

    func convertToAsyncImagePhase(from state: LazyImageState) -> AsyncImagePhase {
        if let image = state.image {
            return .success(image)
        } else if let error = state.error {
            return .failure(error)
        } else {
            return .empty
        }
    }

    func trackStatusChange(for state: LazyImageState, phase: AsyncImagePhase) {
        let newStatus: PKSImageStatus

        if state.isLoading {
            newStatus = .loading(currentProgress)
        } else if state.image != nil {
            newStatus = .success
            // Update progress to indicate completion from cache if applicable
            if state.imageContainer?.isPreview == true {
                currentProgress = PKSImageProgress(isFromCache: true)
            }
        } else if let error = state.error {
            newStatus = .failure(error)
        } else {
            newStatus = .idle
        }

        if case .loading = lastStatus, case .loading = newStatus {
            // Don't fire callback for progress updates within loading state
            return
        }

        if case .success = lastStatus, case .success = newStatus {
            // Don't fire multiple success callbacks
            return
        }

        lastStatus = newStatus
        onStatusChange?(newStatus)
    }

    func handleCompletion(_ result: Result<ImageResponse, any Error>) {
        switch result {
        case .success(let response):
            #if os(macOS)
            let swiftUIImage = Image(nsImage: response.image)
            #else
            let swiftUIImage = Image(uiImage: response.image)
            #endif
            onCompletion?(.success(swiftUIImage))
        case .failure(let error):
            onCompletion?(.failure(error))
        }
    }
}