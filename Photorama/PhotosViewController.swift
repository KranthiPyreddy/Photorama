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
    store.fetchInterestingPhotos()
    }

}

