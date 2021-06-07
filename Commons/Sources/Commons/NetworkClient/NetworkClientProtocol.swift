//
//  NetworkClientProtocol.swift
//  Networking
//
//  Created by Muhammed Rashid on 07/01/21.
//

import Foundation

/// The Protocol implemented by Netwroking classes
public protocol NetworkClientProtocol {
    
    /**
     Execute network requests
     - parameter URLString:  The URL string.
     - parameter parameters: The parameters. `nil` by default.
     - parameter headers:    The HTTP headers. `nil` by default.
     - parameter method:     The Request Method.
     */
    func executeRequestWith(urlString: String, parameters: [String: Any]?, headers: [String: String]?, method: RequestMethod?, completion: @escaping(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> ())
}


extension NetworkClientProtocol {
    public func executeRequestWith(urlString: String, parameters: [String: Any]?, headers: [String: String]?, method: RequestMethod?, completion: @escaping(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> ()) {
        guard let request = URLRequest.prepareURLRequest(urlString: urlString, parameters: parameters, headers: headers, method: method) else {
            return
        }
                
        let urlSessionTask = NetworkSessionManager.sharedInstance.sessionManager?.dataTask(with: request) { data, response, error in
        
            completion(data, response, error)
        }
        urlSessionTask?.resume()
    }
}
