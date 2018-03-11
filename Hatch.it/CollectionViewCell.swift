//
//  CollectionViewCell.swift
//  Hatch.it
//
//  Created by Stephen Thomas on 1/27/18.
//  Copyright © 2018 Hatch Inc. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var interestsImage: UIImageView!
    @IBOutlet weak var interestsTitle: UILabel!
    override func prepareForReuse() {
        super.prepareForReuse()
        self.interestsImage.image = nil
    }
    
}
