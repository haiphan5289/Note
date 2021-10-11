//
//  NoteManage.swift
//  Note
//
//  Created by haiphan on 29/09/2021.
//

import Foundation
import UIKit
import RxSwift

final class NoteManage {
    static var shared = NoteManage()
    
    @VariableReplay var listNote: [NoteModel] = []
    
    private init() {}
    
    func start() {
        self.getListNote()
    }
    
    private func getListNote() {
        self.listNote = RealmManager.shared.getListNote()
    }
    
    func getWidthCell(width: CGFloat) -> CGFloat {
        return (width - (ConstantCommon.shared.distanceAreaSide * 2) - (ConstantCommon.shared.distanceAreaSide * 2)) / 3
    }
}
