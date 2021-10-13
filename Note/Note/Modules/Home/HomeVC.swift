
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
        
//        self.collectionView.rx.itemSelected.bind { [weak self] idx in
//            guard let wSelf = self else { return }
//            let item = NoteManage.shared.listNote[idx.row]
//            let vc = TextVC.createVC()
//            vc.noteModel = item
//            wSelf.eventStatusDropdown = .hide
//            wSelf.navigationController?.pushViewController(vc, animated: true)
//        }.disposed(by: disposeBag)
        
        
        self.eventStatusDropDown.asObservable().bind { [weak self] status in
            guard let wSelf = self else { return }
            wSelf.eventStatusDropdown = .hide
            switch status {
            case .open:
                if #available(iOS 13, *) {
                    wSelf.playAudio()
                }
                wSelf.vDropDown.isHidden = false
                var f = wSelf.vDropDown.frame
                UIView.animate(withDuration: ConstantCommon.shared.timeAnimation) {
                    f.origin.y -= wSelf.vDropDown.getHeightDropdown()
                    wSelf.vDropDown.frame = f
                } completion: { _ in
                    if #available(iOS 13, *) {
                        wSelf.audio.stop()
                    }
                }

            default:
                if #available(iOS 13, *) {
                    wSelf.playAudio()
                }
                var f = wSelf.vDropDown.frame
                UIView.animate(withDuration: ConstantCommon.shared.timeAnimation) {
                    f.origin.y += wSelf.vDropDown.getHeightDropdown()
                    wSelf.vDropDown.frame = f
                } completion: { _ in
                    wSelf.vDropDown.isHidden = true
                    if #available(iOS 13, *) {
                        wSelf.audio.stop()
                    }
                }

            }
        }.disposed(by: disposeBag)
        
        self.navigationItemView.$actionStatus.asObservable().bind { [weak self] stt in
            guard let wSelf = self else { return }
            wSelf.collectionView.reloadData()
        }.disposed(by: disposeBag)
        
        self.navigationItemView.$tapAction.asObservable().bind { [weak self] tap in
            guard let wSelf = self else { return }
            
            switch tap {
            case .selectAll:
                if NavigationItemHome.Action.statusSelectAll == .selectAll {
                    wSelf.collectionView.selectAll(animated: true)
                } else {
                    wSelf.collectionView.deselectAll(animated: true)
                }
                
                wSelf.selectRows()
            case .cancelEdit:
                wSelf.collectionView.deselectAll(animated: true)
                wSelf.selectRows()
            case .moreAction, .trash: break
            }
            
        }.disposed(by: disposeBag)
    }
    
    private func selectRows() {
        self.selectIndexs = self.collectionView.indexPathsForSelectedItems ?? []
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
        default: break
        }
    }
    
    
}
extension HomeVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.listNote.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeTextCell.identifier, for: indexPath) as? HomeTextCell else {
            fatalError("Don't have Cell")
        }
        
        let note = self.listNote[indexPath.row]
        
        switch note.noteType {
        case .text:
            cell.updateValue(note: note)
        default: break
        }
        
        cell.btSelect.isHidden = (self.navigationItemView.actionStatus == .normal) ? true : false
        
        let hasSelect = self.selectIndexs.contains(indexPath)
        let img = (hasSelect) ? Asset.icCheckbox.image : Asset.icUncheck.image
        cell.btSelect.setImage(img, for: .normal)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("===== didSelectItemAt \(indexPath.row)")
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        print("===== didDeselectItemAt \(indexPath.row)")
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
