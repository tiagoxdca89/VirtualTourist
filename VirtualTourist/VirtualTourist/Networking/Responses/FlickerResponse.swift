//
//  FlickerResponse.swift
//  VirtualTourist
//
//  Created by Tiago Xavier da Cunha Almeida on 26/05/2020.
//  Copyright © 2020 Tiago Xavier da Cunha Almeida. All rights reserved.
//

import Foundation

struct FlickerResponse: Codable {
    let results: [PhotoResponse]
}

struct PhotoResponse: Codable {
    let data: Data?
    let createdAt: String?
    let name: String?
}
