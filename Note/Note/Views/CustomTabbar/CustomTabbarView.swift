//
//  CustomTabbarView.swift
//  CameraMakeUp
//
//  Created by haiphan on 27/09/2021.
//

import Foundation
import UIKit
import RxSwift

class CustomTabbarView: UIView {
    var itemTapped: ((_ tab: Int) -> Void)?
    var activeItem: Int = 0
    
    private let img: UIImageView = UIImageView()
    private let title: UILabel = UILabel()
    private let tap: UITapGestureRecognizer = UITapGestureRecognizer()

    private let disposeBag = DisposeBag()
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    convenience init(menuItem: CustomTabbar.TabItem, frame: CGRect) {
        self.init(frame: frame)
        self.setupUI(menuItem: menuItem)
        self.setupRX()
    }
    
    private func setupRX() {
        
    }
    
    private func setupUI(menuItem: CustomTabbar.TabItem) {
        self.img.image = menuItem.img
        self.img.tintColor = Asset.colorApp.color
        self.addSubview(self.img)
        self.img.snp.makeConstraints { (make) in
            make.top.equalToSuperview().inset(3)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(24)
        }
        self.title.text = menuItem.text
        self.title.font = UIFont.mySystemFont(ofSize: 12)
        self.title.textColor = .black
        self.title.textAlignment = .center
        self.addSubview(self.title)
        self.title.snp.makeConstraints { (make) in
            make.top.equalTo(self.img.snp.bottom).inset(-5)
            make.centerX.equalTo(self.img)
        }
        
        if menuItem == CustomTabbar.TabItem.home {
            self.activateTab()
        } else {
            self.deactivateTab()
        }
        
        self.addGestureRecognizer(self.tap)
        self.tap.rx.event.asObservable().bind { [weak self] tap in
            guard let wSelf = self else { return }
            wSelf.itemTapped?(menuItem.rawValue)
        }.disposed(by: disposeBag)
        
    }
    
    @objc func handleTap(_ sender: UIGestureRecognizer) {
        // ...
    }

    func switchTab(from: Int, to: Int) {
        // ...
    }

    func activateTab() {
        self.img.tintColor = Asset.colorApp.color
        self.title.textColor = Asset.colorApp.color
    }

    func deactivateTab() {
        self.img.tintColor = Asset.disableHome.color
        self.title.textColor = Asset.disableHome.color
    }
}
