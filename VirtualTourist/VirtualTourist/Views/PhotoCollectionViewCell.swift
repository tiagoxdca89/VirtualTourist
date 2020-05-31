//
//  PhotoCollectionViewCell.swift
//  VirtualTourist
//
//  Created by Tiago Xavier da Cunha Almeida on 27/05/2020.
//  Copyright © 2020 Tiago Xavier da Cunha Almeida. All rights reserved.
//

import UIKit
import Kingfisher

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    func loadImageBy(url: String) {
        let processor = DownsamplingImageProcessor(size: imageView.bounds.size)
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(
            with: URL(string: url),
            options: [
                .processor(processor),
                .scaleFactor(imageView.contentScaleFactor),
                .transition(.fade(0.5)),
                .cacheOriginalImage
            ])
    }
    
    func loadImageBy(data: Data?) {
        guard let data = data else { return }
        imageView.image = UIImage(data: data)
    }
}
