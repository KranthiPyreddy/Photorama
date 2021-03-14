//  PhotoStore.swift
//  Photorama
//  Created by Kranthi Pyreddy on 3/13/21.
import Foundation

class PhotoStore {
    //Adding a URLSession property
    private let session: URLSession = {
    let config = URLSessionConfiguration.default
    return URLSession(configuration: config)
    }()
   // Implementing a method to start the web service request
    func fetchInterestingPhotos() {
    //create a URL instance using the FlickrAPI struct
    let url = FlickrAPI.interestingPhotosURL
// instantiate a request object with it
    let request = URLRequest(url: url)
    let task = session.dataTask(with: request) {
    (data, response, error) in
    if let jsonData = data {
    if let jsonString = String(data: jsonData,
    encoding: .utf8) {
    print(jsonString)
    }
    } else if let requestError = error {
    print("Error fetching interesting photos: \(requestError)")
    } else {
    print("Unexpected error with the request")
    }
    }
    task.resume()
    }
}
