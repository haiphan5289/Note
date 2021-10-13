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
    let dropdownActionView: DropdownActionView = DropdownActionView()
    var vContainer: UIView!
    
    @VariableReplay var eventStatusDropdown: DropdownActionView.DropDownActionStatus = .hide
    @VariableReplay var statusNavigation: NavigationItemHome.ActionStatus = .normal
    let eventActionDropdown: PublishSubject<DropdownActionView.Action> = PublishSubject.init()
    
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
        
        self.dropdownActionView.delegate = self
    }
    
    private func configRX() {
        
        self.eventActionDropdown.asObservable().bind { [weak self] action in
            guard let wSelf = self else { return }
            
            switch action {
            case .trash:
                wSelf.navigationItemView.actionStatus = .edit
            default: break
            }
            
        }.disposed(by: disposeBag)
        
        self.$eventStatusDropdown.asObservable().bind { [weak self] stt in
            guard let wSelf = self else { return }
            
            switch stt {
            case .hide:
                wSelf.dropdownActionView.hideView()
            case .show:
                wSelf.dropdownActionView.showView()
            }
            
        }.disposed(by: disposeBag)
        
    }
    
    private func setupDropdownActionView() {
        
    }
    
}
extension BaseNavigationHome: NavigationItemHomeDelegate {
    func showListAction(frameParent: UIView) {
        let origionX = frameParent.x + (frameParent.width / 2) - DropdownActionView.Constant.width
        self.view.addSubview(dropdownActionView)
        dropdownActionView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(origionX)
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.width.equalTo(DropdownActionView.Constant.width)
            make.height.equalTo(DropdownActionView.Constant.height)
        }
        self.eventStatusDropdown = .show
    }
    
    
}
extension BaseNavigationHome: DropdownActionViewDelegate {
    func selectAction(action: DropdownActionView.Action) {
        self.eventActionDropdown.onNext(action)
        self.eventStatusDropdown = .hide
    }
}
