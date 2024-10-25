//
//  Item.swift
//  StockApp
//
//  Created by Rhushabh Madurwar on 10/7/24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
