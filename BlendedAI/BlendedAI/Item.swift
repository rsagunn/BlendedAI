//
//  Item.swift
//  BlendedAI
//
//  Created by Reilan Sagun on 2026-05-05.
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
