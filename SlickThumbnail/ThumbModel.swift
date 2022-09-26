//
//  ThumbModel.swift
//  SlickThumbnail
//
//  Created by Nick Raptis on 9/25/22.
//

import Foundation

struct ThumbModel: Equatable {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.index == rhs.index
    }
    
    static func mock() -> ThumbModel {
        return ThumbModel(index: 0, image: "🧫", downloadDidSucceed: false, downloadDidFail: false)
    }
    
    let index: Int
    let image: String
    
    // Wrapper, not part of purist JSON model
    var downloadDidSucceed: Bool
    var downloadDidFail: Bool
}
