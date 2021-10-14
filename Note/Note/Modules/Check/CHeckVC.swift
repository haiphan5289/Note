
//
//  
//  CHeckVC.swift
//  Note
//
//  Created by haiphan on 14/10/2021.
//
//
import UIKit
import RxCocoa
import RxSwift
import WebKit

class CHeckVC: UIViewController {
    
    // Add here outlets
    @IBOutlet weak var webView: WKWebView!
    
    // Add here your view model
    private var viewModel: CHeckVM = CHeckVM()
    
    private let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupRX()
        self.loadRequest()
    }
    
}
extension CHeckVC {
    
    private func setupUI() {
        // Add here the setup for the UI
    }
    
    private func setupRX() {
        // Add here the setup for the RX
    }
    
    func loadRequest() {
//        guard let url = URL(string: "https://stg2.dictionary.goo.ne.jp/srch/app/%E3%81%9B/m0u") else {
//            return
//        }
//        let request = URLRequest(url: url)
////        request.cachePolicy = URLRequest.CachePolicy
//        webView.load(request)
    }
}
