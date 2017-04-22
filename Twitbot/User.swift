//
//  User.swift
//  Twitbot
//
//  Created by Dam Vu Duy on 3/24/16.
//  Copyright © 2016 dotRStudio. All rights reserved.
//

import UIKit

class User: NSObject {
    static let USER_DID_LOGOUT_NOTIFICATION = "UserDidLogout"
    
    var userID: String?
    var name: String?
    var screenName: String?
    var profileUrl: URL?
    var profileHighUrl: URL?
    var profileCoverUrl: URL?
    var tagline: String?
    var favoritesCount = 0
    var followingCount = 0
    var followerCount = 0
    
    var dictionary: NSDictionary?
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        name = dictionary["name"] as? String
        screenName = dictionary["screen_name"] as? String
        
        if let profileUrl = dictionary["profile_image_url_https"] as? String {
            let arr = profileUrl.components(separatedBy: "_normal")
            let proHigh = arr[0] + arr[1]
            self.profileHighUrl = URL(string: proHigh)
            self.profileUrl = URL(string: profileUrl)
        }
        
        if let profileCoverUrl = dictionary["profile_banner_url"] as? String {
            self.profileCoverUrl = URL(string: profileCoverUrl)
        }
        userID = dictionary["id_str"] as? String
        favoritesCount = dictionary["favourites_count"] as! Int
        followerCount = dictionary["followers_count"] as! Int
        followingCount = dictionary["friends_count"] as! Int
        tagline = dictionary["description"] as? String
    }
    
    static var _currentUser: User? = nil
    
    class var currentUser: User? {
        get {
            if _currentUser == nil {
                let defaults = UserDefaults.standard
                let userData = defaults.object(forKey: "currentUserData") as? Data
                if let userData = userData {
                    let dictionary = try! JSONSerialization.jsonObject(with: userData, options: [])
                    _currentUser = User(dictionary: dictionary as! NSDictionary)
                }
                else {
                    _currentUser = nil
                }
            }
            return _currentUser
        }
        
        set(user) {
            _currentUser = user
            let defaults = UserDefaults.standard
            if let user = user {
                let data = try! JSONSerialization.data(withJSONObject: user.dictionary!, options: [])
                defaults.set(data, forKey: "currentUserData")
            }
            else {
                defaults.set(nil, forKey: "currentUserData")
            }
            defaults.synchronize()
        }
    }
}
