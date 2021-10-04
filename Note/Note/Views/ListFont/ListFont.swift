//
//  ListFont.swift
//  Note
//
//  Created by haiphan on 04/10/2021.
//

import UIKit
import RxCocoa
import RxSwift

class ListFont: UIView {
    
    @IBOutlet weak var pickerView: UIPickerView!
    let minutes = Array(0...9)
    let seconds = Array(0...59)
    
    var recievedString: String = ""
    
    private let disposeBag = DisposeBag()
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupRX()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    override func removeFromSuperview() {
        superview?.removeFromSuperview()
    }
}
extension ListFont {
    
    private func setupUI() {
        pickerView.delegate = self
    }
    
    private func setupRX() {
        
    }
    
    func addViewToParent(view: UIView) {
        view.addSubview(self)
        self.snp.makeConstraints { make in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(BaseNavigationHeader.Constant.heightViewListFont + ConstantCommon.shared.getHeightSafeArea(type: .bottom))
        }
    }
}
extension ListFont: UIPickerViewDelegate {
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2
        
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return minutes.count
        }
        
        else {
            return seconds.count
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if component == 0 {
            return String(minutes[row])
        } else {
            
            return String(seconds[row])
        }
    }
}
