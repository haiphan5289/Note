//
//  RealmModel.swift
//  KFC
//
//  Created by Dong Nguyen on 12/12/19.
//  Copyright © 2019 TVT25. All rights reserved.
//

import Foundation
import RealmSwift
import UIKit

class NoteRealm: Object {
    @objc dynamic var data: Data?
    @objc dynamic var id: Date?

    init(_ model: NoteModel) {
        super.init()
        do {
            data = try model.toData()
            id = model.id
        } catch {
            print("\(error.localizedDescription)")
        }
        

    }    
    required init() {
        super.init()
    }
}


