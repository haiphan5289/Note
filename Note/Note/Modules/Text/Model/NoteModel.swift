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
    
}

struct BgColorModel: Codable {
    var color: String?
    var gradient: [String]?
    var image: String?
    var textFont: String?
    var sizeFont: CGFloat?
    var indexFont: Int?
    var indexFontStyle: Int?
    var textColorString: String?
    
    enum CodingKeys: String, CodingKey {
        case color, gradient, image, textFont, sizeFont, indexFont, indexFontStyle, textColorString
    }
    
    func getBgColorType() -> BackgroundColor.BgColorTypes? {
        
        if let img = self.image {
            return .images(img)
        }
        
        if let color = self.color {
            return .colors(color)
        }
        
        if let g = self.gradient, g.count > 0 {
            return .gradient(g)
        }
        
        return nil
    }
    
    func getFont() -> UIFont? {
        if let f = self.textFont, let size = self.sizeFont {
            return UIFont(name: f, size: size)
        }
        return ConstantApp.shared.fontDefault
    }
    
    
    
    static let empty = BgColorModel(color: nil, gradient: nil, image: nil, textFont: nil, sizeFont: nil, indexFont: nil, indexFontStyle: nil, textColorString: nil)
}

