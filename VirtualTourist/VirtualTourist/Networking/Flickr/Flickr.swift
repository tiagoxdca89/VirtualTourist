//
//  Flickr.swift
//  VirtualTourist
//
//  Created by Tiago Xavier da Cunha Almeida on 28/05/2020.
//  Copyright © 2020 Tiago Xavier da Cunha Almeida. All rights reserved.
//

import UIKit

class Flickr {
    
  let apiKey = "6857b2f3fb97230b27dd5a09f7ef3b47"
    
  enum Error: Swift.Error {
    case unknownAPIResponse
    case generic
  }
  
    func searchFlickr(for searchTerm: String, page: Int, lon: Double, lat: Double, completion: @escaping (Result<FlickrSearchResults>) -> Void) {
        guard let searchURL = flickrSearchURL(for: searchTerm, page: page, lon: lon, lat: lat) else {
            completion(Result.error(Error.unknownAPIResponse))
            return
        }
        
        let searchRequest = URLRequest(url: searchURL)
        
        URLSession.shared.dataTask(with: searchRequest) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completion(Result.error(error))
                }
                return
            }
            
            guard let _ = response as? HTTPURLResponse, let data = data else {
                DispatchQueue.main.async {
                    completion(Result.error(Error.unknownAPIResponse))
                }
                return
            }
            
            do {
                guard let resultsDictionary = try JSONSerialization.jsonObject(with: data) as? [String: AnyObject], let status = resultsDictionary["stat"] as? String
                    else {
                        DispatchQueue.main.async {
                            completion(Result.error(Error.unknownAPIResponse))
                        }
                        return
                    }
                
                switch (status) {
                case "ok":
                    print("Results processed OK")
                case "fail":
                    DispatchQueue.main.async {
                        completion(Result.error(Error.generic))
                    }
                    return
                default:
                    DispatchQueue.main.async {
                        completion(Result.error(Error.unknownAPIResponse))
                    }
                    return
                }
                
                guard
                    let photosContainer = resultsDictionary["photos"] as? [String: AnyObject],
                    let photosReceived = photosContainer["photo"] as? [[String: AnyObject]]
                    else {
                        DispatchQueue.main.async {
                            completion(Result.error(Error.unknownAPIResponse))
                        }
                        return
                }
                
                let photos: [FlickrPhoto] = photosReceived.compactMap { photoObject in
                    guard
                        let photoID = photoObject["id"] as? String,
                        let farm = photoObject["farm"] as? Int ,
                        let server = photoObject["server"] as? String ,
                        let secret = photoObject["secret"] as? String
                        else {
                            return nil
                    }
                    return FlickrPhoto(photoID: photoID, farm: farm, server: server, secret: secret)
                }
                
                let searchResults = FlickrSearchResults(searchTerm: searchTerm, searchResults: photos)
                DispatchQueue.main.async {
                    completion(Result.results(searchResults))
                }
            } catch {
                completion(Result.error(error))
                return
            }
        }.resume()
    }
  
    private func flickrSearchURL(for searchTerm: String, page: Int, lon: Double, lat: Double) -> URL? {
        guard let term = searchTerm.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics) else {
            return nil
        }
        let URLString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&text=\(term)&page=\(page)&per_page=20&lat=\(lat)&lon=\(lon)&format=json&nojsoncallback=1"
        return URL(string: URLString)
    }
}
