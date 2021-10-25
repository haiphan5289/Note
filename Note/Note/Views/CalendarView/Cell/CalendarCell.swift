//
//  CalendarCell.swift
//  Note
//
//  Created by haiphan on 24/10/2021.
//

import UIKit

class CalendarCell: UICollectionViewCell {
    
    @IBOutlet weak var lbDay: UILabel!
    
    private lazy var accessibilityDateFormatter: DateFormatter = {
      let dateFormatter = DateFormatter()
      dateFormatter.calendar = Calendar(identifier: .gregorian)
      dateFormatter.setLocalizedDateFormatFromTemplate("EEEE, MMMM d")
      return dateFormatter
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func updateValue(day: Day) {
        self.lbDay.text = day.number
        accessibilityLabel = accessibilityLabel
        accessibilityLabel = accessibilityDateFormatter.string(from: day.date)
        self.applyDefaultStyle(isWithinDisplayedMonth: day.isWithinDisplayedMonth)
    }
    
    private func applyDefaultStyle(isWithinDisplayedMonth: Bool) {
      accessibilityTraits.remove(.selected)
      accessibilityHint = "Tap to select"

        self.lbDay.textColor = isWithinDisplayedMonth ? Asset.textColorApp.color : .secondaryLabel
//      self.isHidden = true
    }

}
