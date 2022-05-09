
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
        case project, text, checkList, draw, photo, video
        
        var title: String {
            switch self {
            case .text: return "Add Note with Text"
            case .checkList: return "Add Note with List"
            case .draw: return "Add Note with Draw"
            case .photo: return "Add Note with Photo"
            case .video: return "Add Note with Video"
            case .project: return "Project"
            }
        }
        
        var subTitle: String {
            switch self {
            case .text: return "remember what you're going to write"
            case .checkList: return "remember what you're going to write with list"
            case .draw: return "remember what you're going to Draw"
            case .photo: return "remember what you're going to Photo"
            case .video: return "remember what you're going to Video"
            case .project: return "Projects Nearly"
            }
        }
        
        var img: UIImage {
            switch self {
            case .text: return Asset.icText64DD.image
            case .checkList: return Asset.icCheckList64.image
            case .draw: return Asset.icDraw64.image
            case .photo: return Asset.icPhoto64.image
            case .video: return Asset.icVideo64.image
            case .project: return Asset.icProjectsDD.image
            }
        }
    }
    
    // Add here outlets
    @IBOutlet weak var tableView: UITableView!
    
    // Add here your view model
    private var viewModel: HomeV2VM = HomeV2VM()
    private let eventPickerUrl: PublishSubject<UIImage> = PublishSubject.init()
    
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
        Observable.just(NoteStatus.allCases).bind(to: tableView.rx.items){(tbv, row, item) -> UITableViewCell in
            switch item {
            case .project:
                guard let cell = tbv.dequeueReusableCell(withIdentifier: ProjectCell.identifier) as? ProjectCell else {
                    fatalError()
                }
                cell.loadValue(note: item)
                return cell
            case .text, .checkList, .draw, .photo, .video:
                guard let cell = tbv.dequeueReusableCell(withIdentifier: NoteStatusCell.identifier) as? NoteStatusCell else {
                    fatalError()
                }
                cell.loadValue(note: item)
                return cell
            }
        }.disposed(by: disposeBag)
        
        self.tableView.rx.itemSelected.bind { [weak self] idx in
            guard let wSelf = self, let noteType = NoteStatus(rawValue: idx.row) else { return }
            switch noteType {
            case .text:
                let vc = TextVC.createVC()
                wSelf.navigationController?.pushViewController(vc, animated: true)
            case .checkList:
                let vc = CheckListVC.createVC()
                wSelf.navigationController?.pushViewController(vc, animated: true)
            case .draw:
                let vc = DrawVC.createVC()
                wSelf.navigationController?.pushViewController(vc, animated: true)
            case .video:
                let vc = QRCodeVC.createVC()
                wSelf.navigationController?.pushViewController(vc, animated: true)
            case .photo:
                wSelf.presentImagePicker()
            case .project:
                let project = HomeVC.createVC()
                wSelf.navigationController?.pushViewController(project, animated: true)
            }
        }.disposed(by: disposeBag)
        
        self.eventPickerUrl.asObservable().debounce(.milliseconds(200), scheduler: MainScheduler.asyncInstance)
            .bind { [weak self] url in
                guard let wSelf = self else { return }
                let vc = PhotoVC.createVC()
                vc.imagePhotoLibrary = url
                vc.hidePickCOlor()
                wSelf.navigationController?.pushViewController(vc, animated: true)
            }.disposed(by: disposeBag)
    }
    
    private func presentImagePicker() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.mediaTypes = UIImagePickerController.availableMediaTypes(for:.photoLibrary)!
        self.present(imagePickerController, animated: true, completion: nil)
    }
}
extension HomeV2VC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        defer {
//             picker.dismiss(animated: true)
//         }
         
         // get the image
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
             return
         }
        picker.dismiss(animated: true) {
            self.eventPickerUrl.onNext(image)
        }
    }
}

extension HomeV2VC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
