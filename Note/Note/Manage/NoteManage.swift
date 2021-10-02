//
//  NoteManage.swift
//  Note
//
//  Created by haiphan on 29/09/2021.
//

import Foundation
import UIKit

final class NoteManage {
    static var shared = NoteManage()
    
    private init() {}
    
    func getWidthCell(width: CGFloat) -> CGFloat {
        return (width - (ConstantCommon.shared.distanceAreaSide * 2) - (ConstantCommon.shared.distanceAreaSide * 2)) / 3
    }
}
