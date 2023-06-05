//
//  EntryTableViewCell.swift
//  CalorieApp
//
//  Created by Workspace on 20/04/22.
//

import UIKit
import Kingfisher

class EntryTableViewCell: UITableViewCell {

    @IBOutlet weak var entryNameLabel: UILabel!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var entryImageView: UIImageView!
    @IBOutlet weak var entryCalorieLabel: UILabel!
    @IBOutlet weak var entryDateLabel: UILabel!
    
    static let id = String(describing: EntryTableViewCell.self)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        selectionStyle = .none
        
    }
    
    func configure(with entry: Entry, _ isSameDay: Bool = true, _ dailyTotal: Int = 0, _ dailyCalorieLimit: Int = 0) {
        entryNameLabel.text = entry.name
        entryCalorieLabel.text = "calories: \(entry.calorie)"
        entryDateLabel.text = entry.date.stringDateAndTime
        
        if !entry.imageURL.isEmpty {
            guard let url = URL(string: entry.imageURL) else { return }
            entryImageView.kf.setImage(
                with: url,
                placeholder: UIImage.placeholder,
                options: [
                    .processor(DownsamplingImageProcessor(size: entryImageView.frame.size)),
                    .scaleFactor(UIScreen.main.scale),
                    .cacheOriginalImage
                ],
                completionHandler: nil)

        } else {
            entryImageView.image = .placeholder
        }
        warningLabel.isHidden = true
        
        if !isSameDay {
            warningLabel.isHidden = false
        }
        
        warningLabel.layer.masksToBounds = true
        warningLabel.layer.cornerRadius = 4
        
        if dailyTotal > dailyCalorieLimit {
            warningLabel.backgroundColor = .orange
            warningLabel.text = "Daily calorie limit exceeded: \(dailyTotal)"
        } else {
            warningLabel.backgroundColor = .green
            warningLabel.text = "Daily calorie: \(dailyTotal)"
        }
    }
}
