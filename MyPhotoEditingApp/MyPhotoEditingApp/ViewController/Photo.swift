//
//  Photo.swift
//  MyPhotoEditingApp
//
//  Created by Rishi Jha on 11/04/24.
//

import UIKit

struct Photo {
    var image: UIImage
    var filters: [CIFilter]
    var caption: String
    var backgroundImage: UIImage?
    var overlayImages: [UIImage]

    init(image: UIImage) {
        self.image = image
        self.filters = []
        self.caption = ""
        self.backgroundImage = nil
        self.overlayImages = []
    }
}
