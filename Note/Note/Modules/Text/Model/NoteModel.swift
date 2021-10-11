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
    let id: Date = Date.convertDateToLocalTime()
    let color: String?
    let gradient: [String]?
    let image: String?
    
    enum CodingKeys: String, CodingKey {
        case noteType, text, color, gradient, image
    }
    
//    func getBgColorType() -> BackgroundColor.BgColorTypes {
//        
//        if self.image != nil {
//            return .colors(.red)
//        }
//        
//        return .colors(.red)
//    }
    
}

