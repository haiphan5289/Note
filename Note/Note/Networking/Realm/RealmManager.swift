//
//  RealmModel.swift
//  iKanBid
//
//  Created by Quân on 7/23/19.
//  Copyright © 2019 TVT25. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

class RealmManager {
    
    static var shared = RealmManager()
    var realm : Realm!
    
    init() {
        migrateWithCompletion()
        realm = try! Realm()
    }
    
    func migrateWithCompletion() {
        let config = RLMRealmConfiguration.default()
        config.schemaVersion = 7
        
        config.migrationBlock = { (migration, oldSchemaVersion) in
            if (oldSchemaVersion < 1) {
                // Nothing to do!
                // Realm will automatically detect new properties and removed properties
                // And will update the schema on disk automatically
            }
        }
        
        RLMRealmConfiguration.setDefault(config)
        print("schemaVersion after migration:\(RLMRealmConfiguration.default().schemaVersion)")
        RLMRealm.default()
    }
    
    private func getAllNoteRealm() -> [NoteRealm]  {
        let arr = realm.objects(NoteRealm.self).toArray(ofType: NoteRealm.self)
        return arr
    }
    
    func updateOrInsertConfig(model: NoteModel) {
        let list = self.getAllNoteRealm()
        
        if let index = list.firstIndex(where: { $0.id == model.id}) {
                try! realm.write {
                    
                    do {
                        let newNote = NoteModel(noteType: model.noteType, text: model.text, id: model.id, bgColorModel: model.bgColorModel,
                                                updateDate: model.updateDate, noteCheckList: model.noteCheckList, noteDrawModel: model.noteDrawModel, notePhotoModel: model.notePhotoModel)
                        list[index].data = try newNote.toData()
                    } catch {
                        print("\(error.localizedDescription)")
                    }
                }
            
            
        } else {
            let itemAdd = NoteRealm.init(model)
            try! realm.write {
                realm.add(itemAdd)
            }
        }
        NotificationCenter.default.post(name: NSNotification.Name(PushNotificationKeys.didUpdateNote.rawValue), object: model, userInfo: nil)
    }
    
    func getListNote() -> [NoteModel] {
        if self.getAllNoteRealm().count <= 0 {
            return []
        }
        
        let listRealm = self.getAllNoteRealm().map { item -> NoteModel? in
            
            guard let model = item.data?.toCodableObject() as NoteModel? else{
                return nil
            }
            
            return model
        }
        .compactMap { $0 }
        return listRealm
    }
    
    func deleteNote(note: NoteModel ) {
        let items = self.getAllNoteRealm()
        
        if let index = items.firstIndex(where: {$0.id == note.id}) {
            try! realm.write {
                realm.delete(items[index])
                NotificationCenter.default.post(name: NSNotification.Name(PushNotificationKeys.didUpdateNote.rawValue), object: items[index], userInfo: nil)
            }
        }
    }
    
    func deleteNoteAll() {
        let items = self.getAllNoteRealm()
        try! realm.write {
            realm.delete(items)
            NotificationCenter.default.post(name: NSNotification.Name(PushNotificationKeys.didUpdateNote.rawValue), object: nil, userInfo: nil)
        }
    }
    
    
}


extension Results {
    func toArray<T>(ofType: T.Type) -> [T] {
        var array = [T]()
        for i in 0 ..< count {
            if let result = self[i] as? T {
                array.append(result)
            }
        }
        return array
    }
}


extension Object {
    func toDictionary() -> [String:Any] {
        let properties = self.objectSchema.properties.map { $0.name }
        var dicProps = [String:Any]()
        for (key, value) in self.dictionaryWithValues(forKeys: properties) {
            if let value = value as? ListBase {
                dicProps[key] = value.toArray()
            } else if let value = value as? Object {
                dicProps[key] = value.toDictionary()
            } else {
                dicProps[key] = value
            }
        }
        return dicProps
    }
}

extension ListBase {
    func toArray() -> [Any] {
        var _toArray = [Any]()
        for i in 0..<self._rlmArray.count {
            if let value = self._rlmArray[i] as? Object {
                let obj = unsafeBitCast(self._rlmArray[i], to: Object.self)
                _toArray.append(obj.toDictionary())
            } else {
                _toArray.append(self._rlmArray[i])
            }
            
        }
        return _toArray
    }
}

extension Data {
    func toCodableObject<T: Codable>() -> T? {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        if let obj = try? decoder.decode(T.self, from: self) {
            return obj
        }
        return nil    }
    
}
