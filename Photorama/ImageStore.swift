//  ImageStore.swift
//  Photorama
//  Created by Kranthi Pyreddy on 3/28/21.
import UIKit
class ImageStore {
    let cache = NSCache<NSString,UIImage>()
    func setImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
        // Create full URL for image
            let url = imageURL(forKey: key)

            // Turn image into JPEG data
            if let data = image.jpegData(compressionQuality: 0.5) {
                // Write it to full URL
                try? data.write(to: url)
            }
    }
    
    func image(forKey key: String) -> UIImage? {
        //return cache.object(forKey: key as NSString)
        //Fetching the image from the filesystem if it is not in the cache
        if let existingImage = cache.object(forKey: key as NSString) {
                return existingImage
            }

            let url = imageURL(forKey: key)
            guard let imageFromDisk = UIImage(contentsOfFile: url.path) else {
                return nil
            }

            cache.setObject(imageFromDisk, forKey: key as NSString)
            return imageFromDisk
    }
    
    func deleteImage(forKey key: String) {
        cache.removeObject(forKey: key as NSString)
        //Removing the image from the filesystem
        let url = imageURL(forKey: key)
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                print("Error removing the image from disk: \(error)")
            }
    }
    //Adding a method to get a URL for a given image
    func imageURL(forKey key: String) -> URL {
        let documentsDirectories =
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = documentsDirectories.first!
        
        return documentDirectory.appendingPathComponent(key)
    }
}