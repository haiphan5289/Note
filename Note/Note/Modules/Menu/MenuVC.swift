
//
//  
//  MenuVC.swift
//  Note
//
//  Created by haiphan on 29/09/2021.
//
//
import UIKit
import RxCocoa
import RxSwift

class MenuVC: UIViewController {
    
    enum MenuElement: Int, CaseIterable {
        case getPrenium, restore,  autoLock, shareApp, rateApp, feedBackApp, myApps, term, policy
        
        var text: String {
            switch self {
            case .getPrenium:
                return ""
            case .restore:
                return "Restore"
            case .autoLock:
                return "AutoLock"
            case .shareApp:
                return "Share App"
            case .rateApp:
                return "Rate App"
            case .feedBackApp:
                return "FeedBack App"
            case .myApps:
                return "My Apps"
            case .term:
                return "Term Of Use"
            case .policy:
                return "Privacy Policy"
            }
        }
    }
    
    enum AutoLockValue: Int, Codable, CaseIterable {
        case instantly, oneminute, fiveminute, onehour, fivehour, nerver
        
        var text: String {
            switch self {
            case .instantly:
                return "L10n.AutoLock.instantly"
            case .oneminute:
                return "L10n.AutoLock.oneMinute"
            case .fiveminute:
                return "L10n.AutoLock.fiveMinute"
            case .onehour:
                return "L10n.AutoLock.oneHour"
            case .fivehour:
                return "L10n.AutoLock.fiveHour"
            case .nerver:
                return "L10n.AutoLock.fiveHour"
            }
        }
        
        var valueSeconds: Int {
            switch self {
            case .instantly: return 0
            case .fiveminute: return 0
            case .oneminute: return 0
            case .onehour: return 0
            case .fivehour: return 0
            case .nerver: return 0
            }
        }
    }
    
    // Add here outlets
    @IBOutlet weak var tableView: UITableView!
    
    // Add here your view model
    private var viewModel: MenuVM = MenuVM()
    
    private let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupRX()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
}
extension MenuVC {
    
    private func setupUI() {
        // Add here the setup for the UI
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(MenuCell.nib, forCellReuseIdentifier: MenuCell.identifier)
        self.tableView.register(MenuPremiumCell.nib, forCellReuseIdentifier: MenuPremiumCell.identifier)
    }
    
    private func setupRX() {
        // Add here the setup for the RX
    }
    
    private func actionSheetAutoLock() {
        self.showAlert(type: .actionSheet,
                       title: "L10n.AutoLock.set",
                       message: nil,
                       buttonTitles: AutoLockValue.allCases.map{ $0.text },
                       highlightedButtonIndex: nil) { [weak self] idx in
            guard let wSelf = self, let value = AutoLockValue(rawValue: idx) else { return }
//            let lock = AppLockModel(isUsingFaceID: app.isUsingFaceID,
//                                    autoLockValue: value,
//                                    passCode: app.passCode,
//                                    isEnable: app.isEnable)
//            BackgroundLock.shared.updateValueAppLock(app: lock)
        }
    }
}
extension MenuVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MenuElement.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch MenuElement.init(rawValue: indexPath.row) {
        case .getPrenium:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: MenuPremiumCell.identifier) as! MenuPremiumCell? else {
                return UITableViewCell.init()
            }
            return cell
        default:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: MenuCell.identifier) as? MenuCell else { return UITableViewCell.init() }
            cell.lbName.text = MenuElement.allCases[indexPath.row].text
            if MenuElement.allCases[indexPath.row] == .autoLock {
                cell.lbDes.isHidden = false
            } else {
                cell.lbDes.isHidden = true
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch MenuElement.init(rawValue: indexPath.row) {
        case .autoLock:
            self.actionSheetAutoLock()
        default: break
        }
    }
    
}
extension MenuVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
}
