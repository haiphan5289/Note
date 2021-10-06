//
//  ListFont.swift
//  Note
//
//  Created by haiphan on 04/10/2021.
//

import UIKit
import RxCocoa
import RxSwift

protocol ListFontDelegate {
    func dismissListFont()
    func done()
    func search()
}

enum StatusList {
    case zero, other
    
    static func getStatus(count: Int) -> Self {
        if count == 0 {
            return zero
        }
        
        return other
    }
}

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
    
    enum Action: Int, CaseIterable {
        case close, done, search, minus, plus
    }
    
    var delegate: ListFontDelegate?
    
    @IBOutlet weak var listFontTableView: UITableView!
    @IBOutlet weak var listSizeTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet var bts: [UIButton]!
    
    private var listSize: BehaviorRelay<[String]> = BehaviorRelay.init(value: [])
    private var listFont: BehaviorRelay<[String]> = BehaviorRelay.init(value: [])
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
        self.listFont.accept(FontType.listFont.getListFont())
        
    }
    
    private func setupRX() {
        self.listFont.asObservable()
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
            if wSelf.selectIndexFont != idx.row {
                wSelf.selectIndexFont = idx.row
                wSelf.selectIndexSize = 0
                let name = FontType.listFont.getListFont()[idx.row]
                wSelf.updateListSize(name: name)
                wSelf.listFontTableView.reloadData()
            }
        }.disposed(by: disposeBag)
        
        self.listSizeTableView.rx.itemSelected.bind { [weak self] idx in
            guard let wSelf = self else { return }
            wSelf.selectIndexSize = idx.row
            wSelf.listSizeTableView.reloadData()
        }.disposed(by: disposeBag)
        
        self.searchBar.rx.text.orEmpty.asObservable().bind { [weak self] text in
            guard let wSelf = self else { return }
            switch StatusList.getStatus(count: text.count) {
            case .zero:
                wSelf.listFont.accept(FontType.listFont.getListFont())
            case .other:
                let list = FontType.listFont.getListFont().filter { $0.uppercased().contains(text.uppercased()) }
                wSelf.listFont.accept(list)
            }
        }.disposed(by: disposeBag)
        
        Action.allCases.forEach { [weak self] type in
            guard let wSelf = self else { return }
            let bt = wSelf.bts[type.rawValue]
            
            bt.rx.tap.bind { [weak self] _ in
                guard let wSelf = self else { return }
                switch type {
                case .close: wSelf.delegate?.dismissListFont()
                case .done: wSelf.delegate?.done()
                case .search: wSelf.delegate?.search()
                case .minus, .plus: break
                }
            }.disposed(by: disposeBag)
        }
        
    }
    
    func scrollToIndex(index: Int) {
        self.selectIndexFont = index
        self.listFontTableView.scrollToIndex(index: index)
        self.listFontTableView.reloadData()
        
        let name = FontType.listFont.getListFont()[index]
        self.updateListSize(name: name)
    }
    
    func getSelectIndexFont() -> Int {
        return self.selectIndexFont
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
    
    func hide() {
        self.isHidden = true
    }
}
extension ListFont: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    
}
