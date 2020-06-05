//
//  Result.swift
//  VirtualTourist
//
//  Created by Tiago Xavier da Cunha Almeida on 28/05/2020.
//  Copyright © 2020 Tiago Xavier da Cunha Almeida. All rights reserved.
//

import Foundation

enum Result<ResultType> {
  case results(ResultType)
  case error(Error)
}
