//
//  Constant.swift
//  CameraMakeUp
//
//  Created by haiphan on 22/09/2021.
//

import Foundation
import UIKit

final class Constant {
    static var shared = Constant()
    let bigRadiusTabbar: CGFloat = 30
    
    private init() {}

    func getHeightSafeArea(type: GetHeightSafeArea.SafeAreaType) -> CGFloat {
        return GetHeightSafeArea.shared.getHeight(type: type)
    }
    
    
    
}
