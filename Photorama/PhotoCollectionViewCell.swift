//  PhotoCollectionViewCell.swift
//  Photorama
//  Created by Kranthi Pyreddy on 3/28/21.
import UIKit
class PhotoCollectionViewCell: UICollectionViewCell {
@IBOutlet var imageView: UIImageView!
@IBOutlet var spinner: UIActivityIndicatorView!
//Updating the cell contents
    func update(displaying image: UIImage?) {
    if let imageToDisplay = image {
    spinner.stopAnimating()
    imageView.image = imageToDisplay
    } else {
    spinner.startAnimating()
    imageView.image = nil
    }
    }
}
