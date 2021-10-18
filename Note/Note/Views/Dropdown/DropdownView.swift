//
//  DropdownView.swift
//  Note
//
//  Created by haiphan on 01/10/2021.
//

import UIKit
import RxSwift

protocol DropDownDelegate {
    func actionCreate(type: DropdownView.TypeView)
}

class DropdownView: UIView {
    
    struct Constant {
        static let heightView: CGFloat = 50
        static let distanceView: CGFloat = 10
        static let borderWidth: CGFloat = 1
        static let cornerRadius: CGFloat = 8
        static let distanceArea: CGFloat = 16
        static let radius: CGFloat = 20
        static let distancetoBottomDropView: CGFloat = 20
    }
    
    enum TypeView: Int, CaseIterable {
        case text, checkList, draw, photo, video, qrCode
        
        var text: String {
            switch self {
            case .text: return L10n.Dropdown.text
            case .checkList: return L10n.Dropdown.checkList
            case .draw: return L10n.Dropdown.draw
            case .photo: return L10n.Dropdown.photos
            case .video: return L10n.Dropdown.videos
            case .qrCode: return "QR_Code"
            }
        }
        
        var img: UIImage {
            switch self {
            case .text: return Asset.icTextDD.image
            case .checkList: return Asset.icChecklistDD.image
            case .draw: return Asset.icDrawDD.image
            case .photo: return Asset.icPhotoDD.image
            case .video: return Asset.icVideoDD.image
            case .qrCode: return Asset.icVideoDD.image
            }
        }
    }
    
    var delegate: DropDownDelegate?
    
    private let scrollView: UIScrollView = UIScrollView()
    private let stackView: UIStackView = UIStackView()
    private var shapeLayer: CALayer?
    private var frameShow: CGRect = .zero
    private var frameHide: CGRect = .zero
    
    private let disposeBag = DisposeBag()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
        self.setupRX()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        self.addShape()
    }

}
extension DropdownView {
    
    private func setupUI() {
        scrollView.backgroundColor = .clear
        self.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(Constant.distanceArea)
        }
        
        self.setupViewStack()
        
        self.stackView.backgroundColor = .clear
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = Constant.distanceView
        scrollView.addSubview(self.stackView)
        self.stackView.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(self.scrollView)
            make.left.right.equalTo(self.scrollView)
            make.width.equalTo(self.scrollView)
            make.height.equalTo(self.getHeight())
            // or:
            // make.centerX.equalTo(self.scrollView)
            // make.centerY.equalTo(self.scrollView)
        }
        
    }
    
    private func setupRX() {
        
    }
    
    private func setupViewStack() {
        for type in TypeView.allCases {
            let v: UIView = UIView(frame: .zero)
            v.tag = type.rawValue
            v.backgroundColor = Asset.appBg.color
            v.clipsToBounds = true
            v.layer.borderColor = UIColor.black.cgColor
            v.layer.borderWidth = Constant.borderWidth
            v.layer.cornerRadius = Constant.cornerRadius
            
            let lbTitle: UILabel = UILabel(frame: .zero)
            lbTitle.font = UIFont.mySemiBoldSystemFont(ofSize: 16)
            lbTitle.textColor = Asset.textColorApp.color
            lbTitle.textAlignment = .center
            lbTitle.text = type.text
            v.addSubview(lbTitle)
            lbTitle.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
            
            let img: UIImageView = UIImageView(frame: .zero)
            img.tintColor = Asset.textColorApp.color
            img.image = type.img
            v.addSubview(img)
            img.snp.makeConstraints { make in
                make.centerY.equalTo(lbTitle)
                make.right.equalTo(lbTitle.snp.left).inset(-10)
            }
            
            let tap: UITapGestureRecognizer = UITapGestureRecognizer()
            v.addGestureRecognizer(tap)
            tap.rx.event.bind { [weak self] _ in
                guard let wSelf = self else { return }
                wSelf.delegate?.actionCreate(type: type)
            }.disposed(by: disposeBag)
            
            self.stackView.addArrangedSubview(v)
        }
    }
    
    func updateValueFrame(statusNote: AddNote.StatusAddNote, frame: CGRect) {
        switch statusNote {
        case .open:
            self.frameShow = frame
        case .remove:
            self.frameHide = frame
        }
    }
    
    func getFrawm(statusNote: AddNote.StatusAddNote) -> CGRect {
        switch statusNote {
        case .open:
            return self.frameShow
        case .remove:
            return self.frameHide
        }
    }
    
    private func getHeight() -> CGFloat {
        return CGFloat(TypeView.allCases.count) * Constant.heightView + (Constant.distanceView * CGFloat(TypeView.allCases.count - 1))
    }
    
    func getHeightDropdown() -> CGFloat {
        return self.getHeight() + (Constant.distanceArea * 2) + Constant.distancetoBottomDropView
    }
    
    private func addShape() {
        var shapeLayer = CAShapeLayer()
        shapeLayer.path = PathDraw.shared.createPathDropDown(frame: self.frame, distancefromDropDownViewToBottom: Constant.distancetoBottomDropView)
        shapeLayer = PathDraw.shared.setupShapeLayer(shapeLayer: shapeLayer, colorLine: .clear)

        if let oldShapeLayer = self.shapeLayer {
            self.layer.replaceSublayer(oldShapeLayer, with: shapeLayer)
        } else {
            self.layer.insertSublayer(shapeLayer, at: 0)
        }
        self.shapeLayer = shapeLayer
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard !clipsToBounds && !isHidden && alpha > 0 else { return nil }
        for member in subviews.reversed() {
            let subPoint = member.convert(point, from: self)
            guard let result = member.hitTest(subPoint, with: event) else { continue }
            return result
        }
        return nil
    }
    
}
