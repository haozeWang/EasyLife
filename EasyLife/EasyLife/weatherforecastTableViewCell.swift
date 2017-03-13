//
//  weatherforecastTableViewCell.swift
//  EasyLife
//
//  Created by 王昊泽 on 17/3/10.
//  Copyright © 2017年 Haoze Wang. All rights reserved.
//

import UIKit

class weatherforecastTableViewCell: UITableViewCell {

    @IBOutlet weak var UItemp: UILabel!
    @IBOutlet weak var UIweather: UIImageView!
    @IBOutlet weak var UIdatelabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
