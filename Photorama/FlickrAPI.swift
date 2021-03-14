//  FlickrAPI.swift
//  Photorama
//  Created by Kranthi Pyreddy on 3/13/21.
import Foundation
//Creating the EndPoint enumeration
enum EndPoint: String {
case interestingPhotos = "flickr.interestingness.getList"
}
struct FlickrAPI {
    //Adding the base URL for the Flickr requests
    private static let baseURLString = "https://api.flickr.com/services/rest"
    //Adding an API key property
    private static let apiKey = "a6d819499131071f158fd740860a5a88"
    //Implementing a method to return a Flickr URL
    private static func flickrURL(endPoint: EndPoint,
    parameters: [String:String]?) ->
    URL {
        //Adding the additional parameters to the URL
        var components = URLComponents(string: baseURLString)!
        var queryItems = [URLQueryItem]()
        //Adding the shared parameters to the URL
        let baseParams = [
        "method": endPoint.rawValue,
        "format": "json",
        "nojsoncallback": "1",
        "api_key": apiKey
        ]
        for (key, value) in baseParams {
        let item = URLQueryItem(name: key, value: value)
        queryItems.append(item)
        }
        if let additionalParams = parameters {
        for (key, value) in additionalParams {
        let item = URLQueryItem(name: key, value: value)
        queryItems.append(item)
        }
        }
        components.queryItems = queryItems
        return components.url!
    }
    //Exposing a URL for interesting photos
    static var interestingPhotosURL: URL {
    return flickrURL(endPoint: .interestingPhotos,
    parameters: ["extras": "url_z,date_taken"])
    }
    /*need to define a
    type to represent each layer of the
    structure for JSONDecoder to
    unpack */
    //Defining the response structures
    struct FlickrResponse: Codable {
    //let photos: FlickrPhotosResponse
    //Adding coding keys to the response structures
        let photosInfo: FlickrPhotosResponse
        enum CodingKeys: String, CodingKey {
        case photosInfo = "photos"
        }
    }
    struct FlickrPhotosResponse: Codable {
    //let photo: [Photo]
    //Adding coding keys to the response structures
        let photos: [Photo]
        enum CodingKeys: String, CodingKey {
        case photos = "photo"
        }
    }
    /* A method that takes in an instance of Data and uses the JSONDecoder
     class to convert the data into an instance of FlickrResponse */
    //Decoding the JSON data
    static func photos(fromJSON data: Data) -> Result<[Photo], Error>
    {
    do {
    let decoder = JSONDecoder()
    let flickrResponse = try
    decoder.decode(FlickrResponse.self, from: data)
    return .success(flickrResponse.photosInfo.photos)
    } catch {
    return .failure(error)
    }
    }
}

