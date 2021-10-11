//
//  NoteModel.swift
//  Note
//
//  Created by haiphan on 11/10/2021.
//

import Foundation

struct NoteModel: Codable {
    
    enum NoteType: Int, Codable {
        case text, checkList, draw, photo, video
    }
    
    let noteType: NoteType?
    let text: String?
    let id: Date = Date.convertDateToLocalTime()
    
    enum CodingKeys: String, CodingKey {
        case noteType, text
    }
    
}
