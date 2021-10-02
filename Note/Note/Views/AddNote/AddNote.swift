//
//  AddNote.swift
//  Note
//
//  Created by haiphan on 29/09/2021.
//

import UIKit
import RxSwift

protocol AddNoteDelegate {
    func actionAddNote(status: AddNote.StatusAddNote)
}

class AddNote: UIView {
    
    enum StatusAddNote {
        case open, remove
    }
    
    @IBOutlet weak var btAddNote: UIButton!
    
    var delegate: AddNoteDelegate?
    
    private let disposebag = DisposeBag()
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
extension AddNote {
    private func setupUI() {
        
    }
    
    private func setupRX() {
        self.btAddNote.rx.tap.bind { [weak self] _ in
            guard let wSelf = self else { return }
            var stt: StatusAddNote
            
            if wSelf.btAddNote.isSelected {
                wSelf.btAddNote.isSelected = false
                wSelf.btAddNote.setImage(Asset.icUpAddNote.image, for: .normal)
                stt = .remove
            } else {
                wSelf.btAddNote.isSelected = true
                wSelf.btAddNote.setImage(Asset.icDownAddNote.image, for: .normal)
                stt = .open
            }
            
            wSelf.delegate?.actionAddNote(status: stt)
        }.disposed(by: disposebag)
    }
    
    func hideButtonMix() {
    }
}
