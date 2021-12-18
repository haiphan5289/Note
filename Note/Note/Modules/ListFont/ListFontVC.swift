
//
//  
//  ListFontVC.swift
//  Note
//
//  Created by haiphan on 06/10/2021.
//
//
import UIKit
import RxCocoa
import RxSwift

protocol ListFontVCDelegae {
    func selectFont(index: Int)
}

class ListFontVC: BaseNavigationSimple {
    
    // Add here outlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var selectFontIndex: Int = 0
    
    var delegate: ListFontVCDelegae?
    // Add here your view model
    private var viewModel: ListFontVM = ListFontVM()
    private var listFont: BehaviorRelay<[String]> = BehaviorRelay.init(value: [])
    
    private let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupRX()
    }
    
}
extension ListFontVC {
    
    private func setupUI() {
        // Add here the setup for the UI
        title = L10n.ListFontVC.title
        tableView.register(FontCell.nib, forCellReuseIdentifier: FontCell.identifier)
        tableView.delegate = self
        self.listFont.accept(ListFont.FontType.listFont.getListFont())
    }
    
    private func setupRX() {
        // Add here the setup for the RX
        self.listFont.asObservable()
            .bind(to: tableView.rx.items(cellIdentifier: FontCell.identifier, cellType: FontCell.self)) {(row, element, cell) in
                cell.lbName.text = element
                
                if row == self.selectFontIndex {
                    cell.img.image = Asset.icCheckbox.image
                    cell.img.tintColor = Asset.colorApp.color
                    cell.lbName.textColor = Asset.colorApp.color
                } else {
                    cell.img.image = Asset.icUncheck.image
                    cell.img.tintColor = Asset.disableHome.color
                    cell.lbName.textColor = .white
                }
            }.disposed(by: disposeBag)
        
        self.tableView.rx.itemSelected.bind { [weak self] idx in
            guard let wSelf = self else { return }
            wSelf.navigationController?.popViewController(animated: true, {
                wSelf.delegate?.selectFont(index: idx.row)
            })
        }.disposed(by: disposeBag)
        
        self.searchBar.rx.text.orEmpty.asObservable().bind { [weak self] text in
            guard let wSelf = self else { return }
            switch StatusList.getStatus(count: text.count) {
            case .zero:
                wSelf.listFont.accept(ListFont.FontType.listFont.getListFont())
            case .other:
                let list = ListFont.FontType.listFont.getListFont().filter { $0.uppercased().contains(text.uppercased()) }
                wSelf.listFont.accept(list)
            }
        }.disposed(by: disposeBag)
        
        self.listFont.asObservable().bind { [weak self] list in
            guard let wSelf = self, list.count > 0 else { return }
            if list.count - 1 == wSelf.selectFontIndex {
                wSelf.tableView.scrollToBottom(isAnimated: true)
            } else {
                wSelf.tableView.scrollToIndex(index: wSelf.selectFontIndex)
            }
        }.disposed(by: disposeBag)
    }
}
extension ListFontVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
//    func tableView(_ tableView: UITableView,
//                            contextMenuConfigurationForRowAt indexPath: IndexPath,
//                            point: CGPoint) -> UIContextMenuConfiguration? {
//        return UIContextMenuConfiguration(  identifier: nil,
//                                            previewProvider: nil,
//                                            actionProvider: { suggestedActions in
//            // Context menu with title.
//
//            // Use the IndexPathContextMenu protocol to produce the UIActions.
//            let shareAction = self.shareAction(indexPath)
//            let inspectAction = self.inspectAction(indexPath)
//            let duplicateAction = self.duplicateAction(indexPath)
//            let deleteAction = self.deleteAction(indexPath)
//
//            return UIMenu(title: "",
//                          children: [shareAction, inspectAction, duplicateAction, deleteAction])
//        })
//    }
}
extension ListFontVC: IndexPathContextMenu {
    func performShare(_ indexPath: IndexPath) {
        print("==== performShare")
    }
    
    func performInspect(_ indexPath: IndexPath) {
        print("==== performInspect")
    }
    func performDuplicate(_ indexPath: IndexPath) {
        print("==== performDuplicate")
    }
    func performDelete(_ indexPath: IndexPath) {
        print("==== performDelete")
    }
    
}
