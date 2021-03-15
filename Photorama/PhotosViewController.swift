//  Photorama
//  Created by Kranthi Pyreddy on 3/12/21.
import UIKit

class PhotosViewController: UIViewController {
    //Adding an image view
    @IBOutlet private var imageView: UIImageView!
    //Adding a PhotoStore property
    var store: PhotoStore!
    //Initiating the web service request
    override func viewDidLoad() {
        super.viewDidLoad()
        //store.fetchInterestingPhotos()
        //Printing the results of the request
        store.fetchInterestingPhotos {
            (photosResult) in
            switch photosResult {
            case let .success(photos):
                print("Successfully found \(photos.count) photos.")
            //Showing the first photo
                if let firstPhoto = photos.first {
                self.updateImageView(for: firstPhoto)
                }
            case let .failure(error):
                print("Error fetching interesting photos: \(error)")
            }
        }
        
    }
    //Updating the image view that will fetch the image and display it on the image view
    func updateImageView(for photo: Photo) {
    store.fetchImage(for: photo) {
    (imageResult) in
    switch imageResult {
    case let .success(image):
    self.imageView.image = image
    case let .failure(error):
    print("Error downloading image: \(error)")
    }
    }
    }
    
}

