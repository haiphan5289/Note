//
//  Constant.swift
//  CameraMakeUp
//
//  Created by haiphan on 22/09/2021.
//

import Foundation
import UIKit

final class ConstantApp {
    static var shared = ConstantApp()
    let bigRadiusTabbar: CGFloat = 30
    let distanceCellHome: CGFloat = 10
    let distanceAreaSide: CGFloat = 16
    let timeAnimation: Double = 0.5
    let sizeDefault: CGFloat = 18
    let fontDefault: UIFont = UIFont(name: SettingDefaultFont.DEFAULT_NAME_FONT, size: 18) ?? .systemFont(ofSize: 18)
    let radiusViewDialog: CGFloat = 12
    let radiusSegment: CGFloat = 12
    let radiusCellBgColor: CGFloat = 12
    let radiusHomeNoteCell: CGFloat = 6
    
    private init() {}

    func getHeightSafeArea(type: GetHeightSafeArea.SafeAreaType) -> CGFloat {
        return GetHeightSafeArea.shared.getHeight(type: type)
    }
    
    
    
}
