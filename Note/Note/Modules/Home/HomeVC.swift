
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

class HomeVC: UIViewController {
    
    struct Constant {
        static let distanceFromTopTabbar: CGFloat = 20
        static let heightAddNoteView: CGFloat = 50
        static let totalBesidesArea: CGFloat = 75
        static let contraintBottomDropDownView: CGFloat = 10
    }
    
    // Add here outlets
    // Add here your view model
    private var viewModel: HomeVM = HomeVM()
    private let vAddNote: AddNote = AddNote.loadXib()
    private let vDropDown: DropdownView = DropdownView(frame: .zero)
    
    private let eventStatusDropDown: PublishSubject<AddNote.StatusAddNote> = PublishSubject.init()
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
        self.eventStatusDropDown.asObservable().bind { [weak self] status in
            guard let wSelf = self else { return }
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
