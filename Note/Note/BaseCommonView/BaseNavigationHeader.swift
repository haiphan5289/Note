//
//  BaseNavigationHeader.swift
//  Note
//
//  Created by haiphan on 02/10/2021.
//

import Foundation
import UIKit

final class BaseNavigationHeader: UIViewController {
    
    let navigationItemView: NavigationItemView = NavigationItemView.loadXib()
    
    var vContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
            // MARK: Navigation Bar Customisation
//        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white,
//                                                                        NSAttributedString.Key.font: UIFont.myMediumSystemFont(ofSize: 18)]
//        self.navigationController?.navigationBar.barTintColor = UIColor(named: "ColorApp")
//
//        let v: UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.navigationController?.navigationBar.frame.height ?? 50))
//        v.backgroundColor = .clear
//        self.navigationItem.titleView = v
//
//        v.addSubview(self.navigationItemView)
//        self.navigationItemView.snp.makeConstraints { (make) in
//            make.bottom.left.right.top.equalToSuperview()
//        }
        
        self.navigationItem.leftBarButtonItem = nil
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white,
                                                                        NSAttributedString.Key.font: UIFont.myMediumSystemFont(ofSize: 18)]
        self.navigationController?.navigationBar.barTintColor = Asset.colorApp.color
        
        vContainer = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.navigationController?.navigationBar.frame.height ?? 50))
           
        vContainer.backgroundColor = UIColor.clear
        vContainer.clipsToBounds = true
        vContainer.addSubview(self.navigationItemView)
        self.navigationItemView.snp.makeConstraints { (make) in
            make.bottom.top.equalToSuperview()
            make.left.right.equalToSuperview().inset(16)
        }
        navigationController?.navigationBar.addSubview(vContainer)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        vContainer.removeFromSuperview()
    }
}
