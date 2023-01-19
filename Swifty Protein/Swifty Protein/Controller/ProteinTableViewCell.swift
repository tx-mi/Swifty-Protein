//
//  ProteinTableViewCell.swift
//  Swifty Protein
//
//  Created by Morgane on 22/06/2019.
//  Copyright © 2019 Morgane DUBUS. All rights reserved.
//

import Foundation
import UIKit

class ProteinTableViewCell:UITableViewCell {
    
    @IBOutlet weak var name: UILabel!
    
    var ligand:String? {
        didSet {
            if let l = ligand {
                name?.text = l
            }
        }
    }
}
