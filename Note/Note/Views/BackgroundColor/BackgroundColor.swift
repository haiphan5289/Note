//
//  BackgroundColor.swift
//  Note
//
//  Created by haiphan on 07/10/2021.
//

import UIKit
import RxSwift

class BackgroundColor: UIView {
    
    enum BgColorTypes: Int, CaseIterable {
        case images, colors, gradient
        
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
    
    private let viewModel: BackgroundColorVM = BackgroundColorVM()
    private let segmentControl: SegmentControlCustom = SegmentControlCustom.loadXib()
    private let headerDialogView: ViewHeaderDialog = ViewHeaderDialog.loadXib()
    @VariableReplay private var typesColor: BgColorTypes = .images
    
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
                
                switch self.typesColor {
                case .colors: cell.contentView.backgroundColor = UIColor(hexString: textColor)
                case .images:
                    cell.img.isHidden = false
                    cell.img.image = UIImage(named: img)
                    cell.contentView.backgroundColor = .clear
                case .gradient: cell.contentView.backgroundColor = .red
                }
                
            }.disposed(by: disposeBag)
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
        self.segmentControl.loadList(list: BgColorTypes.allCases)
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
