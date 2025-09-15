//
//  PKSImage.swift
//  PKSUI
//
//  Created by Omer Hamid Kamisli on 9/12/25.
//

import SwiftUI
import NukeUI
import Nuke
import Combine

/// A view that asynchronously loads and displays an image.
///
/// This view provides an enhanced alternative to SwiftUI's `AsyncImage` with
/// additional features like caching, prefetching, progress tracking, and priority management.
///
/// For example, you can display an icon that's stored on a server:
///
///     PKSImage(url: URL(string: "https://example.com/icon.png"))
///         .frame(width: 200, height: 200)
///
/// Until the image loads, the view displays a standard placeholder that
/// fills the available space. After the load completes successfully, the view
/// updates to display the image.
///
/// You can specify a custom placeholder using
/// ``init(url:scale:content:placeholder:)``. With this initializer, you can
/// also use the `content` parameter to manipulate the loaded image.
/// For example, you can add a modifier to make the loaded image resizable:
///
///     PKSImage(url: URL(string: "https://example.com/icon.png")) { image in
///         image.resizable()
///     } placeholder: {
///         ProgressView()
///     }
///     .frame(width: 50, height: 50)
///
/// To gain more control over the loading process, use the
/// ``init(url:scale:transaction:content:)`` initializer, which takes a
/// `content` closure that receives a ``AsyncImagePhase`` to indicate
/// the state of the loading operation. Return a view that's appropriate
/// for the current phase:
///
///     PKSImage(url: URL(string: "https://example.com/icon.png")) { phase in
///         if let image = phase.image {
///             image // Displays the loaded image.
///         } else if phase.error != nil {
///             Color.red // Indicates an error.
///         } else {
///             Color.blue // Acts as a placeholder.
///         }
///     }
///
/// > Important: You can't apply image-specific modifiers, like
/// ``Image/resizable(capInsets:resizingMode:)``, directly to a ``PKSImage``.
/// Instead, apply them to the ``Image`` instance that your `content`
/// closure gets when defining the view's appearance.
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public struct PKSImage<Content>: View where Content: View {

    // MARK: - Properties

    let url: URL?
    let scale: CGFloat
    let transaction: Transaction
    let makeContent: (AsyncImagePhase) -> Content

    // Priority and callbacks
    var priority: PKSImagePriority = .normal
    var onCompletion: ((Result<Image, Error>) -> Void)?
    var onStatusChange: ((PKSImageStatus) -> Void)?
    var onProgress: ((PKSImageProgress) -> Void)?

    // Cache configuration
    var cacheConfiguration: PKSImageCacheConfiguration?
    var useCustomPipeline: Bool = false

    @State var currentProgress = PKSImageProgress()
    @State var lastStatus: PKSImageStatus = .idle
    @State var currentTask: ImageTask?

    // MARK: - Body

    /// The content and behavior of the view.
    public var body: some View {
        let lazyImage = LazyImage(
            request: makeImageRequest(),
            transaction: transaction
        ) { state in
            let phase = convertToAsyncImagePhase(from: state)
            makeContent(phase)
                .onChange(of: state.isLoading) { _ in
                    self.trackStatusChange(for: state, phase: phase)
                }
        }
        .onStart { task in
            self.lastStatus = .loading(PKSImageProgress())
            self.onStatusChange?(.loading(PKSImageProgress()))

            // Store task for potential cancellation
            self.currentTask = task
        }
        .onCompletion { result in
            handleCompletion(result)
        }

        // Use custom pipeline if cache configuration is provided
        if useCustomPipeline, let _ = cacheConfiguration {
            lazyImage.pipeline(PKSImageCacheManager.shared.imagePipeline)
        } else {
            lazyImage
        }
    }

    // MARK: - Internal Methods

    func makeImageRequest() -> ImageRequest? {
        guard let url = url else { return nil }
        var request = ImageRequest(url: url)
        request.priority = priority.nukeImagePriority

        // Set the scale in userInfo if it's not the default value of 1
        if scale != 1 {
            request.userInfo[.scaleKey] = NSNumber(value: Float(scale))
        }

        return request
    }
}

// MARK: - Shared Prefetcher

/// Shared image prefetcher instance for PKSImage
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
let sharedPrefetcher = ImagePrefetcher()
