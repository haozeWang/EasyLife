//
//  EveryDayScheduleCell.swift
//  EasyLife
//
//  Created by 王昊泽 on 17/3/11.
//  Copyright © 2017年 Haoze Wang. All rights reserved.
//

import UIKit

class EveryDayScheduleCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var fin_time: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.title.text = ""
        self.fin_time.text = ""
    }

}


