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
    
    enum SelectAllStatus {
        case selectAll, deSelectAll
    }
    
    enum Action: Int, CaseIterable {
        case selectAll, trash, moreAction, cancelEdit
        
        static var statusSelectAll: SelectAllStatus = .deSelectAll
    }
    
    @IBOutlet var bts: [UIButton]!
    
    var delegate: NavigationItemHomeDelegate?
    @VariableReplay var actionStatus: ActionStatus = .normal
    @VariableReplay var tapAction: Action = .moreAction
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
        self.bts[Action.selectAll.rawValue].adjustsImageWhenHighlighted = false
        self.bts[Action.selectAll.rawValue].adjustsImageWhenDisabled = false
        self.bts[Action.selectAll.rawValue].isHighlighted = false
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
                case .cancelEdit:
                    wSelf.actionStatus = .normal
                    Action.statusSelectAll = .deSelectAll
                case .selectAll:
                    
                    if Action.statusSelectAll == .selectAll {
                        wSelf.bts[Action.selectAll.rawValue].setTitle(L10n.NavigationHomeItem.selectAll, for: .normal)
                        Action.statusSelectAll = .deSelectAll
                    } else {
                        wSelf.bts[Action.selectAll.rawValue].setTitle(L10n.NavigationHomeItem.deselectAll, for: .normal)
                        Action.statusSelectAll = .selectAll
                    }
                    
                default: break
                }
                wSelf.tapAction = type
            }.disposed(by: disposeBag)
            
        }
        
        self.$actionStatus.asObservable().bind { [weak self] stt in
            guard let wSelf = self else { return }
            
            switch stt {
            case .normal:
                wSelf.bts[Action.selectAll.rawValue].isHidden = true
                wSelf.bts[Action.cancelEdit.rawValue].isHidden = true
                wSelf.bts[Action.trash.rawValue].isHidden = true
                wSelf.bts[Action.moreAction.rawValue].isHidden = false
            case .edit:
                wSelf.bts[Action.selectAll.rawValue].isHidden = false
                wSelf.bts[Action.cancelEdit.rawValue].isHidden = false
                wSelf.bts[Action.trash.rawValue].isHidden = false
                wSelf.bts[Action.moreAction.rawValue].isHidden = true
            }
            
        }.disposed(by: disposeBag)
        
    }
    
    func resetSelectAll() {
        self.bts[Action.selectAll.rawValue].setTitle(L10n.NavigationHomeItem.selectAll, for: .normal)
        Action.statusSelectAll = .deSelectAll
    }
    
}
