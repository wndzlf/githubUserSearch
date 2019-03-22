//
//  ViewController.swift
//  riiid_homework
//
//  Created by admin on 20/03/2019.
//  Copyright © 2019 wndzlf. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UISearchBarDelegate {
    
    private var userModel: [GithubModel] = []
    
    private var timer: Timer? = nil
    
    private let heightOfTableViewCell:CGFloat = 100
    
    private let searchTimeInterval:TimeInterval = 0.4
    
    private var lastSearchText: String = ""
    
    //MARK:- PageNation
    private var isDataLoading:Bool = false
    
    private var pageNo:Int = 1

    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        
        searchController.searchBar.becomeFirstResponder()
        
        searchController.searchBar.autocapitalizationType = .none
        
        self.navigationItem.searchController = searchController
        
        return searchController
    }()
    
    private var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(GitHubProfileTableViewCell.self, forCellReuseIdentifier: "githubProfileTableViewCell")
        tableView.allowsSelection = false
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDelegate()
        setTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 11.0, *) {
            navigationItem.hidesSearchBarWhenScrolling = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if #available(iOS 11.0, *) {
            navigationItem.hidesSearchBarWhenScrolling = true
        }
    }
    
    private func setDelegate() {
        searchController.searchBar.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setTableView() {
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
    }
    
    private func getUsersDataFromGithubAPINetwork(with: String, page: Int, completionHandler: @escaping (DataResponse<GitHubModelForNetwork>) -> Void) {
        
        let requestURLString = BaseURL.getGithubSearchAPIBaseURL(with: with, page: page)
        
        guard let requestURL = URL(string: requestURLString) else {
            return
        }
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "GET"
        
        NetworkManager.shared.getData(with: request) { (data, error, response) in
            guard let data = data else {
                print("Error parsing data")
                return
            }
            
            do {
                let order = try JSONDecoder().decode(GitHubModelForNetwork.self, from: data)
                DispatchQueue.main.async {
                    completionHandler(DataResponse.sucess(order))
                }
            } catch let jsonError {
                DispatchQueue.main.async {
                    completionHandler(DataResponse.failed(jsonError))
                }
            }
            
        }
    }
    
    private func getUsersReposDataFromGithubAPINetwork(with: String, completionHandler: @escaping (DataResponse<UserInfoForNetwork>) -> Void) {
        
        let requestURLString = BaseURL.getGithubSearchAPIReposBaseURL(with: with)
        
        guard let requestURL = URL(string: requestURLString) else {
            return
        }
    
        var request = URLRequest(url: requestURL)
        request.httpMethod = "GET"
        
        NetworkManager.shared.getData(with: request) { (data, error, response) in
            guard let userData = data else {
                print("Error parsing data")
                return
            }
            
            do {
                let order = try JSONDecoder().decode(UserInfoForNetwork.self, from: userData)
                DispatchQueue.main.async {
                    completionHandler(DataResponse.sucess(order))
                }
            } catch let jsonError {
                DispatchQueue.main.async {
                    print("jsonError in UserInfoForNetwork")
                    print(response)
                    completionHandler(DataResponse.failed(jsonError))
                }
            }
        }
        
    }
    
    @objc private func requestUserDataAtFirst(timer: Timer) {
        
        let firstPage: Int = 0
        
        guard var searchTextDict = timer.userInfo as? [String: String] else {
            return
        }
        
        guard let searchText = searchTextDict["searchText"] else {
            return
        }
        
        lastSearchText = searchText
        
        if searchText.count == 0 {
            
            userModel = []
            tableView.reloadData()
        } else {
            
            getUsersDataFromGithubAPINetwork(with: searchText, page: firstPage) { [weak self] (dataResponse) in
                
                DispatchQueue.global().async {
                    
                    self?.userModel = []
                    
                    guard dataResponse.isSucess, let value = dataResponse.value else {
                        return
                    }
                    
                    for user in value.users {
//                        let eachUser = GithubModel(userId: user.login,
//                                                   profileImage: user.avatarURL)
//                        self?.userModel.append(eachUser)
                        
                        self?.getUsersReposDataFromGithubAPINetwork(with: user.url) { (reponDataRespons) in
                            let eachUser = GithubModel(userId: user.login,
                                                       profileImage: user.avatarURL,
                                                       repos: reponDataRespons.value?.publicRepos)
                            self?.userModel.append(eachUser)
                        }
 
                    }
                    
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                }
            }
        }
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        lastSearchText = ""
        userModel = []
        tableView.reloadData()
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(timeInterval: searchTimeInterval,
                                     target: self,
                                     selector: #selector(requestUserDataAtFirst),
                                     userInfo: ["searchText": searchText],
                                     repeats: false)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isDataLoading = false
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
    }

    //MARK:- For Pagination
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if ((tableView.contentOffset.y + tableView.frame.size.height) >= tableView.contentSize.height)
        {
            if !isDataLoading{
                
                isDataLoading = true
                
                self.pageNo = self.pageNo + 1
                
                getUsersDataFromGithubAPINetwork(with: lastSearchText, page: self.pageNo) { [weak self] (dataResponse) in
                    DispatchQueue.global().async {
                        
                        guard dataResponse.isSucess, let value = dataResponse.value else {
                            return
                        }
                        
                        for user in value.users {
                            
                            self?.getUsersReposDataFromGithubAPINetwork(with: user.reposURL) { (reponDataRespons) in
                                let eachUser = GithubModel(userId: user.login,
                                                           profileImage: user.avatarURL,
                                                           repos: reponDataRespons.value?.publicRepos)
                                self?.userModel.append(eachUser)
                            }
                            
//                            let eachUser = GithubModel(userId: user.login, profileImage: user.avatarURL)
//                            self?.userModel.append(eachUser)
                        }
                        
                        DispatchQueue.main.async {
                            self?.tableView.reloadData()
                        }
                    }
                }
            }
        }
        
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let githubProfileTableViewCell = tableView.dequeueReusableCell(withIdentifier: "githubProfileTableViewCell") as? GitHubProfileTableViewCell else {
            return .init()
        }
        githubProfileTableViewCell.userModel = userModel[indexPath.row]
        
        return githubProfileTableViewCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightOfTableViewCell
    }
}
