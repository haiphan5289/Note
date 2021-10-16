
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

class HomeVC: BaseNavigationHome {
    
    struct Constant {
        static let distanceFromTopTabbar: CGFloat = 20
        static let heightAddNoteView: CGFloat = 50
        static let totalBesidesArea: CGFloat = 75
        static let contraintBottomDropDownView: CGFloat = 10
        static let numberOfCellinLine: CGFloat = 3
        static let spacingCell: CGFloat = 5
    }
    
    // Add here outlets
    @IBOutlet weak var collectionView: UICollectionView!
    // Add here your view model
    private var viewModel: HomeVM = HomeVM()
    private let vAddNote: AddNote = AddNote.loadXib()
    private let vDropDown: DropdownView = DropdownView(frame: .zero)
    
    private var listNote: [NoteModel] = []
    private let eventStatusDropDown: PublishSubject<AddNote.StatusAddNote> = PublishSubject.init()
    private var selectIndexs: [IndexPath] = []
    private var audio: AVAudioPlayer = AVAudioPlayer()
    
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
        self.collectionView.dataSource = self
        self.collectionView.register(HomeTextCell.nib, forCellWithReuseIdentifier: HomeTextCell.identifier)
        self.collectionView.register(CheckListCell.nib, forCellWithReuseIdentifier: CheckListCell.identifier)
        self.collectionView.register(DrawHomeCell.nib, forCellWithReuseIdentifier: DrawHomeCell.identifier)
        
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
                wSelf.collectionView.reloadData()
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
        
        self.navigationItemView.$actionStatus.asObservable().bind { [weak self] stt in
            guard let wSelf = self else { return }
            switch stt {
            case .normal:
                wSelf.resetStatus()
            case .edit: break
            }
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
    
    private func resetStatus() {
        self.collectionView.deselectAll(animated: true)
        self.selectIndexs = []
        self.navigationItemView.resetSelectAll()
        self.collectionView.reloadData()
    }
    
    
    private func calculateSizeCell() -> CGSize {
        let w = (self.collectionView.bounds.size.width / Constant.numberOfCellinLine) - Constant.spacingCell
        return CGSize(width: w, height: w)
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
        default: break
        }
    }
    
    
}
extension HomeVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.listNote.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let note = self.listNote[indexPath.row]
    
        switch note.noteType {
        case .checkList:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CheckListCell.identifier, for: indexPath) as? CheckListCell else {
                fatalError("Don't have Cell")
            }
            
            cell.updateValue(note: note)
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
            
            if let model = note.noteDrawModel {
                cell.updateValueNote(noteModel: model)
            } else {
                cell.img.isHidden = true
            }
            
            cell.layoutIfNeeded()
            return cell
            
        default:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeTextCell.identifier, for: indexPath) as? HomeTextCell else {
                fatalError("Don't have Cell")
            }
            return cell
        }
        

    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch self.statusNavigation {
        case .normal:
            self.moveToNote(idx: indexPath)
        case .edit:
            self.addOrRemoveNote(idx: indexPath)
        }
    }
    
    
}
extension HomeVC: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
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
