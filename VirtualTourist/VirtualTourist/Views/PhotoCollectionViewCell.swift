//
//  PhotoCollectionViewCell.swift
//  VirtualTourist
//
//  Created by Tiago Xavier da Cunha Almeida on 27/05/2020.
//  Copyright © 2020 Tiago Xavier da Cunha Almeida. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    
    
    func setupCell(photo: FlickrPhoto) {
        
        guard let photo = photo.thumbnail else {
            return
        }
        self.imageView.image = photo
    }
    
}
