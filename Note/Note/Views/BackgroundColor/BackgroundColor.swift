//
//  BackgroundColor.swift
//  Note
//
//  Created by haiphan on 07/10/2021.
//

import UIKit
import RxSwift

class BackgroundColor: UIView {
    
    @IBOutlet weak var backgroundContentView: UIView!
    @IBOutlet weak var segmentContentView: UIView!
    private let segmentControl: SegmentControlCustom = SegmentControlCustom.loadXib()
    private let headerDialogView: ViewHeaderDialog = ViewHeaderDialog.loadXib()
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
extension BackgroundColor {
    
    private func setupUI() {
        self.layer.cornerRadius = ConstantCommon.shared.radiusViewDialog
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.addViewHeader()
        self.addSegment()
    }
    
    private func setupRX() {
        
    }
    
    private func addSegment() {
        self.segmentContentView.addSubview(self.segmentControl)
        self.segmentControl.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        self.segmentControl.loadList(list: ["1", "2", "43"])
    }
    
    private func addViewHeader() {
        self.headerDialogView.updateTitleHeader(text: L10n.StyleView.backgroundColor)
        self.backgroundContentView.addSubview(self.headerDialogView)
        self.headerDialogView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    func addViewToParent(view: UIView) {
        view.addSubview(self)
        self.snp.makeConstraints { make in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(BaseNavigationHeader.Constant.heightViewListFont)
        }
    }
    
}
