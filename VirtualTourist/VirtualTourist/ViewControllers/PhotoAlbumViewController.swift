//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Tiago Xavier da Cunha Almeida on 26/05/2020.
//  Copyright © 2020 Tiago Xavier da Cunha Almeida. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController {
    
    @IBOutlet weak var mapKit: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var btnNewCollection: UIButton!
    
    let leftAndRightPaddings: CGFloat = 0
    
    var location: MKLocation?
    lazy var itemSize: CGSize = {
        let collectionWidth = UIScreen.main.bounds.width / 3 - 2
        let itemWidth = collectionWidth
        return CGSize(width: itemWidth, height: 120)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
//        print(location?.name)
    }

}

extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCollectionViewCell else {
            return UICollectionViewCell()
        }
//        cell.imageName = "Image"
        return cell
    }
}

extension PhotoAlbumViewController: UICollectionViewDelegateFlowLayout {
    
     
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return itemSize
    }
    

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) //.zero
    }
}
