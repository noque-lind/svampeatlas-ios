//
//  PredictionMatch.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 03/09/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import Foundation

class PredictionMatcher {
    
    static func getSpecies(maxAmount: Int, overCertainty: Decimal, confidenceLevels: [Decimal]) -> [(String, Decimal)] {
        let taxonNames = getClasses()
        let matchedWithConfidence = confidenceLevels.enumerated().map({(taxonNames[$0.offset], $0.element)})
        var sorted = matchedWithConfidence.sorted(by: {$0.1 > $1.1})
        sorted.removeAll(where: {$0.1 < overCertainty})
        if sorted.count < maxAmount {
            return Array(sorted)
        } else {
            return Array(sorted[..<maxAmount])
        }
    }
    
    private static func getClasses() -> [String] {
        guard let path = Bundle.main.path(forResource: "species", ofType: "txt") else { return [] }
        guard let species = try? String(contentsOfFile: path, encoding: String.Encoding.utf8).split(whereSeparator: {$0.isNewline}) else { return [] }
        return species.map({$0.components(separatedBy: " ").last!.replacingOccurrences(of: "_", with: " ")})
    }
}


