//
//  PopBaseViewController.swift
//  GoShare_Customer
//
//  Created by admin on 10/8/18.
//  Copyright © 2018 TVT25. All rights reserved.
//

import UIKit

class PopBaseViewController: UIViewController {
    var parentView: UIViewController?
    var callBackWithAction: ((_ action: Int?, _ value: Any?) -> ())?
    var callBackWithAction2: ((_ action: Int?, _ value: Any? , _ value: Any?) -> ())?

    //MARK: INNIT POP
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true

    }
    
    override func viewWillDisappear(_ animated: Bool) {
           super.viewWillDisappear(animated)
           self.navigationController?.isNavigationBarHidden = false
       }
    
    
    func show(viewController : UIViewController) {
        self.parentView = viewController
        self.view.frame = viewController.view.bounds
        self.view.alpha = 0
        
        viewController.addChild(self)
        viewController.view.addSubview(self.view)
        self.didMove(toParent: viewController)
        
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.view.alpha = 1
        }) {(complete) in
        }
    }
    
    func dissmiss() {
        self.willMove(toParent: self.parentView)
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
    

}
