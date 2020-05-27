//
//  PhotoCollectionViewCell.swift
//  VirtualTourist
//
//  Created by Tiago Xavier da Cunha Almeida on 27/05/2020.
//  Copyright © 2020 Tiago Xavier da Cunha Almeida. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var image: UIImageView!
    
    
    var imageName: String! {
        didSet {
//            image.image = UIImage(named: imageName)
        }
    }
    
}
