//
//  SearchStringParser.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 14/08/2022.
//  Copyright © 2022 NaturhistoriskMuseum. All rights reserved.
//

import Foundation

class SearchStringParser {
    private init () {}
    
    
    struct SpeciesSearchResult {
        let genus: String
        let fullSearch: String
        let taxonName: String
    }
    
    static func parseSpeciesSearch(searchString: String, unicode: Bool = true) -> SpeciesSearchResult {
        var genus = ""
        var fullSearchTerm = ""
        var taxonName = ""
        
        for word in searchString.components(separatedBy: " ") {
            guard word != "" else {break}
            if fullSearchTerm == "" {
                fullSearchTerm = word
                genus = word
            } else {
                fullSearchTerm += "\(unicode == true ? "+": " ")\(word)"
                if taxonName == "" {
                    taxonName = word
                } else {
                    taxonName += "+\(word)"
                }
            }
        }
        return SpeciesSearchResult(genus: genus, fullSearch: fullSearchTerm, taxonName: taxonName)
    }
}
