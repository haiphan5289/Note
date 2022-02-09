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
    let titleNotificaiton: String = "You have a Notfication Note"
    let identifierNotification: String = "PushLocalNote"
    let policy: String = "https://sites.google.com/view/marvel-note/trang-ch%E1%BB%A7"
    
    private init() {}

    func getHeightSafeArea(type: GetHeightSafeArea.SafeAreaType) -> CGFloat {
        return GetHeightSafeArea.shared.getHeight(type: type)
    }
    
    func getCurrentViewController() -> UIViewController? {
        // If the root view is a navigation controller, we can just return the visible ViewController
        if let navigationController = getNavigationController() {
            return navigationController.visibleViewController
        }
        // Otherwise, we must get the root UIViewController and iterate through presented views
        if let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first, let rootController = window.rootViewController {
            var currentController: UIViewController! = rootController
            // Each ViewController keeps track of the view it has presented, so we
            // can move from the head to the tail, which will always be the current view
            while( currentController.presentedViewController != nil ) {
                currentController = currentController.presentedViewController
            }
            return currentController
        }
        return nil
    }

    // Returns the navigation controller if it exists
    func getNavigationController() -> UINavigationController? {
        if let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first, let navigationController = window.rootViewController  {
            return navigationController as? UINavigationController
        }
        return nil
    }
    
}
