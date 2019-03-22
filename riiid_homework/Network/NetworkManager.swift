//
//  NetworkManager.swift
//  riiid_homework
//
//  Created by admin on 21/03/2019.
//  Copyright © 2019 wndzlf. All rights reserved.
//

import Foundation

class NetworkManager {
    
    private let session: URLSession
    
    static let shared: NetworkManager = NetworkManager()
    
    private init(_ configuration: URLSessionConfiguration) {
        self.session = URLSession(configuration: configuration)
    }
    
    private convenience init() {
        self.init(.default)
    }
    
    func getData(with: URLRequest, completionHandler: @escaping (Data?, Error?, URLResponse?) -> Void) {
        DispatchQueue.global().async {
            let task = URLSession.shared.dataTask(with: with) { (data, response, error) in
                
                if error != nil {
                    print("network error")
                }
                
                guard let data = data else {
                    return
                }
                
                DispatchQueue.main.async {
                    completionHandler(data, nil, response)
                }
            }
            task.resume()
        }
    }
}

