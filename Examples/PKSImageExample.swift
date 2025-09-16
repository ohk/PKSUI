//
//  PKSImageExample.swift
//  PKSUI Examples
//
//  Created by Omer Hamid Kamisli on 9/12/25.
//

import SwiftUI
import PKSUI

// Example of extending PKSImagePriority with custom values
extension PKSImagePriority {
    static let critical = PKSImagePriority(rawValue: 900)
    static let background = PKSImagePriority(rawValue: 100)
    static let preload = PKSImagePriority(rawValue: 50)
}

struct PKSImageExampleView: View {
    @State private var loadingStatus: PKSImageStatus = .idle
    @State private var currentProgress: PKSImageProgress = PKSImageProgress()
    @State private var completionMessage: String = ""
    
    // URLs for prefetch example
    let imageURLs = [
        "https://picsum.photos/300/300?random=1",
        "https://picsum.photos/300/300?random=2",
        "https://picsum.photos/300/300?random=3",
        "https://picsum.photos/300/300?random=4",
        "https://picsum.photos/300/300?random=5"
    ].compactMap { URL(string: $0) }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("PKSImage with Feedback")
                .font(.largeTitle)
                .padding()
            
            // Example 1: Basic usage with all callbacks
            PKSImage(url: URL(string: "https://picsum.photos/300/200"))
                .frame(width: 300, height: 200)
                .priority(.high)
                .onCompletion { result in
                    switch result {
                    case .success:
                        completionMessage = "Image loaded successfully!"
                    case .failure(let error):
                        completionMessage = "Failed to load: \(error.localizedDescription)"
                    }
                }
                .onStatusChange { status in
                    loadingStatus = status
                    print("Status changed: \(status)")
                }
                .onProgress { progress in
                    currentProgress = progress
                    print("Progress: \(progress.downloadedKB)KB / \(progress.totalKB ?? 0)KB")
                }
            
            // Display status information
            Group {
                Text("Status: \(statusDescription)")
                    .font(.caption)
                
                if loadingStatus.isLoading {
                    ProgressView(value: currentProgress.fractionCompleted)
                        .frame(width: 200)
                    
                    Text("\(Int(currentProgress.downloadedKB))KB / \(Int(currentProgress.totalKB ?? 0))KB")
                        .font(.caption2)
                }
                
                if !completionMessage.isEmpty {
                    Text(completionMessage)
                        .font(.caption)
                        .foregroundColor(loadingStatus.isFinal && loadingStatus.error == nil ? .green : .red)
                }
            }
            .padding()
            
            Divider()
            
            // Example 2: Custom content with phase handling
            Text("Custom Phase Handling")
                .font(.headline)
            
            PKSImage(url: URL(string: "https://picsum.photos/200/200")) { phase in
                switch phase {
                case .empty:
                    Color.gray.opacity(0.3)
                        .overlay(
                            VStack {
                                ProgressView()
                                Text("Loading...")
                                    .font(.caption)
                            }
                        )
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                case .failure(let error):
                    Color.red.opacity(0.3)
                        .overlay(
                            VStack {
                                Image(systemName: "exclamationmark.triangle")
                                Text("Error: \(error.localizedDescription)")
                                    .font(.caption)
                            }
                        )
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 200, height: 200)
            .priority(.veryHigh)
            
            Divider()
            
            // Example 3: Multiple priorities including custom ones
            Text("Priority Examples")
                .font(.headline)
            
            HStack(spacing: 10) {
                ForEach([PKSImagePriority.background, .normal, .critical], id: \.rawValue) { priority in
                    VStack {
                        PKSImage(url: URL(string: "https://picsum.photos/100/100?random=\(priority.rawValue)"))
                            .frame(width: 100, height: 100)
                            .priority(priority)
                        
                        Text(priorityName(priority))
                            .font(.caption)
                        Text("(\(priority.rawValue))")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Divider()
            
            // Example 4: Prefetching
            Text("Prefetch Example")
                .font(.headline)
            
            VStack(spacing: 10) {
                Button("Prefetch All Images") {
                    // Prefetch all images with background priority
                    PKSImage.prefetch(urls: imageURLs, priority: .background)
                }
                .buttonStyle(.borderedProminent)
                
                Button("Cancel All Prefetches") {
                    PKSImage.cancelAllPrefetches()
                }
                .buttonStyle(.bordered)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(imageURLs, id: \.absoluteString) { url in
                            PKSImage(url: url)
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
                .onAppear {
                    // Prefetch the first 3 images when view appears
                    PKSImage.prefetch(urls: Array(imageURLs.prefix(3)), priority: .low)
                }
            }
        }
        .padding()
    }
    
    var statusDescription: String {
        switch loadingStatus {
        case .idle:
            return "Idle"
        case .loading:
            return "Loading..."
        case .success:
            return "Success"
        case .failure:
            return "Failed"
        case .cancelled:
            return "Cancelled"
        }
    }
    
    func priorityName(_ priority: PKSImagePriority) -> String {
        switch priority.rawValue {
        case PKSImagePriority.veryLow.rawValue:
            return "Very Low"
        case PKSImagePriority.low.rawValue:
            return "Low"
        case PKSImagePriority.normal.rawValue:
            return "Normal"
        case PKSImagePriority.high.rawValue:
            return "High"
        case PKSImagePriority.veryHigh.rawValue:
            return "Very High"
        case PKSImagePriority.critical.rawValue:
            return "Critical"
        case PKSImagePriority.background.rawValue:
            return "Background"
        case PKSImagePriority.preload.rawValue:
            return "Preload"
        default:
            return "Custom"
        }
    }
}

// Preview
struct PKSImageExampleView_Previews: PreviewProvider {
    static var previews: some View {
        PKSImageExampleView()
    }
}