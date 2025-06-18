//
//  PolynomialProcessor.swift
//  PolynomialSolver
//
//  Created by Meggi on 18/06/25.
//

import Foundation


struct Term: Identifiable, Hashable, Comparable {
    let id = UUID()
    var coefficient: Double
    var power: Int

    static func < (lhs: Term, rhs: Term) -> Bool {
        return lhs.power > rhs.power
    }

    var description: String {
        var str = ""
        if coefficient < 0 {
            str += "-"
        } else if coefficient > 0 {
        }

        let absCoeff = abs(coefficient)

        if absCoeff != 1 || power == 0 {
            if absCoeff == floor(absCoeff) {
                str += "\(Int(absCoeff))"
            } else {
                str += "\(String(format: "%.2f", absCoeff))"
            }
        } else if absCoeff == 1 && power == 0 {
             if absCoeff == floor(absCoeff) {
                str += "\(Int(absCoeff))"
            } else {
                str += "\(String(format: "%.2f", absCoeff))"
            }
        }
        if power > 0 {
            str += "x"
            if power > 1 {
                str += "^\(power)"
            }
        }
        return str
    }
}

struct Polynomial: Identifiable, CustomStringConvertible, Hashable {
    let id = UUID()
    var terms: [Term]
    let originalString: String

    init?(rawString: String) {
        self.originalString = rawString
        var parsedTerms: [Term] = []
        let cleanedString = rawString.replacingOccurrences(of: " ", with: "")
                                     .replacingOccurrences(of: "-", with: "+-")
        
        let components = cleanedString.components(separatedBy: "+").filter { !$0.isEmpty }

        for component in components {
            if component.isEmpty { continue }

            var coeff: Double = 1.0
            var pow: Int = 0

            var tempComponent = component

            if tempComponent.hasPrefix("-") {
                coeff = -1.0
                tempComponent.removeFirst()
            }

            let pattern = #"^([+-]?\d*\.?\d*)?(x(\^(\d+))?)?$"#

            guard let regex = try? Regex(pattern) else {
                return nil
            }

            if let match = tempComponent.wholeMatch(of: regex) {
                let coefficientPart = match.output[1].substring
                let variablePart = match.output[2].substring
                let powerPart = match.output[4].substring

                if let coeffStr = coefficientPart {
                    if coeffStr.isEmpty {
                    } else if let val = Double(coeffStr) {
                        coeff *= val
                    } else {
                        return nil
                    }
                }

                if let variable = variablePart {
                    if variable.hasPrefix("x") {
                        if let pStr = powerPart {
                            if pStr.isEmpty {
                                pow = 1
                            } else if let val = Int(pStr) {
                                pow = val
                            } else {
                                return nil
                            }
                        } else {
                            pow = 1
                        }
                    } else {
                        return nil
                    }
                } else {
                }
                if coefficientPart == nil && variablePart != nil {
                } else if coefficientPart != nil && coefficientPart!.isEmpty && variablePart == nil {
                }
                parsedTerms.append(Term(coefficient: coeff, power: pow))
            } else {
                return nil
            }
        }
        guard !parsedTerms.isEmpty else { return nil }

        self.terms = parsedTerms
        self.simplify()
    }

    static func isValidPolynomial(string: String) -> Bool {
        let pattern = #"^[+-]?\s*(\d*\.?\d*\s*x(\^\d+)?|\d*\.?\d+)(\s*[+-]\s*(\d*\.?\d*\s*x(\^\d+)?|\d*\.?\d+))*$"#
        
        guard let regex = try? Regex(pattern) else {
            return false
        }
        
        return string.wholeMatch(of: regex) != nil
    }

    mutating func simplify() {
        var combinedTerms: [Int: Double] = [:]

        for term in terms {
            combinedTerms[term.power, default: 0.0] += term.coefficient
        }

        self.terms = combinedTerms
            .filter { $0.value != 0 }
            .map { Term(coefficient: $0.value, power: $0.key) }
            .sorted()
    }

    func derivative() -> Polynomial {
        var derivativeTerms: [Term] = []
        for term in terms {
            if term.power == 0 {
                continue
            }
            let newCoefficient = term.coefficient * Double(term.power)
            let newPower = term.power - 1
            derivativeTerms.append(Term(coefficient: newCoefficient, power: newPower))
        }
        
        let derivativePolynomial = Polynomial(derivedTerms: derivativeTerms)
        return derivativePolynomial
    }
    
    private init(derivedTerms: [Term]) {
        self.originalString = "Derived"
        self.terms = derivedTerms
        self.simplify()
    }
    func evaluate(at x: Double) -> Double {
        var result: Double = 0.0
        for term in terms {
            result += term.coefficient * pow(x, Double(term.power))
        }
        return result
    }

    func factor() -> String {
        guard !terms.isEmpty else { return "Cannot factor an empty polynomial." }
        let sortedTerms = terms.sorted { $0.power > $1.power }
        guard let lowestPower = sortedTerms.map({ $0.power }).min() else {
            return "Cannot factor (no terms)."
        }
        var commonCoefficient: Double = 0.0

        if terms.allSatisfy({ $0.coefficient == floor($0.coefficient) }) {
            var integerCoefficients = sortedTerms.map { Int(abs($0.coefficient)) }.filter { $0 != 0 }
            if integerCoefficients.isEmpty { return self.description }
            commonCoefficient = Double(integerCoefficients.reduce(integerCoefficients.first!) { gcd($0, $1) })
            if let firstTerm = sortedTerms.first, firstTerm.coefficient < 0 {
                commonCoefficient *= -1
            }
        } else {
            if lowestPower == 0 {
                return self.description
            }
            commonCoefficient = 1.0
        }
        if commonCoefficient == 0 {
             return self.description
        }


        if lowestPower == 0 && commonCoefficient == 1.0 {
            return self.description
        }
        
        var factoredOutPart = ""
        if commonCoefficient != 1.0 || (commonCoefficient == -1.0 && (lowestPower > 0 || sortedTerms.count > 1)) {
            if commonCoefficient == -1.0 && lowestPower == 0 && sortedTerms.count == 1 {
                factoredOutPart += "-"
            } else if commonCoefficient == floor(commonCoefficient) {
                 factoredOutPart += "\(Int(commonCoefficient))"
            } else {
                factoredOutPart += "\(String(format: "%.2f", commonCoefficient))"
            }
        }
        
        if lowestPower > 0 {
            factoredOutPart += "x"
            if lowestPower > 1 {
                factoredOutPart += "^\(lowestPower)"
            }
        }

        var remainingTerms: [Term] = []
        for term in sortedTerms {
            if commonCoefficient != 0 {
                remainingTerms.append(Term(coefficient: term.coefficient / commonCoefficient, power: term.power - lowestPower))
            } else {
                remainingTerms.append(Term(coefficient: term.coefficient, power: term.power - lowestPower))
            }
        }
        
        let remainingPolynomial = Polynomial(derivedTerms: remainingTerms)

        if factoredOutPart.isEmpty || remainingPolynomial.terms.isEmpty {
            return self.description
        }

        if remainingPolynomial.terms.count == 2 {
            let term1 = remainingPolynomial.terms[0]
            let term2 = remainingPolynomial.terms[1]
            if term1.power == 1 && term2.power == 0 {
                return "\(factoredOutPart)(\(remainingPolynomial.description))"
            }
        }
        if remainingPolynomial.terms.count == 3 {
             let sortedRemaining = remainingPolynomial.terms.sorted()
             if sortedRemaining[0].power == 2 && sortedRemaining[2].power == 0 {
                 let a_sq = sortedRemaining[0].coefficient
                 let b_sq = sortedRemaining[2].coefficient
                 let two_ab = sortedRemaining[1].coefficient

                 if a_sq == 1.0 {
                     let b = sqrt(abs(b_sq))
                     if abs(two_ab) == abs(2 * b) {
                         let sign = (two_ab / (2 * b)).sign == .minus ? "-" : "+"
                         if b_sq > 0 {
                             return "\(factoredOutPart)(x\(sign)\(Int(b)))^2"
                         }
                     }
                 }
             }
         }
        
        return "\(factoredOutPart)(\(remainingPolynomial.description))"
    }

    private func gcd(_ a: Int, _ b: Int) -> Int {
        var x = a
        var y = b
        while y != 0 {
            let temp = y
            y = x % y
            x = temp
        }
        return x
    }

    var description: String {
        guard !terms.isEmpty else { return "0" }
        var parts: [String] = []
        for term in terms.sorted() {
            if term.coefficient == 0 { continue }

            var termStr = ""
            let absCoeff = abs(term.coefficient)

            if term.coefficient < 0 {
                termStr += "-"
            } else if !parts.isEmpty {
                termStr += "+"
            }
            if absCoeff != 1 || term.power == 0 {
                if absCoeff == floor(absCoeff) {
                    termStr += "\(Int(absCoeff))"
                } else {
                    termStr += "\(String(format: "%.2f", absCoeff))"
                }
            }

            if term.power > 0 {
                termStr += "x"
                if term.power > 1 {
                    termStr += "^\(term.power)"
                }
            }
            parts.append(termStr)
        }
        if parts.isEmpty { return "0" }

        return parts.joined()
    }
}
