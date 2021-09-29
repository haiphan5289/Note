//
//  BaseTabarViewController.swift
//  Ayofa
//
//  Created by Admin on 3/5/20.
//  Copyright © 2020 ThanhPham. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit

class BaseTabbarViewController: UITabBarController {
    
    var customTabbar: CustomTabbar!
    
    private let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.setupVar()
        self.setupUI()
        self.loadTabBar()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func setupVar() {
//        setupTabbar()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        let height: CGFloat = tabBar.frame.height + Constant.shared.getHeightSafeArea(type: .bottom)
//        var tabFrame            = tabBar.frame
//        tabFrame.size.height    = height
//        tabFrame.origin.y       = view.frame.size.height - height
//        self.customTabbar.frame            = tabFrame
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
//        guard let listTabbar = self.tabBar.items else {
//            return
//        }
//        
//        listTabbar.enumerated().forEach { (tabbar) in
//            if let type = TypeTabbar(rawValue: tabbar.offset) {
//                if tabbar.element == item {
//                    tabbar.element.image = type.imageActive
//                } else {
//                    tabbar.element.image = type.image
//                }
//            }
//        }
        
    }
    
    func setupUI() {
//        self.tabBar.isTranslucent = false
//        UITabBar.appearance().tintColor = Asset.color1.color
        UITabBar.appearance().barTintColor = TABBAR_COLOR
//        self.view.backgroundColor = Asset.colorApp.color
        let frame = self.tabBar.frame
        self.tabBar.isHidden = true
        self.customTabbar = CustomTabbar(frame: frame)
        self.view.addSubview(self.customTabbar)
        self.customTabbar.backgroundColor = .clear
    }
    
//    func setupTabbar() {
//        let homeVC = HomeVC.createVC()
//        self.viewControllers = [homeVC]
//
//        TypeTabbar.allCases.forEach { (type) in
//            if let vc = self.viewControllers?[type.rawValue] {
//                vc.tabBarItem.title = type.text
//            }
//        }
//    }
    
    func loadTabBar() {
        // Tạo và load custom tab bar
        let tabbarItems: [CustomTabbar.TabItem] = [.home, .menu]
        
        setupCustomTabMenu(tabbarItems, completion: { viewControllers in
            self.viewControllers = viewControllers
        })
        
        selectedIndex = 0
    }

    func setupCustomTabMenu(_ menuItems: [CustomTabbar.TabItem], completion: @escaping ([UIViewController]) -> Void) {
        // Handle custom tab bar và các attach touch event listener
        let frame = tabBar.frame
        var controllers = [UIViewController]()
        
        // Thêm các view controller tương ứng
        menuItems.forEach({
            controllers.append($0.viewController)
            
            // Khởi tạo custom tab bar
            let customTabbar = CustomTabbarView(menuItem: $0, frame: frame)
            customTabbar.backgroundColor = Asset.appBg.color
            customTabbar.tag = $0.rawValue
            customTabbar.clipsToBounds = true
            customTabbar.itemTapped = changeTab(tab:)
            self.customTabbar.addSubview(customTabbar)
            
            switch $0 {
            case .home:
                // Auto layout cho custom tab bar
                customTabbar.snp.makeConstraints { make in
                    make.left.top.equalToSuperview()
                    make.height.equalTo(self.customTabbar.frame.height)
                    make.width.equalTo(self.getWidthView())
                }
            case .menu:
                // Auto layout cho custom tab bar
                customTabbar.snp.makeConstraints { make in
                    make.right.top.equalToSuperview()
                    make.height.equalTo(self.customTabbar.frame.height)
                    make.width.equalTo(self.getWidthView())
                }
            }
            customTabbar.itemTapped = { [weak self] index in
                guard let wSelf = self else { return }
                wSelf.changeTab(tab: index)
            }
        })
        
        completion(controllers)
    }

    func changeTab(tab: Int) {
        self.selectedIndex = tab
        self.customTabbar.subviews.forEach { v in
            if let v = v as? CustomTabbarView {
                if v.tag == tab {
                    v.activateTab()
                } else {
                    v.deactivateTab()
                }
            }
        }
    }
    
    private func getWidthView() -> CGFloat {
        let countHaftCustomTabbar: CGFloat = CGFloat((CustomTabbar.TabItem.allCases.count / 2))
        let w = ((self.view.frame.width / 2) - Constant.shared.bigRadiusTabbar) / countHaftCustomTabbar
        return w
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        // Handle didSelect viewController method here
    }
}
