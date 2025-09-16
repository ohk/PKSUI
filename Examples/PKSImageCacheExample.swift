//
//  PKSImageCacheExample.swift
//  PKSUI
//
//  Created on 9/14/25.
//

import SwiftUI
import PKSUI

struct PKSImageCacheExample: View {
    let imageURLs = [
        "https://picsum.photos/200/300",
        "https://picsum.photos/300/200",
        "https://picsum.photos/400/400"
    ].compactMap { URL(string: $0) }

    @State private var cacheConfig: PKSImageCacheConfiguration = .default
    @State private var showStats = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Cache Configuration Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Cache Configuration")
                            .font(.headline)

                        HStack {
                            Button("Default") {
                                cacheConfig = .default
                                PKSImage.configureCacheGlobally(.default)
                            }
                            .buttonStyle(.bordered)

                            Button("Aggressive") {
                                cacheConfig = .aggressive
                                PKSImage.configureCacheGlobally(.aggressive)
                            }
                            .buttonStyle(.bordered)

                            Button("Memory Only") {
                                cacheConfig = .memoryOnly
                                PKSImage.configureCacheGlobally(.memoryOnly)
                            }
                            .buttonStyle(.bordered)

                            Button("Disabled") {
                                cacheConfig = .disabled
                                PKSImage.configureCacheGlobally(.disabled)
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)

                    // Image Examples
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Basic Image Loading")
                            .font(.headline)

                        PKSImage(url: imageURLs[0])
                            .frame(width: 200, height: 200)
                            .clipped()
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Image with Custom Cache")
                            .font(.headline)

                        PKSImage(url: imageURLs[1]) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 300, height: 200)
                        .clipped()
                        .cacheConfiguration(.aggressive)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Image without Cache")
                            .font(.headline)

                        PKSImage(url: imageURLs[2]) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            case .failure:
                                Image(systemName: "photo")
                                    .foregroundColor(.red)
                            case .empty:
                                ProgressView()
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .frame(height: 200)
                        .disableCache()
                    }

                    // Cache Management
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Cache Management")
                            .font(.headline)

                        HStack {
                            Button("Clear Memory") {
                                PKSImage.clearMemoryCache()
                            }
                            .buttonStyle(.bordered)

                            Button("Clear Disk") {
                                PKSImage.clearDiskCache()
                            }
                            .buttonStyle(.bordered)

                            Button("Clear All") {
                                PKSImage.clearAllCaches()
                            }
                            .buttonStyle(.borderedProminent)
                        }

                        Button("Show Cache Stats") {
                            showStats = true
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)

                    // Prefetching Example
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Prefetching Example")
                            .font(.headline)

                        HStack {
                            Button("Prefetch Images") {
                                PKSImage.prefetch(urls: imageURLs, priority: .normal)
                            }
                            .buttonStyle(.bordered)

                            Button("Cancel Prefetch") {
                                PKSImage.cancelPrefetch(urls: imageURLs)
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("PKSImage Cache Example")
            .alert("Cache Statistics", isPresented: $showStats) {
                Button("OK") { }
            } message: {
                let stats = PKSImage.cacheStatistics
                Text("""
                Memory Cache:
                - Total Items: \(stats.memoryCacheTotalCount)
                - Total Cost: \(formatBytes(stats.memoryCacheTotalCost))
                - Cost Limit: \(formatBytes(stats.memoryCacheCostLimit))
                - Count Limit: \(stats.memoryCacheCountLimit)

                Disk Cache:
                - Enabled: \(stats.isDiskCacheEnabled ? "Yes" : "No")
                - Size Limit: \(formatBytes(stats.diskCacheSizeLimit))
                """)
            }
        }
    }

    private func formatBytes(_ bytes: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .binary
        return formatter.string(fromByteCount: Int64(bytes))
    }
}

struct PKSImageCacheExample_Previews: PreviewProvider {
    static var previews: some View {
        PKSImageCacheExample()
    }
}