//
//  PKSImageScaleAndTransitionExample.swift
//  PKSUI
//
//  Created on 9/15/25.
//

import SwiftUI
import PKSUI

struct PKSImageScaleAndTransitionExample: View {
    @State private var imageURL: URL? = URL(string: "https://picsum.photos/200/200")
    @State private var currentScale: CGFloat = 1.0
    @State private var useAnimation = true

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Scale Example Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Scale Example")
                            .font(.headline)

                        Text("Scale controls how the image is interpreted for different resolutions (like @2x, @3x images)")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        HStack {
                            Text("Scale: \(currentScale, specifier: "%.1f")")
                            Slider(value: $currentScale, in: 0.5...3.0, step: 0.5)
                        }

                        PKSImage(
                            url: imageURL,
                            scale: currentScale
                        )
                        .frame(width: 200, height: 200)
                        .border(Color.gray, width: 1)

                        Text("Note: Scale affects how the image decoder interprets pixel density, not the display size")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)

                    // Transaction (Animation) Example Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Transaction Example")
                            .font(.headline)

                        Text("Transaction controls animations when the image state changes")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Toggle("Use Animation", isOn: $useAnimation)

                        Button("Change Image") {
                            // Generate a new random image URL
                            let size = Int.random(in: 200...400)
                            imageURL = URL(string: "https://picsum.photos/\(size)/\(size)")
                        }
                        .buttonStyle(.borderedProminent)

                        // Image with custom transaction
                        PKSImage(
                            url: imageURL,
                            scale: 1.0,
                            transaction: Transaction(
                                animation: useAnimation ? .easeInOut(duration: 0.5) : nil
                            )
                        ) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            case .failure:
                                Image(systemName: "xmark.circle")
                                    .foregroundColor(.red)
                                    .font(.largeTitle)
                            case .empty:
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .frame(height: 300)
                        .border(Color.blue, width: 1)

                        Text("Try toggling animation and changing the image to see the difference")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)

                    // Combined Example
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Combined Scale & Transaction")
                            .font(.headline)

                        PKSImage(
                            url: URL(string: "https://picsum.photos/300/300"),
                            scale: 2.0,  // Interpret as @2x image
                            transaction: Transaction(animation: .spring())
                        ) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } else if phase.error != nil {
                                Color.red.opacity(0.3)
                            } else {
                                Color.gray.opacity(0.3)
                                    .overlay(ProgressView())
                            }
                        }
                        .frame(width: 250, height: 250)
                        .clipped()
                        .cornerRadius(15)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("Scale & Transaction")
        }
    }
}

struct PKSImageScaleAndTransitionExample_Previews: PreviewProvider {
    static var previews: some View {
        PKSImageScaleAndTransitionExample()
    }
}