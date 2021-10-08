//
//  ColorsModel.swift
//  Note
//
//  Created by haiphan on 08/10/2021.
//

import Foundation
struct ColorModel: Codable {
    let text: String?
    
    enum CodingKeys: String, CodingKey {
        case text
    }
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        text = try values.decodeIfPresent(String.self, forKey: .text)
    }
    
}
