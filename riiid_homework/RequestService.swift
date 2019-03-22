//
//  requestService.swift
//  riiid_homework
//
//  Created by admin on 21/03/2019.
//  Copyright © 2019 wndzlf. All rights reserved.
//

import Foundation

protocol RequestService: class {
    func requestGithubLogin(completionHandler: @escaping (DataResponse<GitHubModelForNetwork>) -> Void)
}

public enum DataResponse<Data> {
    case sucess(Data)
    case failed(Error)
    
    init(value: Data, error: Error?) {
        if let error = error {
            self = .failed(error)
        } else {
            self = .sucess(value)
        }
    }
    
    public var isSucess: Bool {
        switch self {
        case .sucess:
            return true
        case .failed:
            return false
        }
    }
    
    public var isFailure: Bool {
        return !isSucess
    }
    
    public var value: Data? {
        switch self {
        case .sucess(let value):
            return value
        case .failed:
            return nil
        }
    }
    
    public var error: Error? {
        switch self {
        case .sucess:
            return nil
        case .failed(let error):
            return error
        }
    }
}
