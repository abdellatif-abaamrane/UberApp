//
//  NetworkClient.swift
//  Twitter
//
//  Created by macbook-pro on 14/05/2020.
//

import Foundation

class NetworkClient {
    static let shared = NetworkClient()
    private init() {}
    
    lazy var session : URLSession = {
        let session = URLSession.shared
        return session
    }()
    
    
    func getProfileImage(url: URL, completion: @escaping ((Data?, URLResponse?, Error?) -> Void)) {
        let request = URLRequest(url: url,cachePolicy: .returnCacheDataElseLoad)
        
        let cache = URLCache.shared
        cache.diskCapacity = 1024 * 1024 * 300
        DispatchQueue.global(qos: .default).async {
            if let cachedResponse = cache.cachedResponse(for: request) {
                    completion(cachedResponse.data, cachedResponse.response, nil)
            } else {
                self.session.dataTask(with: request) { (data, response, error) in

                    if let data = data,
                       let response = response {
                        let storeCachedResponse = CachedURLResponse(response: response, data: data)
                        URLCache.shared.storeCachedResponse(storeCachedResponse, for: request)
                    }
                    completion(data,response,error)
                }.resume()
            }
        }
        
    }

}
