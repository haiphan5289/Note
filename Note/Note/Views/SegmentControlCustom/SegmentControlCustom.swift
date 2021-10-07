//
//  SegmentControlCustom.swift
//  Note
//
//  Created by haiphan on 07/10/2021.
//

import UIKit
import RxSwift

class SegmentControlCustom: UIView {
    
    struct Constant {
        static let tagSegment: Int = 10
    }
    
    @IBOutlet weak var stackView: UIStackView!
    private let thumnailView: UIView = UIView(frame: .zero)
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
extension SegmentControlCustom {
    
    private func setupUI() {
        self.stackView.clipsToBounds = true
        self.stackView.layer.cornerRadius = ConstantCommon.shared.radiusSegment
    }
    
    private func setupRX() {
        
    }
    
    func loadList(list: [String]) {
        list.enumerated().forEach { [weak self] item in
            guard let wSelf = self else { return }
            wSelf.stackView.addArrangedSubview(wSelf.setupViewElement(index: item.offset, text: item.element))
        }
        
        self.layoutIfNeeded()
        self.stackView.subviews.forEach { v in
            if v.tag == Constant.tagSegment {
                self.setupViewThumnail(frame: v.frame)
            }
        }
    }
    
    private func setupViewElement(index: Int, text: String) -> UIView {
        let v: UIView = UIView()
        v.backgroundColor = .clear
        v.tag = index + Constant.tagSegment
        v.clipsToBounds = true
        v.layer.cornerRadius = ConstantCommon.shared.radiusSegment
        
        let lbName: UILabel = UILabel(frame: .zero)
        lbName.text = text
        lbName.font = UIFont.mySystemFont(ofSize: 16)
        
        if index == 0 {
            lbName.textColor = Asset.textColorApp.color
            self.setupViewThumnail(frame: v.frame)
        } else {
            lbName.textColor = Asset.colorApp.color
        }
        
        lbName.textAlignment = .center
        v.addSubview(lbName)
        lbName.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        let bt: UIButton = UIButton(frame: .zero)
        v.addSubview(bt)
        bt.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        bt.rx.tap.bind { [weak self] _ in
            guard let wSelf = self else { return }
            print("====")
        }.disposed(by: disposeBag)
        
        return v
    }
    
    private func setupViewThumnail(frame: CGRect) {
        self.thumnailView.frame = frame
        self.thumnailView.isUserInteractionEnabled = false
        self.thumnailView.backgroundColor = Asset.viewMoveSegment.color
        self.thumnailView.clipsToBounds = true
        self.thumnailView.cornerRadius = ConstantCommon.shared.radiusSegment
        self.stackView.insertSubview(self.thumnailView, at: 0)
    }
    
}
