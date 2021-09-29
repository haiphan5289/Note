//
//  Helper.swift
//  Beach7_Waiter
//
//  Created by admin on 6/5/18.
//  Copyright © 2018 TVT25. All rights reserved.
//

import Foundation
import Foundation
import UIKit

typealias cancelBlock = (()->(Void))?
typealias dismissBlock = (()->(Void))?

class HelperAlert: UIAlertController {
//    static func showAlertWithMessage(_ message: String) {
//        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
//        let cancelAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//        alertController.addAction(cancelAction)
//        getTopViewVC().present(alertController, animated: true, completion: nil)
//    }
//    static func showAlerWithTitle(_ titleString: String? = "",message messageString: String? = "") {
//        let alertController = UIAlertController(title: titleString, message: messageString, preferredStyle: .alert)
//        let cancelAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//        alertController.addAction(cancelAction)
//        getTopViewVC().present(alertController, animated: true, completion: nil)
//    }
//    
//    static func showAlerWithTitle(_ titleString: String? = "",message messageString: String? = "",_ controller: UIViewController) {
//        let alertController = UIAlertController(title: titleString, message: messageString, preferredStyle: .alert)
//        let cancelAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//        alertController.addAction(cancelAction)
//        controller.present(alertController, animated: true, completion: nil)
//    }
//    
//    static func showAlerWithTitle(_ titleString: String? = "",message messageString: String? = "",cancelTitle cancelTitleString: String? = "",_ cancelBlock: dismissBlock = nil,_ controller: UIViewController) {
//        let alertController = UIAlertController(title: titleString, message: messageString, preferredStyle: .alert)
//        
//        if let cancelTitle = cancelTitleString {
//            let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel) { action in
//                cancelBlock!()
//            }
//            alertController.addAction(cancelAction)
//        }
//        controller.present(alertController, animated: true, completion: nil)
//    }
//    
//    static func showAlerWithTitle(_ titleString: String? = "",message messageString: String? = "",cancelTitle cancelTitleString: String? = "",_ cancelBlock: cancelBlock = nil,dismissTitle dismissTitleString: String? = "", dismissBlock: dismissBlock = nil,_ controller: UIViewController) {
//        let alertController = UIAlertController(title: titleString, message: messageString, preferredStyle: .alert)
//        
//        if let cancelTitle = cancelTitleString {
//            let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel) { action in
//                cancelBlock!()
//            }
//            alertController.addAction(cancelAction)
//        }
//        
//        if let dismissTitle = dismissTitleString {
//            let OKAction = UIAlertAction(title: dismissTitle, style: .default) { action in
//                dismissBlock!()
//            }
//            alertController.addAction(OKAction)
//        }
//        controller.present(alertController, animated: true, completion: nil)
//    }
//    
//    static func showActionSheetWithTitle(_ titleString: String? = "",first firstString: String? = "" ,_ firstBlock: cancelBlock = nil,second secondString: String? = "",_ secondBlock: cancelBlock = nil,dismissTitle dismissTitleString: String? = "", dismissBlock: dismissBlock = nil,_ controller: UIViewController) {
//        
//        let optionMenu = UIAlertController(title: titleString, message: "", preferredStyle: .actionSheet)
//        let cameraAction = UIAlertAction(title: firstString, style: .default, handler: {
//            (alert: UIAlertAction!) -> Void in
//            firstBlock!()
//        })
//        
//        let libraryAction = UIAlertAction(title: secondString, style: .default, handler: {
//            (alert: UIAlertAction!) -> Void in
//            secondBlock!()
//
//        })
//        
//        let cancelAction = UIAlertAction(title: "Hủy", style: .default, handler: {
//            (alert: UIAlertAction!) -> Void in
//            dismissBlock!()
//        })
//        optionMenu.addAction(cameraAction)
//        optionMenu.addAction(libraryAction)
//        optionMenu.addAction(cancelAction)
//        controller.present(optionMenu, animated: true, completion: nil)
//    }
    
}

