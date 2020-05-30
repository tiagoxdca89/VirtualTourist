//
//  Client.swift
//  VirtualTourist
//
//  Created by Tiago Xavier da Cunha Almeida on 26/05/2020.
//  Copyright © 2020 Tiago Xavier da Cunha Almeida. All rights reserved.
//

import Foundation

class Client {
    
    static let apiKey = "6857b2f3fb97230b27dd5a09f7ef3b47"
    static let secret = "3596c683186d3ace"
    
    enum Endpoints {
        case getPhotos
        
        var stringValue: String {
            switch self {
            case .getPhotos:
                return FlickerPhotosRequest.getFlickerPhotos.path
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
}

extension Client {
    
    static func getFlickerPhotos(studentID: String, completion: @escaping ([PhotoResponse], Error?) -> Void) {
        taskForGETRequest(url: Endpoints.getPhotos.url, responseType: FlickerResponse.self) { (response, error) in
            if let response = response {
                completion(response.results, nil)
            } else {
                completion([], error)
            }
        }
    }
}


extension Client {
    
    @discardableResult
    static func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionDataTask {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                do {
                    let errorResponse = try decoder.decode(ErrorResponse.self, from: data) as Error
                    DispatchQueue.main.async {
                        completion(nil, errorResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        }
        task.resume()
        
        return task
    }
}
