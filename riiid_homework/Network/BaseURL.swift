//
//  baseURL.swift
//  riiid_homework
//
//  Created by admin on 22/03/2019.
//  Copyright © 2019 wndzlf. All rights reserved.
//

import Foundation

struct BaseURL {
    
    static private let githubSearchAPIBaseURL = "https://api.github.com/search/"
    
    static private let githubSearchRepoAPIBaseURL = "https://api.github.com/users/"
    
    static func getGithubSearchAPIBaseURL(with: String, page: Int) -> String {
        return BaseURL.githubSearchAPIBaseURL + "users?q=\(with)&page=\(page)&per_page=20"
    }
    
    static func getGithubSearchAPIReposBaseURL(with: String) -> String {
        return "\(with)"
    }
}
