//
//  ReportTableViewCell.swift
//  CalorieApp
//
//  Created by Workspace on 24/04/22.
//

import UIKit

class ReportTableViewCell: BaseTableViewCell {

    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var calorieLabel: UILabel!
    
    static let id = String(describing: ReportTableViewCell.self)
    
    func configure(user: String, calories: Int) {
        userLabel.text = "User: \(user)"
        calorieLabel.text = "Calories: \(calories)"
    }
}
