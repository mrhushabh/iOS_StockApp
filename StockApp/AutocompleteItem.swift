//
//  AutocompleteItem.swift
//  Stocksearch
//
//  Created by Rhushabh Madurwar on 4/7/24.
//

import Foundation
struct AutocompleteItem: Decodable {

  
        let id: UUID = UUID()
        let description: String
        let displaySymbol: String
        let symbol: String
        let type: String
    
   
}
