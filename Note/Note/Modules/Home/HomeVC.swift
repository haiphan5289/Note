
//
//  
//  HomeVC.swift
//  Note
//
//  Created by haiphan on 29/09/2021.
//
//
import UIKit
import RxCocoa
import RxSwift
import Photos
import WeScan

class HomeVC: BaseNavigationHome {
    
    struct Constant {
        static let distanceFromTopTabbar: CGFloat = 20
        static let heightAddNoteView: CGFloat = 50
        static let totalBesidesArea: CGFloat = 75
        static let contraintBottomDropDownView: CGFloat = 10
        static let numberOfCellisTwo: CGFloat = 2
        static let numberOfCellisThree: CGFloat = 3
        static let numberOfCellisFour: CGFloat = 4
        static let spacingCell: CGFloat = 5
    }
    
    // Add here outlets
    @IBOutlet weak var collectionView: UICollectionView!
    // Add here your view model
    private var viewModel: HomeVM = HomeVM()
    private let vAddNote: AddNote = AddNote.loadXib()
    private let vDropDown: DropdownView = DropdownView(frame: .zero)
    
    @VariableReplay private var listNote: [NoteModel] = []
    private let eventStatusDropDown: PublishSubject<AddNote.StatusAddNote> = PublishSubject.init()
    private var selectIndexs: [IndexPath] = []
    private var audio: AVAudioPlayer = AVAudioPlayer()
    private let eventPickerUrl: PublishSubject<UIImage> = PublishSubject.init()
    private var sizeCell: CGSize = .zero
    
    private let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupRX()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //This is reasson why call this method at here
        //Because when load completely, Size view.frame wii get size of file Xib not real devices
        self.addDropdownView()
        
        //Update cell view after back to home
        self.collectionView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.vAddNote.updateStatus(status: .remove)
    }
    
    
}
extension HomeVC {
    
    private func setupUI() {
        vAddNote.delegate = self
        // Add here the setup for the UI
        if let height = self.tabBarController?.tabBar.frame.height {
            self.view.addSubview(vAddNote)
            self.vAddNote.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
                make.bottom.equalToSuperview().inset(height - Constant.distanceFromTopTabbar)
                make.height.equalTo(Constant.heightAddNoteView)
            }
        }
        
        self.collectionView.delegate = self
        self.collectionView.register(HomeTextCell.nib, forCellWithReuseIdentifier: HomeTextCell.identifier)
        self.collectionView.register(CheckListCell.nib, forCellWithReuseIdentifier: CheckListCell.identifier)
        self.collectionView.register(DrawHomeCell.nib, forCellWithReuseIdentifier: DrawHomeCell.identifier)
        self.collectionView.register(PhotoCell.nib, forCellWithReuseIdentifier: PhotoCell.identifier)
    
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            let scannerViewController = ImageScannerController()
//            scannerViewController.imageScannerDelegate = self
//            self.present(scannerViewController, animated: true)
//        }
    }
    
    private func addDropdownView() {
        if let height = self.tabBarController?.tabBar.frame.height {
            let f: CGRect = CGRect(x: (self.view.frame.width / 2) - ((self.view.frame.width - Constant.totalBesidesArea) / 2),
                                   y: self.view.frame.height - Constant.heightAddNoteView - height,
                                   width: self.view.frame.width - Constant.totalBesidesArea,
                                   height: vDropDown.getHeightDropdown())
            vDropDown.frame = f
            vDropDown.isHidden = true
            vDropDown.delegate = self
            var framwShow = self.vDropDown.frame
            framwShow.origin.y -= self.vDropDown.getHeightDropdown()
            vDropDown.updateValueFrame(statusNote: .open, frame: framwShow)
            let framwHide = self.vDropDown.frame
            vDropDown.updateValueFrame(statusNote: .remove, frame: framwHide)
            self.view.addSubview(vDropDown)
        }

    }
    
    private func setupRX() {
        // Add here the setup for the RX
        
        NoteManage.shared.$listNote.asObservable().bind { [weak self] list in
            guard let wSelf = self else { return }
            
            wSelf.listNote = list
            wSelf.collectionView.reloadData()
        }.disposed(by: disposeBag)
        
        self.$listNote.bind(to: collectionView.rx.items) {
          (collectionView: UICollectionView, index: Int, note: NoteModel) in
            let indexPath = IndexPath(item: index, section: 0)
            switch note.noteType {
            case .checkList:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CheckListCell.identifier, for: indexPath) as? CheckListCell else {
                    fatalError("Don't have Cell")
                }
                cell.layoutIfNeeded()
                cell.updateValue(note: note)
                cell.imgSelect.isHidden = (self.navigationItemView.actionStatus == .normal) ? true : false
                let hasSelect = self.selectIndexs.contains(indexPath)
                let img = (hasSelect) ? Asset.icCheckbox.image : Asset.icUncheck.image
                cell.imgSelect.image = img
                cell.layoutIfNeeded()
                return cell
            case .text:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeTextCell.identifier, for: indexPath) as? HomeTextCell else {
                    fatalError("Don't have Cell")
                }
                cell.layoutIfNeeded()
                cell.updateValue(note: note)
                cell.imgSelect.isHidden = (self.navigationItemView.actionStatus == .normal) ? true : false
                
                let hasSelect = self.selectIndexs.contains(indexPath)
                let img = (hasSelect) ? Asset.icCheckbox.image : Asset.icUncheck.image
                cell.imgSelect.image = img
                cell.layoutIfNeeded()
                return cell
                
            case .draw:
                
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DrawHomeCell.identifier, for: indexPath) as? DrawHomeCell else {
                    fatalError("Don't have Cell")
                }
                cell.layoutIfNeeded()
                if let model = note.noteDrawModel {
                    cell.updateValueNote(noteModel: model)
                } else {
                    cell.img.isHidden = true
                }
                
                cell.imgSelect.isHidden = (self.navigationItemView.actionStatus == .normal) ? true : false
                let hasSelect = self.selectIndexs.contains(indexPath)
                let img = (hasSelect) ? Asset.icCheckbox.image : Asset.icUncheck.image
                cell.imgSelect.image = img
                
                cell.layoutIfNeeded()
                return cell
                
            case .photo:
                
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.identifier, for: indexPath) as? PhotoCell else {
                    fatalError("Don't have Cell")
                }
                
                
                cell.layoutIfNeeded()
                cell.updateValue(note: note)
                cell.imgSelect.isHidden = (self.navigationItemView.actionStatus == .normal) ? true : false
                
                let hasSelect = self.selectIndexs.contains(indexPath)
                let img = (hasSelect) ? Asset.icCheckbox.image : Asset.icUncheck.image
                cell.imgSelect.image = img
                cell.layoutIfNeeded()
                return cell
                
            default:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeTextCell.identifier, for: indexPath) as? HomeTextCell else {
                    fatalError("Don't have Cell")
                }
                return cell
            }
            }.disposed(by: disposeBag)
        
        self.collectionView.rx.itemSelected.bind { [weak self] idx in
            guard let wSelf = self else { return }
            switch wSelf.navigationItemView.actionStatus {
            case .normal:
                wSelf.moveToNote(idx: idx)
            case .edit:
                wSelf.addOrRemoveNote(idx: idx)
            }
        }.disposed(by: disposeBag)
        
        self.eventStatusDropDown.asObservable().bind { [weak self] status in
            guard let wSelf = self else { return }
            
            switch status {
            case .open:
                wSelf.eventStatusDropdown = .hide
                wSelf.playAudio()
                wSelf.vDropDown.isHidden = false
                UIView.animate(withDuration: ConstantApp.shared.timeAnimation) {
                    wSelf.vDropDown.frame = wSelf.vDropDown.getFrawm(statusNote: .open)
                } completion: { _ in
                    wSelf.audio.stop()
                }

            default:
                wSelf.playAudio()
                UIView.animate(withDuration: ConstantApp.shared.timeAnimation) {
                    wSelf.vDropDown.frame = wSelf.vDropDown.getFrawm(statusNote: .remove)
                } completion: { _ in
                    wSelf.vDropDown.isHidden = true
                    wSelf.audio.stop()
                }

            }
        }.disposed(by: disposeBag)
        
        self.navigationItemView.$actionStatus.asObservable().bind { [weak self] stt in
            guard let wSelf = self else { return }
            wSelf.collectionView.reloadData()
        }.disposed(by: disposeBag)
        
        self.eventActionDropdown.asObservable().bind { [weak self] tap in
            guard let wSelf = self else { return }
            
            switch tap {
            case .sort:
                if DropdownActionView.Action.sortStatus == .orderedDescending {
                    wSelf.listNote = wSelf.listNote.sorted(by: { $0.updateDate?.compare($1.updateDate ?? Date.convertDateToLocalTime()) == ComparisonResult.orderedDescending } )
                } else {
                    wSelf.listNote = wSelf.listNote.sorted(by: { $0.updateDate?.compare($1.updateDate ?? Date.convertDateToLocalTime()) == ComparisonResult.orderedAscending } )
                }
                wSelf.resetStatus()
                wSelf.navigationItemView.enableButtonMoreAction()
                wSelf.collectionView.reloadData()
            case .reset:
                wSelf.listNote = wSelf.listNote.sorted(by: { $0.updateDate?.compare($1.updateDate ?? Date.convertDateToLocalTime()) == ComparisonResult.orderedDescending } )
                wSelf.resetStatus()
                wSelf.eventNumberOfCell.onNext(.three)
                wSelf.navigationItemView.enableButtonMoreAction()
            default: break
            }
            
        }.disposed(by: disposeBag)
        
        self.navigationItemView.$tapAction.asObservable().bind { [weak self] tap in
            guard let wSelf = self else { return }
            
            switch tap {
            case .selectAll:
                if NavigationItemHome.Action.statusSelectAll == .selectAll {
                    wSelf.collectionView.selectAll(animated: true)
                    wSelf.selectIndexs = wSelf.collectionView.getIndexPaths()
                } else {
                    wSelf.collectionView.deselectAll(animated: true)
                    wSelf.selectIndexs = []
                }
                
                wSelf.collectionView.reloadData()
            case .trash:
                if wSelf.selectIndexs.count == wSelf.listNote.count {
                    NoteManage.shared.removeAllNote()
                } else {
                    wSelf.selectIndexs.forEach({ idx in
                        let note = wSelf.listNote[idx.row]
                        NoteManage.shared.deleteNote(note: note)
                    })
                }
                wSelf.selectIndexs = []
                wSelf.navigationItemView.resetSelectAll()
            case .cancelEdit:
                wSelf.collectionView.deselectAll(animated: true)
                wSelf.selectIndexs = []
                wSelf.navigationItemView.resetSelectAll()
                wSelf.collectionView.reloadData()
            case .moreAction:
                wSelf.vAddNote.updateStatus(status: .remove)
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
        
        self.navigationItemView.$actionStatus.asObservable().bind { [weak self] stt in
            guard let wSelf = self else { return }
            switch stt {
            case .normal:
                wSelf.resetStatus()
            case .edit: break
            }
        }.disposed(by: disposeBag)
        
        Observable.merge(Observable.just(AppSettings.numberOfCellHome), self.eventNumberOfCell.asObservable())
            .bind { [weak self] status in
            guard let wSelf = self else { return }
            wSelf.calculateSizeCell(numberOfCell: status)
        }.disposed(by: disposeBag)

    }
    
    private func addOrRemoveNote(idx: IndexPath) {
        if let index = self.selectIndexs.firstIndex(where: { $0 == idx }) {
            self.selectIndexs.remove(at: index)
            
            if self.selectIndexs.count <= 0 {
                self.navigationItemView.resetSelectAll()
            }
            
        } else {
            self.selectIndexs.append(idx)
        }
        self.collectionView.reloadData()
    }
    
    private func moveToNote(idx: IndexPath) {
        let item = NoteManage.shared.listNote[idx.row]
        
        switch item.noteType {
        case .text:
            let vc = TextVC.createVC()
            vc.noteModel = item
            self.eventStatusDropdown = .hide
            self.navigationController?.pushViewController(vc, animated: true)
        case .checkList:
            let vc = CheckListVC.createVC()
            vc.noteModel = item
            self.eventStatusDropdown = .hide
            self.navigationController?.pushViewController(vc, animated: true)
        case .draw:
            let vc = DrawVC.createVC()
            vc.noteModel = item
            self.eventStatusDropdown = .hide
            self.navigationController?.pushViewController(vc, animated: true)
        default: break
        }
    }
    
    private func presentImagePicker() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.mediaTypes = UIImagePickerController.availableMediaTypes(for:.photoLibrary)!
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    private func resetStatus() {
        self.collectionView.deselectAll(animated: true)
        self.selectIndexs = []
        self.navigationItemView.resetSelectAll()
        self.collectionView.reloadData()
    }
    
    
    private func calculateSizeCell(numberOfCell: DropdownActionView.ViewsStatus) {
        
        switch numberOfCell {
        case .three:
            let w = (self.collectionView.bounds.size.width / Constant.numberOfCellisThree) - Constant.spacingCell
            self.sizeCell = CGSize(width: w, height: w)
        case .two:
            let w = (self.collectionView.bounds.size.width / Constant.numberOfCellisTwo) - Constant.spacingCell
            self.sizeCell = CGSize(width: w, height: w)
        case .four:
            let w = (self.collectionView.bounds.size.width / Constant.numberOfCellisFour) - Constant.spacingCell
            self.sizeCell = CGSize(width: w, height: w)
        }
        
        AppSettings.numberOfCellHome = numberOfCell
        self.collectionView.reloadData()
    }
    
    private func playAudio() {
        do {
            guard let url = Bundle.main.url(forResource: "SoundNote", withExtension: ".mp3") else {
                return
            }
            self.audio = try AVAudioPlayer(contentsOf: url)
            self.audio.prepareToPlay()
            self.audio.volume = 2.0
            self.audio.currentTime = 5
            self.audio.play()
        } catch {
            print(" Erro play Audio \(error.localizedDescription) ")
        }
    }
}
extension HomeVC: AddNoteDelegate {
    func actionAddNote(status: AddNote.StatusAddNote) {
        self.eventStatusDropDown.onNext(status)
    }
}
extension HomeVC: DropDownDelegate {
    func actionCreate(type: DropdownView.TypeView) {
        switch type {
        case .text:
            let vc = TextVC.createVC()
            self.navigationController?.pushViewController(vc, animated: true)
        case .checkList:
            let vc = CheckListVC.createVC()
            self.navigationController?.pushViewController(vc, animated: true)
        case .draw:
            let vc = DrawVC.createVC()
            self.navigationController?.pushViewController(vc, animated: true)
        case .qrCode:
            let vc = QRCodeVC.createVC()
            self.navigationController?.pushViewController(vc, animated: true)
        case .photo:
            self.presentImagePicker()
        }
    }
    
    
}
extension HomeVC: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.sizeCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Constant.spacingCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
extension HomeVC: ImageScannerControllerDelegate {
    func imageScannerController(_ scanner: ImageScannerController, didFinishScanningWithResults results: ImageScannerResults) {

    }

    func imageScannerControllerDidCancel(_ scanner: ImageScannerController) {

    }

    func imageScannerController(_ scanner: ImageScannerController, didFailWithError error: Error) {

    }

}
extension HomeVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
