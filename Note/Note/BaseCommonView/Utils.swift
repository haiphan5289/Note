//
//  Utils.swift
//  GreenBee_Fantasy
//
//  Created by ThanhPham on 7/14/17.
//  Copyright © 2017 TVT25. All rights reserved.
//

import UIKit
import Foundation
import Photos
//import GooglePlaces
import ActionSheetPicker_3_0
import SKPhotoBrowser


class Utils {
    
    static var shared = Utils()
    
//    func gotoZoomImage(images:[String], index: Int) {
//        guard let rootVC = UIViewController.getTopViewController() else {return}
//            var photos: [SKPhoto] = []
//            for url in images {
//                guard let imageURLString =  url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
//                    return
//                }
//                photos.append(SKPhoto.photoWithImageURL(imageURLString))
//            }
//            // 2. create PhotoBrowser Instance, and present.
//            let browser = SKPhotoBrowser(photos: photos)
//            browser.initializePageIndex(index)
//            rootVC.present(browser, animated: true, completion: {})
//    }
//    
//    
    func gotoHome( ) {
//        guard let winScene = (scene as? UIWindowScene) else { return }
//        window = UIWindow(windowScene: winScene)
//        let navi: UINavigationController = UINavigationController(rootViewController: HomeTabbar())
//        window?.rootViewController = navi
//        window?.makeKeyAndVisible()
//        let SHARE_APPLICATION_DELEGATE = UIApplication.shared.delegate as! AppDelegate
//        SHARE_APPLICATION_DELEGATE.tabbar = BaseTabbarViewController()
//        SHARE_APPLICATION_DELEGATE.window?.rootViewController = SHARE_APPLICATION_DELEGATE.tabbar
        
    }
//    
//    func gotoTutorial( ) {
//        SHARE_APPLICATION_DELEGATE.tutorial = TutorialVC(nibName: "TutorialVC", bundle: nil)
//        SHARE_APPLICATION_DELEGATE.window?.rootViewController = BaseNavigationController(rootViewController: SHARE_APPLICATION_DELEGATE.tutorial!)
//    }
//    
//    func gotoLogin() {
//        
//        let nav =  STORYBOARD_AUTH.instantiateViewController(withIdentifier: LoginVC.className) as! LoginVC
//        SHARE_APPLICATION_DELEGATE.window?.rootViewController = BaseNavigationController(rootViewController: nav)
//    }
//    
//    static func saveObject(_ customObject: Any, _ key: String) {
//        let userdefault = UserDefaults.standard
//        let data: Data = NSKeyedArchiver.archivedData(withRootObject: customObject)
//        userdefault.setValue(data, forKey: key)
//        userdefault.synchronize()
//    }
//    
//    static func loadObject(_ key: String) ->NSObject? {
//        let userdefault = UserDefaults.standard
//        if let data: NSObject = userdefault.object(forKey: key) as? NSObject {
//            return NSKeyedUnarchiver.unarchiveObject(with: data as! Data) as? NSObject
//        }
//        return nil
//    }
//    
//    static func removeObject(_ key: String){
//        let userdefault = UserDefaults.standard
//        if userdefault.object(forKey: key) != nil {
//            userdefault.removeObject(forKey: key)
//            userdefault.synchronize()
//        }
//    }
//    
//    static func validateEmail(_ email: String) -> Bool{
//        
//        if email.count == 0 {
//            return false
//        }
//        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,20}"
//        let emailTest  = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
//        return emailTest.evaluate(with: email)
//    }
//    
//    
//    func getAssetThumbnail(asset: PHAsset) -> UIImage? {
//        var img: UIImage?
//        let manager = PHImageManager.default()
//        let options = PHImageRequestOptions()
//        options.deliveryMode = .fastFormat
//        options.resizeMode = .exact
//        options.isSynchronous = true
//        options.version = .original
//        options.isNetworkAccessAllowed = true
//        
//        manager.requestImageData(for: asset, options: options) { data, _, _, _ in
//            if let data = data {
//                img = UIImage(data: data)
//            }
//        }
//        return img
//    }
//    
//    
//    func toAddress(lat: Double,long: Double, complete: @escaping(_ state: String, _ city: String, _ street: String,_ name: String)->()) {
//        
//        let geoCoder = CLGeocoder()
//        let location = CLLocation(latitude: lat , longitude: long)
//        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
//            var placeMark: CLPlacemark!
//            placeMark = placemarks?[0]
//            var city_ = ""
//            var state_ = ""
//            var street_ = ""
//            var name_ = ""
//            // Country
//            if placeMark == nil {
//                return
//            }
//            guard let address = placeMark.addressDictionary else {return}
//            guard   /*let country = address["Country"] as? String,*/
//                let city = address["City"] as? String,
//                let state = address["State"] as? String,
//                let street = address["Street"] as? String,
//                let name = address["Name"] as? String
//                else {return}
//            
//            city_ = city
//            state_ = state
//            street_ = street
//            name_ = name
//            complete(state_, city_, street_, name_)
//        })
//    }
//    func reverseGeocodeLocation(coordinate : CLLocationCoordinate2D, completeHanler : @escaping ((_ clPlacemarks : [CLPlacemark]?)->())) {
//        if #available(iOS 11.0, *) {
//            CLGeocoder().reverseGeocodeLocation(CLLocation.init(latitude: coordinate.latitude, longitude: coordinate.longitude)) { (data, error) in
//                completeHanler(data)
//            }
//        } else {
//            //            UserDefaults.standard.set(["vi_VN"], forKey: "AppleLanguages")
//            CLGeocoder().reverseGeocodeLocation(CLLocation.init(latitude: coordinate.latitude, longitude: coordinate.longitude)) { (data, error) in
//                completeHanler(data)
//            }
//        }
//    }
//    
//    
//    func fetchPlacemarks(clPlacemarks : [CLPlacemark]) -> (String?, String?, String?, String?, String?){
//        var address : String?
//        var subLocality : String?
//        var locality : String?
//        var postalCode : String?
//        var country : String?
//        for clPlacemark in clPlacemarks {
//            if let _subLocality = clPlacemark.subAdministrativeArea, subLocality == nil {
//                subLocality = _subLocality
//            }
//            if let _locality = clPlacemark.administrativeArea, locality == nil {
//                locality = _locality
//            }
//            if let _postalCode = clPlacemark.postalCode, postalCode == nil {
//                postalCode = _postalCode
//            }
//            if let _country = clPlacemark.country, country == nil {
//                country = _country
//            }
//            if let addrList = clPlacemark.addressDictionary?["FormattedAddressLines"] as? [String], address == nil {
//                address = addrList.joined(separator: ", ")
//            }
//        }
//        return (address, subLocality, locality, postalCode, country)
//    }
//    
//    func convertLocationToCityAddressCountry(coordinate : CLLocationCoordinate2D, completeHandler : @escaping ((String?, String?, String?, String?, String?)->())) {
//        self.reverseGeocodeLocation(coordinate: coordinate) {(places) in
//            guard let result = places else {return}
//            let (address, administrativeArea, locality, postalCode, country) = Utils.shared.fetchPlacemarks(clPlacemarks: result)
//            completeHandler(address, administrativeArea, locality, postalCode, country)
//        }
//    }
//    
//    func showCommonNotification(isSuccess : Bool, message : String, completeHandler : (()->())?) {
//        guard let viewController = UIViewController.getTopViewController() else {
//            return
//        }
//        viewController.showAlert(title: message, message: nil, buttonTitles: nil, highlightedButtonIndex: nil) { (index) in
//            if completeHandler != nil {
//                completeHandler!()
//            }
//        }
//    }
//    
//    func showCommonToastMessage(viewController : UIViewController, isSuccess : Bool, message : String, completeHandler : (()->())?) {
//        if isSuccess {
//            viewController.view.makeToast(message: message, duration: 2) {
//                if completeHandler != nil {
//                    completeHandler!()
//                }
//            }
//        } else {
//            viewController.showAlert(title: message, message: nil, buttonTitles: nil, highlightedButtonIndex: nil) { (index) in
//                if completeHandler != nil {
//                    completeHandler!()
//                }
//            }
//        }
//    }
//    
//    func showDatePicker(origin : UIView, _ mode : UIDatePicker.Mode = .date,  completeHandler: @escaping(_ item : Date?)->()) {
//        ActionSheetDatePicker.show(withTitle: "", datePickerMode: mode, selectedDate: Date(), doneBlock: { (picker, selectedDate, orgin) in
//            guard let selectedDate = selectedDate as? Date else {
//                completeHandler(nil)
//                return
//            }
//            completeHandler(selectedDate)
//        }, cancel: { (picker) in
//            
//        }, origin: origin)
//    }
//    
//    func showInforPicker(items:[String], completeHandler: @escaping(_ item : String?, _ index : Int?)->()) {
//        guard let rootView = SHARE_APPLICATION_DELEGATE.window?.rootViewController else {return}
//        ActionSheetStringPicker.show(withTitle: "", rows: items as [Any] , initialSelection: 0, doneBlock: { (picker, index, orgin) in
//            completeHandler(items[index], index)
//        }, cancel: { (picker) in
//            completeHandler(nil, nil)
//        }, origin: rootView.view)
//    }
}


