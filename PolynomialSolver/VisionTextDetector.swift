//
//  VisionTextDetector.swift
//  PolynomialSolver
//
//  Created by Meggi on 18/06/25.
//

import Vision
import UIKit

class VisionTextDetector {

    func detectText(in image: UIImage, completion: @escaping ([VNRecognizedTextObservation]?, Error?) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(nil, NSError(domain: "VisionTextDetector", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert UIImage to CGImage."]))
            return
        }

        let request = VNRecognizeTextRequest { (request, error) in
            if let error = error {
                print("Error recognizing text: \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion([], nil)
                return
            }
            completion(observations, nil)
        }
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true

        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                print("Failed to perform text recognition request: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
    }
    func extractPolynomials(observations: [VNRecognizedTextObservation]) -> [(String, CGRect)] {
        var detectedPolynomials: [(String, CGRect)] = []

        for observation in observations {
            guard let candidate = observation.topCandidates(1).first else { continue }
            let recognizedText = candidate.string.trimmingCharacters(in: .whitespacesAndNewlines)
            if Polynomial.isValidPolynomial(string: recognizedText) {
                if let _ = Polynomial(rawString: recognizedText) {
                    detectedPolynomials.append((recognizedText, observation.boundingBox))
                }
            }
        }
        return detectedPolynomials
    }
}
