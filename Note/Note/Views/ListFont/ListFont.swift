//
//  ListFont.swift
//  Note
//
//  Created by haiphan on 04/10/2021.
//

import UIKit
import RxCocoa
import RxSwift

class ListFont: UIView {
    
    struct Constant {
        static let characterMiddle: String = "-"
        static let firstName: String = "Normal"
    }
    
    enum FontType: Int, CaseIterable {
        case listFont
        case listSize
        
        func getListFont() -> [String] {
            return UIFont.familyNames
        }
        
        func getListSize(forFamilyName: String) -> [String] {
            return UIFont.fontNames(forFamilyName: forFamilyName)
        }
        
    }
    
    @IBOutlet weak var listFontTableView: UITableView!
    @IBOutlet weak var listSizeTableView: UITableView!
    
    private var listSize: BehaviorRelay<[String]> = BehaviorRelay.init(value: [])
    private var selectIndexFont: Int = 0
    private var selectIndexSize: Int = 0
    private var fontFamilyNames: String = SettingDefaultFont.DEFAULT_NAME_FONT
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
extension ListFont {
    
    private func setupUI() {
        
        self.layer.cornerRadius = 12
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        listFontTableView.delegate = self
        listSizeTableView.delegate = self
        listFontTableView.register(FontCell.nib, forCellReuseIdentifier: FontCell.identifier)
        listSizeTableView.register(FontSize.nib, forCellReuseIdentifier: FontSize.identifier)
        self.listSize.accept(FontType.listSize.getListSize(forFamilyName: self.fontFamilyNames))
        
    }
    
    private func setupRX() {
        Observable.just(FontType.listFont.getListFont())
            .bind(to: listFontTableView.rx.items(cellIdentifier: FontCell.identifier, cellType: FontCell.self)) {(row, element, cell) in
                cell.lbName.text = element
                
                if row == self.selectIndexFont {
                    cell.img.image = Asset.icCheckbox.image
                    cell.img.tintColor = Asset.colorApp.color
                    cell.lbName.textColor = Asset.colorApp.color
                } else {
                    cell.img.image = Asset.icUncheck.image
                    cell.img.tintColor = Asset.disableHome.color
                    cell.lbName.textColor = .white
                }
                
            }.disposed(by: disposeBag)
        
        self.listSize.asObservable()
            .bind(to: listSizeTableView.rx.items(cellIdentifier: FontSize.identifier, cellType: FontSize.self)) {(row, element, cell) in
                if row == 0 {
                    cell.lbName.text = Constant.firstName
                } else {
                    if let range = element.searchLocation(searchText: Constant.characterMiddle), let cutString = element.cutString(range: range) {
                        cell.lbName.text = cutString
                    }
                }
                
                if row == self.selectIndexSize {
                    cell.img.image = Asset.icCheckbox.image
                    cell.img.tintColor = Asset.colorApp.color
                    cell.lbName.textColor = Asset.colorApp.color
                } else {
                    cell.img.image = Asset.icUncheck.image
                    cell.img.tintColor = Asset.disableHome.color
                    cell.lbName.textColor = .white
                }
            }.disposed(by: disposeBag)
        
        self.listFontTableView.rx.itemSelected.bind { [weak self] idx in
            guard let wSelf = self else { return }
            wSelf.selectIndexFont = idx.row
            let name = FontType.listFont.getListFont()[idx.row]
            wSelf.updateListSize(name: name)
            wSelf.listFontTableView.reloadData()
        }.disposed(by: disposeBag)
        
        self.listSizeTableView.rx.itemSelected.bind { [weak self] idx in
            guard let wSelf = self else { return }
            wSelf.selectIndexSize = idx.row
            wSelf.listSizeTableView.reloadData()
        }.disposed(by: disposeBag)
        
    }
    
    private func updateListSize(name: String) {
        self.fontFamilyNames = name
        self.listSize.accept(FontType.listSize.getListSize(forFamilyName: self.fontFamilyNames))
    }
    
    func addViewToParent(view: UIView) {
        view.addSubview(self)
        self.snp.makeConstraints { make in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(BaseNavigationHeader.Constant.heightViewListFont)
        }
    }
}
extension ListFont: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    
}
