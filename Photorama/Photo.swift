//  Photo.swift
//  Photorama
//  Created by Kranthi Pyreddy on 3/14/21.
import Foundation
//Creating the Photo class & Conforming Photo to Codable
class Photo: Codable {
let title: String
//let remoteURL: URL
//Making the remoteURL optional/ By default Photo has non-optional properties
let remoteURL: URL?
let photoID: String
let dateTaken: Date
//Adding coding keys to the Photo class
    enum CodingKeys: String, CodingKey {
    case title
    case remoteURL = "url_z"
    case photoID = "id"
    case dateTaken = "datetaken"
    }
}
//Defining Photo equality
extension Photo: Equatable {
static func == (lhs: Photo, rhs: Photo) -> Bool {
// Two Photos are the same if they have the same photoID
return lhs.photoID == rhs.photoID
}
}
