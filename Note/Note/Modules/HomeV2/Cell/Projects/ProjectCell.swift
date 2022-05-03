//
//  ProjectCell.swift
//  Note
//
//  Created by haiphan on 03/05/2022.
//

import UIKit
import RxSwift

class ProjectCell: UITableViewCell {

    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbSubtitle: UILabel!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @VariableReplay private var listNote: [NoteModel] = []
    
    private let disposeBag = DisposeBag()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setupUI()
        self.setupRX()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
extension ProjectCell {
    
    private func setupUI() {
        self.collectionView.delegate = self
        self.collectionView.register(HomeTextCell.nib, forCellWithReuseIdentifier: HomeTextCell.identifier)
        self.collectionView.register(CheckListCell.nib, forCellWithReuseIdentifier: CheckListCell.identifier)
        self.collectionView.register(DrawHomeCell.nib, forCellWithReuseIdentifier: DrawHomeCell.identifier)
        self.collectionView.register(PhotoCell.nib, forCellWithReuseIdentifier: PhotoCell.identifier)
    }
    
    private func setupRX() {
        
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
//                cell.imgSelect.isHidden = (self.navigationItemView.actionStatus == .normal) ? true : false
//                let hasSelect = self.selectIndexs.contains(indexPath)
//                let img = (hasSelect) ? Asset.icCheckbox.image : Asset.icUncheck.image
//                cell.imgSelect.image = img
                cell.layoutIfNeeded()
                return cell
            case .text:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeTextCell.identifier, for: indexPath) as? HomeTextCell else {
                    fatalError("Don't have Cell")
                }
                cell.layoutIfNeeded()
                cell.updateValue(note: note)
                cell.imgSelect.isHidden = true
                cell.borderColor = Asset.colorApp.color
                cell.borderWidth = 1
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
                
//                cell.imgSelect.isHidden = (self.navigationItemView.actionStatus == .normal) ? true : false
//                let hasSelect = self.selectIndexs.contains(indexPath)
//                let img = (hasSelect) ? Asset.icCheckbox.image : Asset.icUncheck.image
//                cell.imgSelect.image = img
                
                cell.layoutIfNeeded()
                return cell
                
            case .photo:
                
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.identifier, for: indexPath) as? PhotoCell else {
                    fatalError("Don't have Cell")
                }
                
                
                cell.layoutIfNeeded()
                cell.updateValue(note: note)
//                cell.imgSelect.isHidden = (self.navigationItemView.actionStatus == .normal) ? true : false
//
//                let hasSelect = self.selectIndexs.contains(indexPath)
//                let img = (hasSelect) ? Asset.icCheckbox.image : Asset.icUncheck.image
//                cell.imgSelect.image = img
                cell.layoutIfNeeded()
                return cell
                
            default:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeTextCell.identifier, for: indexPath) as? HomeTextCell else {
                    fatalError("Don't have Cell")
                }
                return cell
            }
        }.disposed(by: self.disposeBag)
    }
    
    func loadValue(note: HomeV2VC.NoteStatus) {
        self.lbTitle.text = note.title
        self.lbSubtitle.text = note.subTitle
        self.img.image = note.img
    }
}
extension ProjectCell: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 64, height: 64)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
