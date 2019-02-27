//
//  PhotoCollectionCell.swift
//  VirtualTourist
//
//  Created by Khaled H on 27/02/2019.
//  Copyright © 2019 Khaled H. All rights reserved.
//

import UIKit

class PhotoCollectionCell: UICollectionViewCell {
    
   

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var imageUrl: String = ""
    
    override var isSelected: Bool{
        didSet{
            if self.isSelected
            {
                
                self.contentView.alpha = 0.5
            }
            else
            {
                
                self.contentView.alpha = 1.0
            }
        }
    }
}
