# PolynomialSolver
-> A robust iOS application built with SwiftUI and Apple's Vision framework to detect, parse, process, and display mathematical polynomial expressions from images. This app is designed to help students, educators, and anyone needing quick polynomial calculations directly from handwritten or printed notes.

# Features

## 1.Image Import:

-> Users can select existing images from their Photo Library.

-> Users can capture new images directly using the device's camera.

## 2.Text Detection (OCR):

-> Utilizes Apple's Vision framework for highly accurate Optical Character Recognition (OCR).

-> Specifically extracts polynomial expressions, recognizing formats like x^2 + 2x + 1 and 3x^3 - x^2 + 5x - 10.

-> Supports detection across multiple lines within an image.

## 3.Polynomial Parser:

-> A dedicated Swift module parses detected polynomial strings into a structured data format (e.g., a list of terms with coefficients and powers).

-> Includes validation to ensure that a detected string is a syntactically valid polynomial expression.

## 4.Polynomial Processing:
-> For each successfully detected and parsed polynomial, the app performs the following operations:

-> Simplification: Combines like terms (e.g., x + 2x becomes 3x).

-> Derivative: Calculates the first derivative of the polynomial.

-> Evaluation: Evaluates the polynomial at x=1,x=2, and x=3.

-> (Bonus) Factoring: Attempts to factor the polynomial (currently supports common monomial factoring and simple perfect squares like (x+a)2).

## All results are displayed in a structured, clean, and user-friendly SwiftUI interface.

## 5.Export Results:

-> Allows users to share the processed results, including:

-> An annotated image with bounding boxes drawn around the detected polynomial expressions, visually confirming what was recognized.

-> A text summary of all calculations for each polynomial


# Project Setup

-> To set up and run the PolynomialSolver project in Xcode:

## 1.Clone the Repository:
-> bash -> git clone https://github.com/your-username/PolynomialSolver.git # Replace with your repo URL -> cd PolynomialSolver -> 

## 2.Open in Xcode:
-> Open the PolynomialSolver.xcodeproj file in Xcode.

## 3.Add Swift Files:
-> Ensure the following Swift files are present in your project:

-> PolynomialProcessor.swift

-> VisionTextDetector.swift

-> ImagePicker.swift

-> ContentView.swift

-> PolynomialSolverApp.swift (this should be created by default)

## 4.Configure Info.plist (Privacy Settings):
-> In Xcode, select your project in the Project Navigator.

-> Select your app target (e.g., PolynomialSolver) under "Targets."

-> Go to the "Info" tab.

-> Add the following keys and their respective privacy descriptions (string values):

-> Privacy - Photo Library Usage Description: This app needs access to your photo library to select images for text detection.

-> Privacy - Camera Usage Description: This app needs access to your camera to capture images for text detection.

## 5.Build and Run:
-> Select your target device or simulator and click the "Run" button (▶️) in Xcode.

# How to Use the App
-> Launch the App: Open the PolynomialSolver app on your iOS device or simulator.

-> Select or Capture Image:

-> Tap "Select Photo" to choose an image from your photo library.

-> Tap "Take Photo" to use your device's camera to capture a new image.

-> Process Image: Once an image is selected, tap the "Process Image" button. The app will perform OCR and polynomial analysis.

-> View Results: The detected polynomials and their simplified form, derivative, evaluations, and factored form will be displayed in individual cards.

-> Share Results: Tap "Share Results" to export the textual summary and an annotated image (with bounding boxes) via standard iOS sharing options.

# Examples
## Example 1: x^2 + 2x + 1
Original String: x^2 + 2x + 1

Simplified: x^2 + 2x + 1

Derivative: 2x + 2

Evaluated at x = 1: 4.00

Evaluated at x = 2: 9.00

Evaluated at x = 3: 16.00

Factored: (x+1)^2

## Example 2: 3x^3 - x^2 + 5x - 10
Original String: 3x^3 - x^2 + 5x - 10

Simplified: 3x^3 - x^2 + 5x - 10

Derivative: 9x^2 - 2x + 5

Evaluated at x = 1: -3.00

Evaluated at x = 2: 20.00

Evaluated at x = 3: 77.00

Factored: 3x^3 - x^2 + 5x - 10 (Cannot be easily factored by simple common monomial or perfect square methods implemented)


## Example 3: x + 2x + 3x^3
Original String: x + 2x + 3x^3

Simplified: 3x^3 + 3x

Derivative: 9x^2 + 3

Evaluated at x = 1: 6.00

Evaluated at x = 2: 30.00

Evaluated at x = 3: 90.00

Factored: 3x(x^2 + 1)

## Example 4: 5
Original String: 5

Simplified: 5

Derivative: 0

Evaluated at x = 1: 5.00

Evaluated at x = 2: 5.00

Evaluated at x = 3: 5.00

Factored: 5 (Constant, no further factoring)

## Example 5: 2x^4 - 4x^3 + 6x^2
Original String: 2x^4 - 4x^3 + 6x^2

Simplified: 2x^4 - 4x^3 + 6x^2

Derivative: 8x^3 - 12x^2 + 12x

Evaluated at x = 1: 4.00

Evaluated at x = 2: 24.00

Evaluated at x = 3: 108.00

Factored: 2x^2(x^2 - 2x + 3) (Common factor 2x^2 extracted)

