//
//  BaseNavigationSimpleVC.swift
//  Note
//
//  Created by haiphan on 06/10/2021.
//

import Foundation
import UIKit
import RxSwift

class BaseNavigationSimple: UIViewController {
    
    private let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
            // MARK: Navigation Bar Customisation
//        self.navigationItem.setHidesBackButton(true, animated: true)
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: Asset.colorApp.color,
                                                                        NSAttributedString.Key.font: UIFont.myMediumSystemFont(ofSize: 18)]
        self.navigationController?.navigationBar.barTintColor = Asset.navigationBar.color
        self.navigationController?.isNavigationBarHidden = false
        
        let buttonLeft = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 44, height: 44)))
        buttonLeft.setImage(Asset.icClose.image, for: .normal)
        buttonLeft.tintColor = Asset.colorApp.color
        buttonLeft.contentEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
        let leftBarButton = UIBarButtonItem(customView: buttonLeft)
        navigationItem.leftBarButtonItem = leftBarButton
        buttonLeft.rx.tap.bind { [weak self] _ in
            guard let wSelf = self else { return }
            wSelf.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
        
    }
}
