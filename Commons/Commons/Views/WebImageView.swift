//
//  UIImageView+Download.swift
//  Commons
//
//  Created by Muhammed Rashid on 06/01/21.
//

import Foundation
import UIKit

public class WebImageView: UIImageView {
    private var imageDownloader: ImageDownloader?

    public override var image: UIImage? {
        get {
            super.image
        }
        set {
            imageDownloader?.cancelAllRequests()
            super.image = newValue
        }
    }
    
    public func setImageFromUrlString(_ urlString: String, placeHolder: UIImage? = nil) {
        image = placeHolder
        imageDownloader = ImageDownloader()
        imageDownloader?.downloadImageFromUrlString(urlString, completion: { downloadedImage in
            if let image = downloadedImage {
                self.image = image
            }
        })
    }
}
