//
//  BaseNavigationHome.swift
//  Note
//
//  Created by haiphan on 12/10/2021.
//

import Foundation
import UIKit
import RxSwift

class BaseNavigationHome: UIViewController {
    let navigationItemView: NavigationItemHome = NavigationItemHome.loadXib()
    
    var vContainer: UIView!
    
    private let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
        self.configRX()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
            // MARK: Navigation Bar Customisation
        
        //to show Navigation Ite, this only is the case BaseTabbar
        DispatchQueue.main.async {
            self.navigationController?.isNavigationBarHidden = false
        }
        self.navigationItem.setHidesBackButton(true, animated: true)
        
        self.navigationController?.navigationBar.barTintColor = .clear
        self.navigationController?.isNavigationBarHidden = false
        
        vContainer = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.navigationController?.navigationBar.frame.height ?? 50))
           
        vContainer.backgroundColor = UIColor.clear
        vContainer.clipsToBounds = true
        vContainer.addSubview(self.navigationItemView)
        self.navigationItemView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        navigationController?.navigationBar.addSubview(vContainer)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        vContainer.removeFromSuperview()
    }
    
}
extension BaseNavigationHome {
    
    private func configUI() {
        self.navigationItemView.delegate = self
    }
    
    private func configRX() {
        
    }
    
}
extension BaseNavigationHome: NavigationItemHomeDelegate {
    func showListAction(frameParent: UIView) {
        print("===== frameParent \(frameParent.frame)")
        let origionX = frameParent.x + (frameParent.width / 2) - 100
        
        let v: DropdownActionView = DropdownActionView()
        self.view.addSubview(v)
        v.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(origionX)
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.width.height.equalTo(100)
        }
    }
    
    
}
