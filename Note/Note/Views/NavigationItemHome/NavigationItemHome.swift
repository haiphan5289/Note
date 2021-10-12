//
//  NavigationItemHome.swift
//  Note
//
//  Created by haiphan on 12/10/2021.
//

import UIKit
import RxSwift

protocol NavigationItemHomeDelegate {
    func showListAction(frameParent: UIView)
}

class NavigationItemHome: UIView {
    
    enum ActionStatus {
        case normal, edit
    }
    
    enum Action: Int, CaseIterable {
        case selectAll, trash, moreAction, cancelEdit
    }
    
    @IBOutlet var bts: [UIButton]!
    
    var delegate: NavigationItemHomeDelegate?
    @VariableReplay var actionStatus: ActionStatus = .normal
    private let disposeBag = DisposeBag()
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupRX()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    override func removeFromSuperview() {
        superview?.removeFromSuperview()
    }
    
}
extension NavigationItemHome {
    
    private func setupUI() {
        
    }
    
    private func setupRX() {
        
        Action.allCases.forEach { [weak self] type in
            guard let wSelf = self else { return }
            let bt = wSelf.bts[type.rawValue]
            
            bt.rx.tap.bind { [weak self] _ in
                guard let wSelf = self else { return }
                switch type {
                case .moreAction:
                    wSelf.delegate?.showListAction(frameParent: wSelf.bts[Action.moreAction.rawValue])
                default: break
                }
            }.disposed(by: disposeBag)
            
        }
        
        self.$actionStatus.asObservable().bind { [weak self] stt in
            guard let wSelf = self else { return }
            
            switch stt {
            case .normal:
                wSelf.bts[Action.selectAll.rawValue].isHidden = true
                wSelf.bts[Action.cancelEdit.rawValue].isHidden = true
                wSelf.bts[Action.trash.rawValue].isHidden = true
            case .edit: break
            }
            
        }.disposed(by: disposeBag)
        
    }
    
}
