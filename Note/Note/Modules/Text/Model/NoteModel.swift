//
//  NoteModel.swift
//  Note
//
//  Created by haiphan on 11/10/2021.
//

import Foundation
import UIKit

struct NoteModel: Codable {
    
    enum NoteType: Int, Codable {
        case text, checkList, draw, photo, video
    }
    
    let noteType: NoteType?
    let text: String?
    let id: Date?
    let bgColorModel: BgColorModel?
    let updateDate: Date?
    
    enum CodingKeys: String, CodingKey {
        case noteType, text, bgColorModel, id, updateDate
    }
    
    func getBgColorType() -> BackgroundColor.BgColorTypes? {
        
        if let bg = self.bgColorModel, let img = bg.image {
            return .images(img)
        }
        
        if let bg = self.bgColorModel, let color = bg.color {
            return .colors(color)
        }
        
        if let bg = self.bgColorModel, let g = bg.gradient, g.count > 0 {
            return .gradient(g)
        }
        
        return nil
    }
    
}

struct BgColorModel: Codable {
    var color: String?
    var gradient: [String]?
    var image: String?
    
    enum CodingKeys: String, CodingKey {
        case color, gradient, image
    }
    
    static let empty = BgColorModel(color: nil, gradient: nil, image: nil)
}

