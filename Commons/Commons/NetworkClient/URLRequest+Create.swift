//
//  NetworkRequest.swift
//  Networking
//
//  Created by Muhammed Rashid on 07/01/21.
//

import Foundation
/**
    HTTP method definitions.
 */
public enum RequestMethod: String {
    case get = "GET"
    case post = "POST"
    case delete = "DELETE"
    case put = "PUT"
}

extension URLRequest {
    
    /**
     Creates a URLRequest  for the specified method, URL string, parameters, and
     headers.
     
     - parameter URLString:  The URL string.
     - parameter parameters: The parameters. `nil` by default.
     - parameter headers:    The HTTP headers. `nil` by default.
     - parameter method:     The Request Method.

     - returns: The created request.
     */
    static func prepareURLRequest(urlString: String, parameters: [String: Any]? = nil, headers: [String: String]? = nil, method: RequestMethod? = .get) -> URLRequest? {
        guard let url = URL(string: urlString) else {
            return nil
        }
        return prepareURLRequest(url: url, parameters: parameters, headers: headers, method: method)
    }
    
    /**
     Creates a URLRequest  for the specified method, URL , parameters, and
     headers.
     
     - parameter url:  The URL..
     - parameter parameters: The parameters. `nil` by default.
     - parameter headers:    The HTTP headers. `nil` by default.
     - parameter method:     The Request Method.

     - returns: The created request.
     */
    static func prepareURLRequest(url: URL, parameters: [String: Any]? = nil, headers: [String: String]? = nil, method: RequestMethod? = .post) -> URLRequest? {
        var request = URLRequest(url: url)
        
        if let params = parameters {
            if method == .get || method == .delete {
                guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                    return nil
                }
                let queryItems = params.map {
                    URLQueryItem(name: $0.key, value: String(describing: $0.value))
                }
                urlComponents.queryItems = (urlComponents.queryItems ?? []) + queryItems
                guard let newURL = urlComponents.url else {
                    return nil
                }
                request = URLRequest(url: newURL)
            }
            else {
                let jsonData = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
                request.httpBody = jsonData
            }
        }
        
        request.httpMethod = method?.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let requestHeaders = headers {
            for (field, value) in requestHeaders {
                request.setValue(value, forHTTPHeaderField: field)
            }
        }
        return request
    }
}
