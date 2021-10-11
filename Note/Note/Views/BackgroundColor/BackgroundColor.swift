//
//  BackgroundColor.swift
//  Note
//
//  Created by haiphan on 07/10/2021.
//

import UIKit
import RxSwift

protocol BackgroundColorDelegate {
    func dismissBgColor()
    func doneBgColor(bgColorType: BackgroundColor.BgColorTypes)
    func updateBgColor(bgColorType: BackgroundColor.BgColorTypes)
}

class BackgroundColor: UIView {
    
    enum BgColorTypes {
        case images(UIImage?)
        case colors(UIColor?)
        case gradient([UIColor])
        
        var text: String {
            switch self {
            case .images: return L10n.SegmentControl.images
            case .colors: return L10n.SegmentControl.colors
            case .gradient: return L10n.SegmentControl.gradients
            }
        }
    }
    
    struct Constant {
        static let numberOfCellinLine: CGFloat = 3
        static let spacingCell: CGFloat = 5
    }

    
    @IBOutlet weak var backgroundContentView: UIView!
    @IBOutlet weak var segmentContentView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var delegate: BackgroundColorDelegate?
    private let viewModel: BackgroundColorVM = BackgroundColorVM()
    private let segmentControl: SegmentControlCustom = SegmentControlCustom.loadXib()
    private let headerDialogView: ViewHeaderDialog = ViewHeaderDialog.loadXib()
    @VariableReplay private var typesColor: BgColorTypes = .images(nil)
    
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
        
        collectionView.delegate = self
        collectionView.register(BackgroundColorCell.nib, forCellWithReuseIdentifier: BackgroundColorCell.identifier)
    }
    
    private func setupRX() {
        self.viewModel.$listColors.asObservable()
            .bind(to: self.collectionView.rx.items(cellIdentifier: BackgroundColorCell.identifier, cellType: BackgroundColorCell.self)) { row, data, cell in
                guard let textColor = data.text, let img = data.img else { return }
                cell.img.isHidden = true
                cell.viewGradient.isHidden = true
                
                switch self.typesColor {
                case .colors:
                    cell.contentView.backgroundColor = UIColor(hexString: textColor)
                case .images:
                    cell.img.isHidden = false
                    cell.img.image = UIImage(named: img)
                    cell.contentView.backgroundColor = .clear
                case .gradient:
                    cell.viewGradient.isHidden = false
                    cell.viewGradient.layoutIfNeeded()
                    
                    if row == self.viewModel.listColors.count - 1, let t1 =  self.viewModel.listColors[row].text {
                        let color1 = UIColor(hexString: t1) ?? .red
                        cell.viewGradient.applyGradient(withColours: [color1, color1], gradientOrientation: .vertical)
                    } else if let t1 =  self.viewModel.listColors[row].text, let t2 = self.viewModel.listColors[row + 1].text {
                        let color1 = UIColor(hexString: t1) ?? .red
                        let color2 = UIColor(hexString: t2) ?? .blue
                        cell.viewGradient.applyGradient(withColours: [color1, color2], gradientOrientation: .vertical)
                    }
                }
            }.disposed(by: disposeBag)
        
        self.collectionView.rx.itemSelected.bind { [weak self] idx in
            guard let wSelf = self else { return }
            switch wSelf.typesColor {
            case .images:
                if let text = wSelf.viewModel.listColors[idx.row].img, let img = UIImage(named: text) {
                    wSelf.delegate?.updateBgColor(bgColorType: .images(img))
                    wSelf.typesColor = .images(img)
                }
                
            case .colors:
                let item = wSelf.viewModel.listColors[idx.row]
                if let textColor = item.text {
                    wSelf.delegate?.updateBgColor(bgColorType: .colors(UIColor(hexString: textColor)))
                    wSelf.typesColor = .colors(UIColor(hexString: textColor))
                }
                
            case .gradient:
                var color1: UIColor = .red
                var color2: UIColor = .black
                if idx.row == wSelf.viewModel.listColors.count - 1, let t1 =  wSelf.viewModel.listColors[idx.row].text {
                    color1 = UIColor(hexString: t1) ?? .red
                    color2 = UIColor(hexString: t1) ?? .red
                } else if let t1 =  wSelf.viewModel.listColors[idx.row].text, let t2 = wSelf.viewModel.listColors[idx.row + 1].text {
                    color1 = UIColor(hexString: t1) ?? .red
                    color2 = UIColor(hexString: t2) ?? .blue
                }
                wSelf.delegate?.updateBgColor(bgColorType: .gradient([color1, color2]))
                wSelf.typesColor = .gradient([color1, color2])
            }
        }.disposed(by: disposeBag)
        
        ViewHeaderDialog.ActionHeader.allCases.forEach { [weak self] type in
            guard let wSelf = self else { return }
            let bt = wSelf.headerDialogView.bts[type.rawValue]
            
            bt.rx.tap.bind { [weak self] _ in
                guard let wSelf = self else { return }
                
                switch type {
                case .cancel:
                    wSelf.hideView()
                    wSelf.delegate?.dismissBgColor()
                case .done:
                    wSelf.hideView()
                    wSelf.delegate?.doneBgColor(bgColorType: wSelf.typesColor)
                }
                
            }.disposed(by: disposeBag)
            
        }
    }
    
    private func calculateSizeCell() -> CGSize {
        let w = (self.collectionView.bounds.size.width / Constant.numberOfCellinLine) - Constant.spacingCell
        return CGSize(width: w, height: w)
    }
    
    private func addSegment() {
        self.segmentContentView.addSubview(self.segmentControl)
        self.segmentControl.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        self.segmentControl.delegate = self
        self.segmentControl.loadList(list: [BgColorTypes.images(nil), BgColorTypes.colors(nil), BgColorTypes.gradient([])])
    }
    
    private func addViewHeader() {
        self.headerDialogView.updateTitleHeader(text: L10n.StyleView.backgroundColor)
        self.backgroundContentView.addSubview(self.headerDialogView)
        self.headerDialogView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    func showView() {
        self.isHidden = false
    }
    
    func hideView() {
        self.isHidden = true
    }
    
    func addViewToParent(view: UIView) {
        view.addSubview(self)
        self.snp.makeConstraints { make in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(BaseNavigationHeader.Constant.heightViewListFont)
        }
    }
    
}
extension BackgroundColor: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.calculateSizeCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Constant.spacingCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
extension BackgroundColor: SegmentControlCustomDelegate {
    func selectIndex(selectType: BgColorTypes) {
        self.typesColor = selectType
        self.collectionView.reloadData()
    }
}
