//  PhotoInfoViewController.swift
//  Photorama
//  Created by Kranthi Pyreddy on 3/28/21.
import UIKit
class PhotoInfoViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    //Adding a Photo property
    var photo: Photo! {
        didSet {
            navigationItem.title = photo.title
        }
    }
    var store: PhotoStore!
    //Updating the interface with the photo
    override func viewDidLoad() {
        super.viewDidLoad()
        store.fetchImage(for: photo) { (result) -> Void in
            switch result {
            case let .success(image):
                self.imageView.image = image
            case let .failure(error):
                print("Error fetching image for photo: \(error)")
            }
        }
    }
}
