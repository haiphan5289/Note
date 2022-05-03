
//
//  
//  HomeV2VC.swift
//  Note
//
//  Created by haiphan on 03/05/2022.
//
//
import UIKit
import RxCocoa
import RxSwift

class HomeV2VC: UIViewController {
    
    enum NoteStatus: Int, CaseIterable {
        case text, checkList, draw, photo, video
        
        var title: String {
            switch self {
            case .text: return "Add Note with Text"
            case .checkList: return "Add Note with List"
            case .draw: return "Add Note with Draw"
            case .photo: return "Add Note with Photo"
            case .video: return "Add Note with Video"
            }
        }
        
        var subTitle: String {
            switch self {
            case .text: return "remember what you're going to write"
            case .checkList: return "remember what you're going to write with list"
            case .draw: return "remember what you're going to Draw"
            case .photo: return "remember what you're going to Photo"
            case .video: return "remember what you're going to Video"
            }
        }
        
        var img: UIImage {
            switch self {
            case .text: return Asset.icTextDD.image
            case .checkList: return Asset.icTextDD.image
            case .draw: return Asset.icTextDD.image
            case .photo: return Asset.icTextDD.image
            case .video: return Asset.icTextDD.image
            }
        }
    }
    
    // Add here outlets
    @IBOutlet weak var tableView: UITableView!
    
    // Add here your view model
    private var viewModel: HomeV2VM = HomeV2VM()
    
    private let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupRX()
    }
    
}
extension HomeV2VC {
    
    private func setupUI() {
        // Add here the setup for the UI
        self.tableView.register(NoteStatusCell.nib, forCellReuseIdentifier: NoteStatusCell.identifier)
        self.tableView.register(ProjectCell.nib, forCellReuseIdentifier: ProjectCell.identifier)
        self.tableView.delegate = self
    }
    
    private func setupRX() {
        // Add here the setup for the RX
        Observable.just(NoteStatus.allCases)
            .bind(to: tableView.rx.items(cellIdentifier: NoteStatusCell.identifier, cellType: NoteStatusCell.self)) {(row, element, cell) in
                cell.loadValue(note: element)
            }.disposed(by: disposeBag)
    }
}
extension HomeV2VC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
}