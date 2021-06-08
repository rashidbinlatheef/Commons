//
//  NetworkClient.swift
//  Networking
//
//  Created by Muhammed Rashid on 16/03/21.
//

import Foundation

class NetworkSessionManager {
    static var sharedInstance = NetworkSessionManager()
    private var _sessionManager: URLSession?
    
    var sessionManager: URLSession? {
        if _sessionManager == nil {
            let configuration = URLSessionConfiguration.default
            configuration.tlsMinimumSupportedProtocolVersion = tls_protocol_version_t.TLSv12
            configuration.timeoutIntervalForRequest = 30
            configuration.timeoutIntervalForResource = 30
            _sessionManager = URLSession(configuration: configuration)
        }
        return _sessionManager
    }
}
