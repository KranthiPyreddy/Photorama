//  PhotoStore.swift
//  Photorama
//  Created by Kranthi Pyreddy on 3/13/21.
import UIKit

import CoreData
//Adding an error type
enum PhotoError: Error {
    case imageCreationError
    case missingImageURL
}

class PhotoStore {
    //Adding an ImageStore property
    let imageStore = ImageStore()
    
    //Adding an NSPersistentContainer property hold on to an instance of NSPersistentContainer
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Photorama")
        container.loadPersistentStores { (description, error) in
            if let error = error {
                print("Error setting up Core Data (\(error)).")
            }
        }
        return container
    }()
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
            //let result = self.processPhotosRequest(data: data, error: error)
            //Saving photos on successful fetch
            var result = self.processPhotosRequest(data: data, error:
                                                    error)
            if case .success = result {
                do {
                    try self.persistentContainer.viewContext.save()
                } catch {
                    result = .failure(error)
                }
            }
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
        //return FlickrAPI.photos(fromJSON: jsonData)
        //Inserting a Photo into a context
        
        let context = persistentContainer.viewContext
        switch FlickrAPI.photos(fromJSON: jsonData) {
        case let .success(flickrPhotos):
            let photos = flickrPhotos.map { flickrPhoto -> Photo in
                //Fetching previously saved photos
                //Duplicate photos will no longer be inserted into Core Data.
                let fetchRequest: NSFetchRequest<Photo> =
                    Photo.fetchRequest()
                let predicate = NSPredicate(
                    format: "\(#keyPath(Photo.photoID)) == \(flickrPhoto.photoID)"
                )
                fetchRequest.predicate = predicate
                var fetchedPhotos: [Photo]?
                context.performAndWait {
                    fetchedPhotos = try? fetchRequest.execute()
                }
                if let existingPhoto = fetchedPhotos?.first {
                    return existingPhoto
                }
                var photo: Photo!
                context.performAndWait {
                    photo = Photo(context: context)
                    photo.title = flickrPhoto.title
                    photo.photoID = flickrPhoto.photoID
                    photo.remoteURL = flickrPhoto.remoteURL
                    photo.dateTaken = flickrPhoto.dateTaken
                }
                return photo
            }
            return .success(photos)
        case let .failure(error):
            return .failure(error)
        }
    }
    //Implementing a method to download image data
    func fetchImage(for photo: Photo,completion: @escaping (Result<UIImage, Error>) ->
                        Void) {
        //Using the image store to cache images
        //Unwrapping the photoKey
        guard let photoKey = photo.photoID else {
            preconditionFailure("Photo expected to have a photoID.")
        }
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
    //Implementing a method to fetch all photos from disk
    func fetchAllPhotos(completion: @escaping (Result<[Photo],
                                                      Error>) -> Void) {
        let fetchRequest: NSFetchRequest<Photo> =
            Photo.fetchRequest()
        let sortByDateTaken = NSSortDescriptor(key:
                                                #keyPath(Photo.dateTaken),
                                               ascending: true)
        fetchRequest.sortDescriptors = [sortByDateTaken]
        let viewContext = persistentContainer.viewContext
        viewContext.perform {
            do {
                let allPhotos = try viewContext.fetch(fetchRequest)
                completion(.success(allPhotos))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
