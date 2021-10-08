//
//  BackgroundColorVM.swift
//  Note
//
//  Created by haiphan on 08/10/2021.
//

import Foundation
import RxSwift

class BackgroundColorVM {
    
    @VariableReplay var listColors: [ColorModel] = []
    
    private let disposeBag = DisposeBag()
    
    init() {
        self.loadValue()
    }
    
    private func loadValue() {
        self.getListColor()
    }
    
    private func getListColor() {
        ReadJSONFallLove.shared
            .readJSONObs(offType: [ColorModel].self, name: "ColorsJson", type: "json")
            .asObservable()
            .bind { [weak self] list in
                guard let wSelf = self else { return }
                wSelf.listColors = list
            }.disposed(by: disposeBag)
    }
    
}
