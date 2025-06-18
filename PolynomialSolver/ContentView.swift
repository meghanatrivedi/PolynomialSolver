//
//  ContentView.swift
//  PolynomialSolver
//
//  Created by Meggi on 18/06/25.
//

import SwiftUI
import Vision
import PhotosUI


struct ProcessedPolynomialResult: Identifiable {
    let id = UUID()
    let originalString: String
    let polynomial: Polynomial
    let simplifiedPolynomial: Polynomial
    let derivativePolynomial: Polynomial
    let evaluationX1: Double
    let evaluationX2: Double
    let evaluationX3: Double
    let factoredString: String
    let boundingBox: CGRect
}

struct ContentView: View {
    
    @State private var selectedImage: UIImage?
        @State private var isShowingImagePicker: Bool = false
        @State private var imageSourceType: UIImagePickerController.SourceType = .photoLibrary
        @State private var processedResults: [ProcessedPolynomialResult] = []
        @State private var isShowingShareSheet: Bool = false
        @State private var shareItems: [Any] = []
        @State private var showNoPolynomialsAlert: Bool = false
        @State private var isLoading: Bool = false

        private let visionTextDetector = VisionTextDetector()

    
    var body: some View {
        NavigationView {
                    ScrollView {
                        VStack(spacing: 20) {
                            HStack {
                                Button(action: {
                                    imageSourceType = .photoLibrary
                                    isShowingImagePicker = true
                                }) {
                                    Label("Select Photo", systemImage: "photo.on.rectangle")
                                        .font(.headline)
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }

                                Button(action: {
                                    imageSourceType = .camera
                                    isShowingImagePicker = true
                                }) {
                                    Label("Take Photo", systemImage: "camera")
                                        .font(.headline)
                                        .padding()
                                        .background(Color.green)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                            }
                            .padding(.horizontal)

                            if isLoading {
                                ProgressView("Processing Image...")
                                    .padding()
                                    .font(.title3)
                            } else if let image = selectedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 300)
                                    .cornerRadius(15)
                                    .shadow(radius: 5)
                                    .padding(.horizontal)
                            } else {
                                Image(systemName: "photo.fill.on.rectangle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 150, height: 150)
                                    .foregroundColor(.gray)
                                    .opacity(0.6)
                                    .padding()
                            }

                            if selectedImage != nil && !isLoading {
                                Button(action: processImage) {
                                    Label("Process Image", systemImage: "text.magnifyingglass")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.purple)
                                        .foregroundColor(.white)
                                        .cornerRadius(15)
                                }
                                .padding(.horizontal)
                                .transition(.scale)
                            }

                            if !processedResults.isEmpty {
                                Text("Detected Polynomials:")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .padding(.top)

                                ForEach(processedResults) { result in
                                    PolynomialResultCard(result: result)
                                }
                                .padding(.horizontal)

                                Button(action: prepareShareSheet) {
                                    Label("Share Results", systemImage: "square.and.arrow.up")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.orange)
                                        .foregroundColor(.white)
                                        .cornerRadius(15)
                                }
                                .padding([.horizontal, .bottom])
                            }
                        }
                        .navigationTitle("Polynomial Solver")
                        .sheet(isPresented: $isShowingImagePicker) {
                            ImagePicker(sourceType: imageSourceType, selectedImage: $selectedImage)
                        }
                        .sheet(isPresented: $isShowingShareSheet) {
                            ShareSheet(activityItems: shareItems)
                        }
                        .alert("No Polynomials Found", isPresented: $showNoPolynomialsAlert) {
                            Button("OK", role: .cancel) { }
                        } message: {
                            Text("No valid polynomial expressions were detected in the selected image.")
                        }
                    }
                }
            }

            private func processImage() {
                guard let image = selectedImage else { return }

                isLoading = true
                processedResults = []

                visionTextDetector.detectText(in: image) { observations, error in
                    DispatchQueue.main.async {
                        isLoading = false

                        if let error = error {
                            print("Error detecting text: \(error.localizedDescription)")
                            return
                        }

                        guard let observations = observations else { return }

                        let detectedStringsAndBoxes = visionTextDetector.extractPolynomials(observations: observations)

                        if detectedStringsAndBoxes.isEmpty {
                            showNoPolynomialsAlert = true
                            return
                        }

                        for (text, boundingBox) in detectedStringsAndBoxes {
                            if let polynomial = Polynomial(rawString: text) {
                                let simplified = polynomial
                                let derivative = polynomial.derivative()
                                let evalX1 = polynomial.evaluate(at: 1)
                                let evalX2 = polynomial.evaluate(at: 2)
                                let evalX3 = polynomial.evaluate(at: 3)
                                let factored = polynomial.factor()

                                let result = ProcessedPolynomialResult(
                                    originalString: text,
                                    polynomial: polynomial,
                                    simplifiedPolynomial: simplified,
                                    derivativePolynomial: derivative,
                                    evaluationX1: evalX1,
                                    evaluationX2: evalX2,
                                    evaluationX3: evalX3,
                                    factoredString: factored,
                                    boundingBox: boundingBox
                                )
                                processedResults.append(result)
                            }
                        }
                    }
                }
            }

            private func prepareShareSheet() {
                var textToShare: String = "Polynomial Analysis Results:\n\n"
                for result in processedResults {
                    textToShare += "Original: \(result.originalString)\n"
                    textToShare += "Simplified: \(result.simplifiedPolynomial.description)\n"
                    textToShare += "Derivative: \(result.derivativePolynomial.description)\n"
                    textToShare += "Evaluated at x=1: \(String(format: "%.2f", result.evaluationX1))\n"
                    textToShare += "Evaluated at x=2: \(String(format: "%.2f", result.evaluationX2))\n"
                    textToShare += "Evaluated at x=3: \(String(format: "%.2f", result.evaluationX3))\n"
                    textToShare += "Factored: \(result.factoredString)\n"
                    textToShare += "--------------------------------------\n"
                }

                shareItems = [textToShare]

                if let originalImage = selectedImage {
                    let annotatedImage = drawBoundingBoxes(on: originalImage, results: processedResults)
                    if let imageData = annotatedImage.pngData() {
                        shareItems.append(imageData)
                    }
                }

                isShowingShareSheet = true
            }
            private func drawBoundingBoxes(on image: UIImage, results: [ProcessedPolynomialResult]) -> UIImage {
                let imageSize = image.size
                let scale: CGFloat = 0
                UIGraphicsBeginImageContextWithOptions(imageSize, false, scale)
                image.draw(at: .zero)

                let context = UIGraphicsGetCurrentContext()!
                context.setStrokeColor(UIColor.red.cgColor)
                context.setLineWidth(2.0)

                for result in results {
                    var boundingBox = result.boundingBox
                    boundingBox.origin.y = 1 - boundingBox.origin.y - boundingBox.size.height

                    let rect = CGRect(
                        x: boundingBox.origin.x * imageSize.width,
                        y: boundingBox.origin.y * imageSize.height,
                        width: boundingBox.size.width * imageSize.width,
                        height: boundingBox.size.height * imageSize.height
                    )
                    context.stroke(rect)
                }

                let newImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                return newImage ?? image
            }
        }
        struct PolynomialResultCard: View {
            let result: ProcessedPolynomialResult

            var body: some View {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Original: \(result.originalString)")
                        .font(.headline)
                        .foregroundColor(.blue)

                    Divider()

                    Grid(alignment: .leading, horizontalSpacing: 10, verticalSpacing: 5) {
                        GridRow {
                            Text("Simplified:")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text(result.simplifiedPolynomial.description)
                                .font(.body)
                        }
                        GridRow {
                            Text("Derivative:")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text(result.derivativePolynomial.description)
                                .font(.body)
                        }
                        GridRow {
                            Text("Factored:")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text(result.factoredString)
                                .font(.body)
                        }
                        GridRow {
                            Text("Eval (x=1):")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text(String(format: "%.2f", result.evaluationX1))
                                .font(.body)
                        }
                        GridRow {
                            Text("Eval (x=2):")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text(String(format: "%.2f", result.evaluationX2))
                                .font(.body)
                        }
                        GridRow {
                            Text("Eval (x=3):")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text(String(format: "%.2f", result.evaluationX3))
                                .font(.body)
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(15)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
            }
        }
        struct ShareSheet: UIViewControllerRepresentable {
            let activityItems: [Any]

            func makeUIViewController(context: Context) -> UIActivityViewController {
                let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
                return controller
            }

            func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
        }
