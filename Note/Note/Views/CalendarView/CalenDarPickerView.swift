//
//  CalenDarPickerView.swift
//  Note
//
//  Created by haiphan on 24/10/2021.
//

import UIKit
import RxSwift

protocol CalenDarPickerViewDelegate {
    func updateReminder(day: Day)
}

class CalenDarPickerView: UIView {
    
    enum CalendarDataError: Error {
        case metadataGeneration
    }
    
    struct Constant {
        static let heightCell: CGFloat = 40
        static let heightView: CGFloat = 450
    }
    
    enum Action: Int, CaseIterable {
        case clsoe, done
    }
    
    var delegate: CalenDarPickerViewDelegate?
     
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var lbTimeMinute: UILabel!
    @IBOutlet weak var segmentCOntrol: UISegmentedControl!
    @IBOutlet var bts: [UIButton]!
    
    private let calendar = Calendar(identifier: .gregorian)
    private var selectIndex: Int?
    
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
extension CalenDarPickerView {
    
    private func setupUI() {
        self.clipsToBounds = true
        self.layer.cornerRadius = ConstantApp.shared.radiusViewDialog
        self.collectionView.register(CalendarCell.nib, forCellWithReuseIdentifier: CalendarCell.identifier)
        self.collectionView.delegate = self
        self.collectionView.isScrollEnabled = false
        
        segmentCOntrol.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: Asset.textColorApp.color], for: .selected)
        
        // color of other options
        segmentCOntrol.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)
        
    }
    
    private func setupRX() {
        Observable.just(self.generateDaysInMonth(for: Date.convertDateToLocalTime()))
            .bind(to: self.collectionView.rx.items(cellIdentifier: CalendarCell.identifier, cellType: CalendarCell.self)) { row, data, cell in
                cell.updateValue(day: data)
                if let index = self.selectIndex, index == row {
                    cell.contentView.backgroundColor = Asset.viewMoveSegment.color
                } else {
                    cell.contentView.backgroundColor = .clear
                }
            }.disposed(by: disposeBag)
        
        self.collectionView.rx.itemSelected.bind { [weak self] idx in
            guard let wSelf = self else { return }
            wSelf.selectIndex = idx.row
            wSelf.collectionView.reloadData()
        }.disposed(by: disposeBag)
        
        self.segmentCOntrol.rx.value.changed.bind { [weak self] idx in
            guard let wSelf = self, let typeTime = String.TimeTo12Or24Hour(rawValue: idx) else { return }
            let h = Date().get(.hour)
            let m = Date().get(.minute)
            wSelf.updateTime(textTime: "\(h):\(m)", coverToTime: typeTime)
        }.disposed(by: disposeBag)
        
        Action.allCases.forEach { [weak self] type in
            guard let wSelf = self else { return }
            let bt = wSelf.bts[type.rawValue]
            bt.rx.tap.bind { [weak self] _ in
                guard let wSelf = self else { return }
                switch type {
                case .clsoe: wSelf.hideView()
                case .done:
                    if let index = wSelf.selectIndex {
                        let day = wSelf.generateDaysInMonth(for: Date.convertDateToLocalTime())[index]
                        wSelf.delegate?.updateReminder(day: day)
                    }
                    wSelf.hideView()
                }
            }.disposed(by: wSelf.disposeBag)
        }
        
    }
    
    func showView() {
        self.isHidden = false
    }
    
    func hideView() {
        self.isHidden = true
    }
    
    private func updateTime(textTime: String, coverToTime: String.TimeTo12Or24Hour) {
        self.lbTimeMinute.text = textTime.coverTo12Hours(coverToTime: coverToTime)
    }
    
    private func generateDaysInMonth(for baseDate: Date) -> [Day] {
        guard let metadata = try? monthMetadata(for: baseDate) else {
            preconditionFailure("An error occurred when generating the metadata for \(baseDate)")
        }
        
        let numberOfDaysInMonth = metadata.numberOfDays
        let offsetInInitialRow = metadata.firstDayWeekday
        let firstDayOfMonth = metadata.firstDay
        
        var days: [Day] = (1..<(numberOfDaysInMonth + offsetInInitialRow))
            .map { day in
                let isWithinDisplayedMonth = day >= offsetInInitialRow
                let dayOffset = isWithinDisplayedMonth ? day - offsetInInitialRow : -(offsetInInitialRow - day)
                
                return generateDay( offsetBy: dayOffset, for: firstDayOfMonth, isWithinDisplayedMonth: isWithinDisplayedMonth)
            }
        days += generateStartOfNextMonth(using: firstDayOfMonth)
        
        return days
    }
    
    private func monthMetadata(for baseDate: Date) throws -> MonthMetadata {
        guard
            let numberOfDaysInMonth = calendar.range(of: .day, in: .month, for: baseDate)?.count,
            let firstDayOfMonth = calendar.date( from: calendar.dateComponents([.year, .month], from: baseDate))
        else {
            throw CalendarDataError.metadataGeneration
        }
        
        let firstDayWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        
        return MonthMetadata(numberOfDays: numberOfDaysInMonth, firstDay: firstDayOfMonth, firstDayWeekday: firstDayWeekday)
    }
    
    private func generateStartOfNextMonth( using firstDayOfDisplayedMonth: Date) -> [Day] {
        guard let lastDayInMonth = calendar.date( byAdding: DateComponents(month: 1, day: -1), to: firstDayOfDisplayedMonth)
        else {
            return []
        }
        
        let additionalDays = 7 - calendar.component(.weekday, from: lastDayInMonth)
        guard additionalDays > 0 else {
            return []
        }
        
        let days: [Day] = (1...additionalDays)
            .map { generateDay( offsetBy: $0, for: lastDayInMonth, isWithinDisplayedMonth: false) }
        
        return days
    }
    
    private func generateDay( offsetBy dayOffset: Int, for baseDate: Date, isWithinDisplayedMonth: Bool) -> Day {
        let date = calendar.date( byAdding: .day, value: dayOffset, to: baseDate) ?? baseDate
        return Day(date: date, number: date.covertToString(format: .d),
                   isSelected: calendar.isDate(date, inSameDayAs: Date.convertDateToLocalTime()),
                   isWithinDisplayedMonth: isWithinDisplayedMonth
        )
    }
    
    private func calculateSizeCell() -> CGSize {
        let width = collectionView.frame.width / 7
        let height = Constant.heightCell
        return CGSize(width: width, height: height)
    }
}
extension CalenDarPickerView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.calculateSizeCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
