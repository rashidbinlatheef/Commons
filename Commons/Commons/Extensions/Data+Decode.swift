//
//  Data+Decode.swift
//  Commons
//
//  Created by Muhammed Rashid on 07/01/21.
//

import Foundation

extension Data {
    public func decodeTo<T: Decodable>(_ type: T.Type) -> T? {
        do {
            let response = try JSONDecoder().decode(type, from: self)
            return response
        } catch let jsonError {
            print(jsonError)
            return nil
        }
    }
}
