//
//  GitHubProfileTableViewCell.swift
//  riiid_homework
//
//  Created by admin on 20/03/2019.
//  Copyright © 2019 wndzlf. All rights reserved.
//

import UIKit

class GitHubProfileTableViewCell: UITableViewCell {
    
    var userModel: GithubModel? {
        didSet {
            guard let userModel = userModel else {
                return
            }
            
            self.userID.text = userModel.userId
            
            //self.repositories.text = self.repositories.text ?? "" + "\(userModel.repos)"
            
            guard let imageURL = URL(string: userModel.profileImage) else {
                return
            }
            
            ImageNetworkManager.shared.getImageByCache(imageURL: imageURL) { [weak self] (image, error) in
                if error == nil {
                    self?.profileImage.image = image
                }
            }
            
        }
    }
    
    private var userID: UILabel = {
        let userID = UILabel()
        userID.translatesAutoresizingMaskIntoConstraints = false
        return userID
    }()
    
    private var profileImage: UIImageView = {
        let profileImage = UIImageView()
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        return profileImage
    }()
    
    private var repositories: UILabel = {
        let repositories = UILabel()
        repositories.translatesAutoresizingMaskIntoConstraints = false
        repositories.textColor = .lightGray
        repositories.text = "Number of repos: "
        return repositories
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        addSubview(profileImage)
        addSubview(userID)
        addSubview(repositories)
        
        NSLayoutConstraint.activate([
            
            profileImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            profileImage.centerYAnchor.constraint(equalTo: centerYAnchor),
            profileImage.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.7),
            profileImage.widthAnchor.constraint(equalTo: profileImage.heightAnchor),
            
            userID.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: 15),
            userID.topAnchor.constraint(equalTo: profileImage.topAnchor),
            
            repositories.bottomAnchor.constraint(equalTo: profileImage.bottomAnchor),
            repositories.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: 15)
        ])
    }
    
    override func prepareForReuse() {
        userID.text = ""
        profileImage.image = nil
    }

}
