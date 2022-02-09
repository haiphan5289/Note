//
//  DropdownActionView.swift
//  Note
//
//  Created by haiphan on 12/10/2021.
//

import UIKit
import RxSwift

protocol DropdownActionViewDelegate {
    func selectAction(action: DropdownActionView.Action)
    func selectNumberOfCell(viewStatus: DropdownActionView.ViewsStatus)
}

class DropdownActionView: UIView {
    
    struct Constant {
        static let width: CGFloat = 200
        static let height: CGFloat = 320
        static let distanceView: CGFloat = 10
        static let borderWidth: CGFloat = 1
        static let cornerRadius: CGFloat = 8
        static let distanceToTop: CGFloat = 15
        static let distanceViewOfView: CGFloat = 5
    }
    
    enum DropDownActionStatus {
        case show, hide
    }
    
    enum SortStatus {
        case orderedDescending, orderedAscending
    }
    
    enum Action: Int, Codable, CaseIterable {
        case trash, sort, reminder, pin, views, reset
        
        static var sortStatus: SortStatus = .orderedDescending
        
        var text: String {
            switch self {
            case .trash:
                return L10n.DropdownAction.trash
            case .pin:
                return L10n.DropdownAction.pin
            case .reminder:
                return L10n.DropdownAction.reminder
            case .sort:
                return L10n.DropdownAction.sort
            case .views:
                return L10n.DropdownAction.views
            case .reset:
                return L10n.DropdownAction.default
            }
        }
        
        var img: UIImage {
            switch self {
            case .trash:
                return Asset.icTrash.image
            case .pin:
                return Asset.icPin.image
            case .reminder:
                return Asset.icReminder.image
            case .sort:
                return Asset.icSortAscending.image
            case .views:
                return Asset.icFourView.image
            case .reset:
                return Asset.icDefaultHome.image
            }
        }
    }
    
    enum ViewsStatus: Int, Codable, CaseIterable {
        case two, three, four
        
        var img: UIImage {
            switch self {
            case .two:
                return Asset.icTwoView.image
            case .three:
                return Asset.icThreeView.image
            case .four:
                return Asset.icFourView.image
            }
        }
    }
    
    var delegate: DropdownActionViewDelegate?
    private let stackView: UIStackView = UIStackView()
    private var shapeLayer: CALayer?
    private var views: [UIView] = []
    
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
extension DropdownActionView {
    
    private func setupUI() {
        self.stackView.backgroundColor = .clear
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = Constant.distanceView
        self.setupStackView()
        
        self.addSubview(self.stackView)
        self.stackView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview().inset(16)
            make.top.equalToSuperview().inset(Constant.distanceToTop + 16)
        }
    }
    
    private func setupRX() {
        
    }
    
    private func setupStackView() {
        Action.allCases.forEach { [weak self] type in
            guard let wSelf = self else { return }
            
            if type == .views {
                wSelf.stackView.addArrangedSubview(wSelf.setupStackViews())
            } else {
                let v: UIView = UIView(frame: .zero)
                v.tag = type.rawValue
                v.backgroundColor = Asset.appBg.color
                v.clipsToBounds = true
                v.layer.borderColor = UIColor.black.cgColor
                v.layer.borderWidth = Constant.borderWidth
                v.layer.cornerRadius = Constant.cornerRadius
                if type == AppSettings.sortModel.type {
                    v.layer.borderColor = Asset.textColorApp.color.cgColor
                }
                
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
                wSelf.views.append(v)
                tap.rx.event.bind { [weak self] _ in
                    guard let wSelf = self else { return }
                    
                    switch type {
                    case .sort:
                        if Action.sortStatus == .orderedDescending {
                            Action.sortStatus = .orderedAscending
                            img.image = Asset.icSortDescending.image
                        } else {
                            Action.sortStatus = .orderedDescending
                            img.image = Asset.icSortAscending.image
                        }
                    default: break
                    }
                    
                    wSelf.views.forEach { v in
                        v.layer.borderColor = UIColor.clear.cgColor
                    }
                    v.layer.borderColor = Asset.textColorApp.color.cgColor
                    v.layer.borderWidth = 1
                    
                    wSelf.delegate?.selectAction(action: type)
                }.disposed(by: disposeBag)
                
                wSelf.stackView.addArrangedSubview(v)
            }
        }
    }
    
    func setupStackViews() -> UIStackView {
        let stackViewOfViews: UIStackView = UIStackView()
        stackViewOfViews.backgroundColor = .clear
        stackViewOfViews.axis = .horizontal
        stackViewOfViews.distribution = .fillEqually
        stackViewOfViews.spacing = Constant.distanceViewOfView
        
        ViewsStatus.allCases.forEach { [weak self] type in
            guard let wSelf = self else { return }
            let v: UIView = UIView(frame: .zero)
            v.tag = type.rawValue
            v.backgroundColor = Asset.appBg.color
            v.clipsToBounds = true
            v.layer.borderColor = UIColor.black.cgColor
            v.layer.borderWidth = Constant.borderWidth
            v.layer.cornerRadius = Constant.cornerRadius
            
            let img: UIImageView = UIImageView(frame: .zero)
            img.tintColor = Asset.textColorApp.color
            img.image = type.img
            v.addSubview(img)
            img.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
            
            let tap: UITapGestureRecognizer = UITapGestureRecognizer()
            v.addGestureRecognizer(tap)
            tap.rx.event.bind { [weak self] _ in
                guard let wSelf = self else { return }
                wSelf.delegate?.selectNumberOfCell(viewStatus: type)
            }.disposed(by: disposeBag)
            
            stackViewOfViews.addArrangedSubview(v)
        }
        return stackViewOfViews
    }
    
    func hideView() {
        self.isHidden = true
    }
    
    func showView() {
        self.isHidden = false
    }
    
    private func addShape() {
        var shapeLayer = CAShapeLayer()
        shapeLayer.path = PathDraw.shared.createPathDropDownAction(frame: self.frame, distanceToTop: Constant.distanceToTop)
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
