//
//  TweetCell.swift
//  Tiki Test
//
//  Created by Nguyễn Tấn Phúc on 5/21/18.
//  Copyright © 2018 Nguyễn Tấn Phúc. All rights reserved.
//

import UIKit

class TweetCell: UITableViewCell {
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupContent(content: String) {
        self.numberLabel.text = "\(content.count)"
        self.contentLabel.text = content
    }
}
