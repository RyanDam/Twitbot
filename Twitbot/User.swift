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
    var name: String?
    var screenName: String?
    var profileUrl: NSURL?
    var tagline: String?
    
    var dictionary: NSDictionary?
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        name = dictionary["name"] as? String
        screenName = dictionary["screen_name"] as? String
        if let profileUrl = dictionary["profile_image_url_https"] as? String {
            self.profileUrl = NSURL(string: profileUrl)
        }
        tagline = dictionary["description"] as? String
    }
    
    static var _currentUser: User? = nil
    
    class var currentUser: User? {
        get {
            if _currentUser == nil {
                let defaults = NSUserDefaults.standardUserDefaults()
                let userData = defaults.objectForKey("currentUserData") as? NSData
                if let userData = userData {
                    let dictionary = try! NSJSONSerialization.JSONObjectWithData(userData, options: [])
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
            let defaults = NSUserDefaults.standardUserDefaults()
            if let user = user {
                let data = try! NSJSONSerialization.dataWithJSONObject(user.dictionary!, options: [])
                defaults.setObject(data, forKey: "currentUserData")
            }
            else {
                defaults.setObject(nil, forKey: "currentUserData")
            }
            defaults.synchronize()
        }
    }
}
