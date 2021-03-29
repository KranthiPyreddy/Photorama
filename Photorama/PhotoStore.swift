//  PhotoStore.swift
//  Photorama
//  Created by Kranthi Pyreddy on 3/13/21.
import UIKit
//Adding an error type
enum PhotoError: Error {
    case imageCreationError
    case missingImageURL
}

class PhotoStore {
    //Adding an ImageStore property
    let imageStore = ImageStore()
    //Adding a URLSession property
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    // Implementing a method to start the web service request
    //Adding a completion handler after the method name
    func fetchInterestingPhotos(completion: @escaping
                                    (Result<[Photo], Error>) -> Void) {
        //create a URL instance using the FlickrAPI struct
        let url = FlickrAPI.interestingPhotosURL
        // instantiate a request object with it
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) {
            (data, response, error) in
            /*
             if let jsonData = data {
             if let jsonString = String(data: jsonData,
             encoding: .utf8) {
             print(jsonString)
             }
             } else if let requestError = error {
             print("Error fetching interesting photos: \(requestError)")
             } else {
             print("Unexpected error with the request")
             } */
            let result = self.processPhotosRequest(data: data, error: error)
            /*Executing the interesting photos completion handler on the main thread*/
            OperationQueue.main.addOperation {
            completion(result)
            }
        }
        task.resume()
    }
    //Processing the data that is returned from the web service
    private func processPhotosRequest(data: Data?,
                                      error: Error?) ->
    Result<[Photo], Error> {
        guard let jsonData = data else {
            return .failure(error!)
        }
        return FlickrAPI.photos(fromJSON: jsonData)
    }
    //Implementing a method to download image data
    func fetchImage(for photo: Photo,completion: @escaping (Result<UIImage, Error>) ->
                        Void) {
        //Using the image store to cache images
        let photoKey = photo.photoID
        if let image = imageStore.image(forKey: photoKey) {
        OperationQueue.main.addOperation{
        completion(.success(image))
        }
        return
        } //
        guard let photoURL = photo.remoteURL else {
            completion(.failure(PhotoError.missingImageURL))
            return
        }
        let request = URLRequest(url: photoURL)
        let task = session.dataTask(with: request) {
            (data, response, error) in
        //Executing the image completion handler
            let result = self.processImageRequest(data: data, error:
            error)
            //Using the image store to cache images
            if case let .success(image) = result {
            self.imageStore.setImage(image, forKey: photoKey)
            } //
           
            /*Executing the image fetching completion handler on the main thread*/
            OperationQueue.main.addOperation {
            completion(result)
            }
        }
        task.resume()
    }
    //Processing the image request data
    private func processImageRequest(data: Data?,error: Error?) ->
    Result<UIImage, Error> {
        guard
            let imageData = data,
            let image = UIImage(data: imageData) else {
            // Couldn't create an image
            if data == nil {
                return .failure(error!)
            } else {
                return .failure(PhotoError.imageCreationError)
            }
        }
        return .success(image)
    }
}
