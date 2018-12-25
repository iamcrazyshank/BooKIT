//
//  RideCell.swift
//  BookIt
//
//  Created by Shashank Chandran on 12/24/18.
//  Copyright © 2018 Shashank Chandran. All rights reserved.
//

import UIKit

class RideCell: UICollectionViewCell {
    @IBOutlet weak var cabImage: UIImageView!
    @IBOutlet weak var cabPrice: UITextField!
    


override var isSelected: Bool{
    willSet{
        super.isSelected = newValue
        if newValue
        {
            self.cabImage.layer.borderWidth = 2
            self.cabPrice.textColor = UIColor.red
        }
        else
        {
           self.cabImage.layer.borderWidth = 0
         
            self.cabPrice.textColor = UIColor.black
        }
    }
}

}
