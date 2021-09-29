//
//  Prefix-Header.swift
//  Restaurant
//
//  Created by TVT25 on 8/3/16.
//  Copyright © 2016 TVT25. All rights reserved.
//

import UIKit
import CoreData

func getDataFromFileJSON(_ name: String) -> NSDictionary {
    
    if let path = Bundle.main.path(forResource: name, ofType: "json")
    {
        if let jsonData = try? NSData(contentsOfFile: path, options: .mappedIfSafe)
        {
            if let jsonResult: NSDictionary = try! JSONSerialization.jsonObject(with: jsonData as Data, options: []) as? NSDictionary
            {
                if jsonResult != nil {
                    print(jsonResult)
                    return jsonResult
                    
                }
                
            }
        }
    }
    return NSDictionary()
}

//********************************************************************************************//
//********************************************************************************************//
let NEW_ORDER = "NEW_ORDER"


///---------------------------------------------------------------------------------------
/// CONNECT_INTERNET
///---------------------------------------------------------------------------------------
//MARK: - CONNECT_INTERNET
var IS_CONNETED_INTERNET = true


///---------------------------------------------------------------------------------------
/// SERVER
///---------------------------------------------------------------------------------------
//MARK: - SERVER

//let DOMAIN = "" //LIVE
//let DOMAIN = "https://dayshee.com.vn" //DEV
//let DOMAIN = "https://woodpeckers.kendemo.com" //DEV
let DOMAIN = "https://api.dayshee.com" //Live




let API = "api/v1"

let SERVER = "\(DOMAIN)/\(API)"



///---------------------------------------------------------------------------------------
/// USERDEFAULT KEYWORD
///---------------------------------------------------------------------------------------
//MARK: - USERDEFAULT KEYWORD
let CUR_USER = "USER"
let USER_LOGIN = "USER_LOGIN"
let USER_PASSWORD = "USER_PASSWORD"
let LOGIN_MODE = "LOGIN_MODE"



///---------------------------------------------------------------------------------------
/// NOTIFICATION KEYWORD
///---------------------------------------------------------------------------------------
//MARK: - NOTIFICATION KEYWORD

let STORYBOARD_HOME = UIStoryboard(name: "Home", bundle: nil)
let STORYBOARD_AUTH = UIStoryboard(name: "Authen", bundle: nil)
let STORYBOARD_SETTING = UIStoryboard(name: "Setting", bundle: nil)
let STORYBOARD_ORDERS = UIStoryboard(name: "Orders", bundle: nil)
let STORYBOARD_NOTIFICATION = UIStoryboard(name: "Notification", bundle: nil)
let STORYBOARD_CART = UIStoryboard(name: "Cart", bundle: nil)

///---------------------------------------------------------------------------------------
/// COLOR
///---------------------------------------------------------------------------------------
//MARK: - COLOR



///---------------------------------------------------------------------------------------
/// SUBMIT APPLE STORE
///---------------------------------------------------------------------------------------
//MARK: - SUBMIT APPLE STORE

let APPLE_ID = ""
let URL_APPSTORE = ""
let GOOGLE_CLIENT_ID = "273646570570-l7vtfonul10ui9ofkmgpl1qvoksh4d6t.apps.googleusercontent.com"
let FIR_DATABASE_CHAT = "https://rescuemoto.firebaseio.com/"
var googleAPI_Key = "AIzaSyDrNEGC_2D2GniqRNtXzDlkUA2AgVdPong"
var googleAPI_Key_web = "AIzaSyDMEfNVVF0ezF5nVUic7j6FS2wgdBNF33s"



//********************************************************************************************//
//********************************************************************************************//

/// NOT CHANGE

//********************************************************************************************//
//********************************************************************************************//


///---------------------------------------------------------------------------------------
/// APPLICATION
///---------------------------------------------------------------------------------------
//MARK: - APPLICATION

@available(iOS 13.0, *)
let SHARE_APPLICATION_DELEGATE = UIApplication.shared.delegate as! AppDelegate

#if targetEnvironment(simulator)
let IS_SIMULATOR = true
#else
let IS_SIMULATOR = false
#endif


///---------------------------------------------------------------------------------------
/// PATH
///---------------------------------------------------------------------------------------

//MARK: - PATH

let PATH_OF_APP_HOME = NSHomeDirectory()
let PATH_OF_TEMP = NSTemporaryDirectory()

///---------------------------------------------------------------------------------------
/// SCREEN FRAME
///---------------------------------------------------------------------------------------
//MARK: - SCREEN FRAME

let SCREEN_WIDTH = UIScreen.main.bounds.size.width
let SCREEN_HEIGHT = UIScreen.main.bounds.size.height

let SCREEN_MAX_LENGTH = max(SCREEN_WIDTH, SCREEN_HEIGHT)
let SCREEN_MIN_LENGTH = min(SCREEN_WIDTH, SCREEN_HEIGHT)
let SIZEHEIGHT_NAVI = CGFloat(64)


let IS_IPAD: Bool = (UIDevice.current.userInterfaceIdiom == .pad)
let IS_IPHONE: Bool = (UIDevice.current.userInterfaceIdiom == .phone)
let IS_RETINA: Bool = (UIScreen.main.scale >= 2.0)

let IS_IPHONE_4S: Bool = (IS_IPHONE&&(SCREEN_MAX_LENGTH < 568.0))
let IS_IPHONE_5: Bool = (IS_IPHONE&&(SCREEN_MAX_LENGTH == 568.0))
let IS_IPHONE_6: Bool = (IS_IPHONE&&(SCREEN_MAX_LENGTH == 667.0))
let IS_IPHONE_6P: Bool = (IS_IPHONE&&(SCREEN_MAX_LENGTH == 736.0))
let IS_IPHONE_X: Bool = (IS_IPHONE&&(SCREEN_MAX_LENGTH == 812.0))
let IS_IPHONE_XSM: Bool = (IS_IPHONE&&(SCREEN_MAX_LENGTH == 896.0))


let QUANLITY_IMAGE:CGFloat = 0.5
let SIZEHEIGHT_TABBAR = IS_IPHONE_X || IS_IPHONE_XSM ? 88 : 49

///---------------------------------------------------------------------------------------
/// SERVICE MOTHOD
///---------------------------------------------------------------------------------------
//MARK: - SERVICE MOTHOD

let POST_METHOD = "POST"
let GET_METHOD = "GET"
let PUT_METHOD = "PUT"


///---------------------------------------------------------------------------------------
/// FONTS
///---------------------------------------------------------------------------------------
//MARK: - FONTS

let FONT_DEFAULT            =  "Poppins"
let FONT_BOLD               =  "Poppins-Bold"
let FONT_BOLD_ITALIC        =  "Poppins-BoldItalic"
let FONT_ITALIC             =  "Poppins-Italic"
let FONT_LIGHT              =  "Poppins-Light"
let FONT_LIGHT_ITALIC       =  "Poppins-LightItalic"
let FONT_MEDIUM             =  "Poppins-Medium"
let FONT_MEDIUM_ITALIC      =  "Poppins-MediumItalic"
let FONT_REGULAR            =  "Poppins"
let FONT_THIN               =  "Poppins-Thin"
let FONT_THIN_ITALIC        =  "Poppins-ThinItalic"
let FONT_ULTRA_LIGHT        =  "Poppins-UltraLight"
let FONT_ULTRA_LIGHT_ITALIC =  "Poppins-UltraLightItalic"
let FONT_COND_BLACK         =  "Poppins-CondensedBlack"
let FONT_COND_BOLD          =  "Poppins-CondensedBold"


///---------------------------------------------------------------------------------------
/// REX KEYWORD
///---------------------------------------------------------------------------------------
//MARK: - REX KEYWORD


let REGEX_ZIPCODE_LIMIT     = "^.{5,10}$"
let REGEX_ZIPCODE           = "^([0-9]{5})(?:[-\\s]*([0-9]{4}))?$"
let REGEX_PASSWORD_LIMIT    = "^.{6,20}$"
let REGEX_PASSWORD          = "[A-Za-z0-9]{6,20}"
let REGEX_USER_NAME_LIMIT   = "^.{3,15}$"
let REGEX_USER_NAME         = "[a-z0-9_]{3,15}"
let REGEX_EMAIL             = "[A-Z0-9a-z._%+-]{3,}+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
let REGEX_PHONE_US          = "((\\(\\d{3}\\) ?)|(\\d{3}-))?\\d{3}-\\d{4}"
let REGEX_NUMBER            = "^\\d+$"
let REGEX_NUMBER_COMMA      = "^\\d{1,3}([,]\\d{3})*$"
let REGEX_ALPHABET          = "^[a-zA-Z]+$"
let REGEX_ALPHA_NUMERIC     = "^[a-zA-Z0-9]+$"
let REGEX_CREDIT_CARD_LIMIT = "^.{10,23}$"//12-19
let REGEX_CVV_LIMIT         = "^.{3,4}$"
let REGEX_NULL              = "^\\s*$"

///---------------------------------------------------------------------------------------
/// TABBAR KEYWORD
///---------------------------------------------------------------------------------------
//MARK: - TABBAR KEYWORD
let GOTO_HOME_TAB = 0
let GOTO_ORDER_HISTORY_TAB = 1
let GOTO_CART_TAB = 2
let GOTO_NOTIFICATION_TAB = 3
let GOTO_SETTING_TAB = 3


//********************************************************************************************//
//********************************************************************************************//
//********************************************************************************************//
//********************************************************************************************//
//********************************************************************************************//
//********************************************************************************************//
//********************************************************************************************//

//#define MsgEmail         @"Plase Enter Valid Email."
//#define MsgEmailEmpty    @"Plase Enter Email."
//#define MsgPasswordEmpty    @"Plase Enter Password."

///---------------------------------------------------------------------------------------
/// MESSAGE KEYWORD
///---------------------------------------------------------------------------------------
//MARK: - MESSAGE KEYWORD

let MsgEmail = "Please Enter Valid Email."
let MsgEmailEmpty = "Please Enter Email."
let MsgPasswordEmpty = "Please Enter Password."
let MsgValidEmail = "Email is invalid"
let MsgRequired = "Required field"
let MsgValidZipCode = "Zipcode is invalid"
let MsgValidPhone = "Phone number must be in proper format (eg. (###) ###-####)"
let MsgValidPassword = "Password characters limit should be come between 6 - 20"
let kMale = "Male"
let kFemale = "Female"

let MsgLogin = "Login failed."
let kSuccessPayment = "kSuccessPayment"
let kPayInfoSuccess = "kPayInfoSuccess"
let kInquiryAddingSuccess = "kInquiryAddingSuccess"
let kDetailShowInfomation = "Request to show information."
let kDetailShowRelationship = "Request to show relationship."
let kRelationShip = "RELATIONSHIP"
let kOnlineDating = "ONLINE DATING"
let kWebandAppUsage = "DATING WEBSITE AND APP USAGE"
let kStatistic = "STATISTIC"
let kReceiveNewMessage = "kReceiveNewMessage"
let kDefaultDateFormat = "yyyy-MM-dd"
class Prefix_Header: UIViewController {
    
}


let PHONE_FORMAT = "***-***-****"
let CARD_FORMAT = "**** **** **** **** ****"
let CHARACTER_FORMAT = "*".utf16.first!
let kPlaceHolder : UIImage = #imageLiteral(resourceName: "no_image2")
