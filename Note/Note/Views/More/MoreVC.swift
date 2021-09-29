//
//  MoreVC.swift
//  Audio
//
//  Created by paxcreation on 3/29/21.
//

import UIKit
import RxSwift
import RxCocoa

enum RouteHome {
    case library
    case imported
}

enum StyleMore: Int, CaseIterable {
    case rename
    case replication
    case delete
}

protocol MoreActionDelegate {
    func updateItem(url: URL)
    func renameItem(url: URL, oldUrl: URL, index: IndexPath)
}

class MoreVC: UIViewController {
    
    @IBOutlet var tapOutSide: UITapGestureRecognizer!
    @IBOutlet var bts: [UIButton]!
    
    var url: URL?
    var index: IndexPath?
    var delegate: MoreActionDelegate?
    var type: RouteHome = .library
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupRX()
    }
}
extension MoreVC {
    private func setupRX() {
        
        StyleMore.allCases.forEach { (type) in
            let bt = self.bts[type.rawValue]
            
            bt.rx.tap.bind(onNext: weakify({ (wSelf) in
                switch type {
                case .delete:
                    self.removeAudio()
                    
                case .rename:
                    let alert: UIAlertController = UIAlertController(title: "Change Name", message: nil, preferredStyle: .alert)
                    let btCancel: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    let btOK: UIAlertAction = UIAlertAction(title: "OK", style: .default) { _ in
                        let textField = alert.textFields![0]
                        self.changeName(name: textField.text ?? "")
                    }
                    alert.addTextField { (textField) -> Void in
                        textField.textColor = .black
                        textField.placeholder = "New name"
                        }
                    alert.addAction(btCancel)
                    alert.addAction(btOK)
                    self.present(alert, animated: true, completion: nil)
                    
                default:
                    break
                }
            })).disposed(by: disposeBag)
            
        }
        
        tapOutSide.rx.event.bind { _ in
            self.dismiss(animated: true, completion: nil)
        }.disposed(by: disposeBag)
    }
    
    func removeAudio() {
        guard  let url = self.url else { return }
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(at: url)
            self.delegate?.updateItem(url: url)
        } catch let err {
            print("\(err.localizedDescription)")
        }
    }
    
    func changeName(name: String) {
        guard  let url = self.url, let index = self.index else { return }
        do {
            let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            var newURL: URL!
            switch  self.type {
            case .library:
                newURL = documentURL.appendingPathComponent("\(LINK_FOLDER_LIBRARY)/\(name).m4a")
            default:
                newURL = documentURL.appendingPathComponent("\(LINK_FOLDER_IMPORTED)/\(name).m4a")
            }
            
            try FileManager.default.moveItem(at: url, to: newURL)
            self.delegate?.renameItem(url: newURL, oldUrl: url, index: index)
        } catch {
            print("========= \(error.localizedDescription)")
        }
    }
}
