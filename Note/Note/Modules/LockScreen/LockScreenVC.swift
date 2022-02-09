
//
//  
//  LockScreenVC.swift
//  Note
//
//  Created by haiphan on 09/02/2022.
//
//
import UIKit
import RxCocoa
import RxSwift
import LocalAuthentication

class LockScreenVC: UIViewController {
    
    // Add here outlets
    
    // Add here your view model
    private var viewModel: LockScreenVM = LockScreenVM()
    private var context = LAContext()
    
    private let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupRX()
    }
    
}
extension LockScreenVC {
    
    private func setupUI() {
        // Add here the setup for the UI
        context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)

        // First check if we have the needed hardware support.
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {

            let reason = "Log in to your account"
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason ) { success, error in

                if success {

                    // Move to the main thread because a state update triggers UI changes.
                    DispatchQueue.main.async { [weak self] in
                        guard let wSelf = self else { return }
                        wSelf.dismiss(animated: true, completion: nil)
                    }

                } else {
                    print(error?.localizedDescription ?? "Failed to authenticate")

                    // Fall back to a asking for username and password.
                    // ...
                }
            }
        } else {
            print(error?.localizedDescription ?? "Can't evaluate policy")

            // Fall back to a asking for username and password.
            // ...
        }
    }
    
    private func setupRX() {
        // Add here the setup for the RX
    }
}
