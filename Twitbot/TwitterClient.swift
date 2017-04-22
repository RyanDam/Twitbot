//
//  TwitterClient.swift
//  Twitbot
//
//  Created by Dam Vu Duy on 3/24/16.
//  Copyright © 2016 dotRStudio. All rights reserved.
// 

import UIKit
import BDBOAuth1Manager

class TwitterClient: BDBOAuth1SessionManager {
    static let sharedInstance = TwitterClient(baseURL: URL(string: "https://api.twitter.com")!
        , consumerKey: "1FWmBO3kyYNZwUEN4YIKuW95B"
        , consumerSecret: "X6PMSVywL5wPSTIOhgL1zG1k6HPYfO1Y9gg3DwTgPUz69SvtOZ")
    
    var loginSuccess: (() -> Void)?
    var loginFailture: ((Error) -> Void)?
    
    func homeTimeline(_ success: @escaping ([Tweet]) -> Void, failture: @escaping (Error) -> Void) {
        get("1.1/statuses/home_timeline.json", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            let dictionaries = response as! [NSDictionary]
            
//            print(dictionaries)
            
            let tweets = Tweet.TweetsFromArray(dictionaries)
            success(tweets)
            }, failure: { (task: URLSessionDataTask?, err: Error) in
                failture(err)
        })
    }
    
    func userTimeline(_ success: @escaping ([Tweet]) -> Void, failture: @escaping (Error) -> Void) {
        get("1.1/statuses/user_timeline.json", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            let dictionaries = response as! [NSDictionary]
            let tweets = Tweet.TweetsFromArray(dictionaries)
            success(tweets)
            }, failure: { (task: URLSessionDataTask?, err: Error) in
                failture(err)
        })
    }
    
    func userTimeline(withId id: String, success: @escaping ([Tweet]) -> Void, failture: @escaping (Error) -> Void) {
        var parameter: [String: AnyObject] = [:]
        parameter["user_id"] = id as AnyObject?
        get("1.1/statuses/user_timeline.json", parameters: parameter, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            let dictionaries = response as! [NSDictionary]
            let tweets = Tweet.TweetsFromArray(dictionaries)
            success(tweets)
            }, failure: { (task: URLSessionDataTask?, err: Error) in
                failture(err)
        })
    }
    
    func mentionTimeline(_ success: @escaping ([Tweet]) -> Void, failture: @escaping (Error) -> Void) {
        get("1.1/statuses/mentions_timeline.json", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            let dictionaries = response as! [NSDictionary]
            let tweets = Tweet.TweetsFromArray(dictionaries)
            success(tweets)
        }) { (task: URLSessionDataTask?, err: Error) in
            failture(err)
        }
    }
    
    func currentAcount(_ success: @escaping (User) -> Void, failture: @escaping (Error) -> Void) {
        get("1.1/account/verify_credentials.json", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            let userDictionary = response as! NSDictionary
            let user = User(dictionary: userDictionary)
            success(user)
            }, failure: { (task: URLSessionDataTask?, err: Error) in
                failture(err)
        })

    }
    
    func handleUrl(_ url: URL) {
        let requestToken = BDBOAuth1Credential(queryString: url.query)
        fetchAccessToken(withPath: "oauth/access_token", method: "POST", requestToken: requestToken, success: { (accessToken: BDBOAuth1Credential!) in
            self.currentAcount({ (user: User) in
                User.currentUser = user
                self.loginSuccess?()
            }, failture: { (err: Error) in
                self.loginFailture?(err)
            })
        }) { (err: Error!) in
            print(err.localizedDescription)
            self.loginFailture?(err)
        }

    }
    
    func newTweet(_ text: String, success: @escaping (Tweet?) -> Void, failure: @escaping (Error) -> Void) {
        var parameter: [String: AnyObject] = [:]
        parameter["status"] = text as AnyObject?
        post("1.1/statuses/update.json", parameters: parameter, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            let dictionary = response as! NSDictionary
            let tweet = Tweet(dictionary: dictionary)
            success(tweet)
        }) { (task: URLSessionDataTask?, err: Error) in
            failure(err)
        }
    }
    
    func retweet(_ id: String, success: @escaping (Tweet?) -> Void, failure: @escaping (Error) -> Void) {
        post("1.1/statuses/retweet/\(id).json", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            let dictionary = response as! NSDictionary
            let tweet = Tweet(dictionary: dictionary)
            success(tweet)
        }) { (task: URLSessionDataTask?, err: Error) in
            failure(err)
        }
    }
    
    func favorite(_ id: String, success: @escaping (Tweet?) -> Void, failure: @escaping (Error) -> Void) {
        var parameter: [String: AnyObject] = [:]
        parameter["id"] = id as AnyObject?
        post("1.1/favorites/create.json", parameters: parameter, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            let dictionary = response as! NSDictionary
            let tweet = Tweet(dictionary: dictionary)
            success(tweet)
        }) { (task: URLSessionDataTask?, err: Error) in
            failure(err)
        }
    }
    
    func unRetweet(_ id: String, success: @escaping (Tweet?) -> Void, failure: @escaping (Error) -> Void) {
        post("1.1/statuses/unretweet/\(id).json", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            let dictionary = response as! NSDictionary
            let tweet = Tweet(dictionary: dictionary)
            success(tweet)
        }) { (task: URLSessionDataTask?, err: Error) in
            failure(err)
        }
    }
    
    func unFavorite(_ id: String, success: @escaping (Tweet?) -> Void, failure: @escaping (Error) -> Void) {
        var parameter: [String: AnyObject] = [:]
        parameter["id"] = id as AnyObject?
        post("1.1/favorites/destroy.json", parameters: parameter, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            let dictionary = response as! NSDictionary
            let tweet = Tweet(dictionary: dictionary)
            success(tweet)
        }) { (task: URLSessionDataTask?, err: Error) in
            failure(err)
        }
    }
    
    func replyToTweet(_ text: String, toId: String, success: @escaping (Tweet?) -> Void, failure: @escaping (Error) -> Void) {
        var parameter: [String: Any] = [:]
        parameter["status"] = text as AnyObject?
        parameter["in_reply_to_status_id"] = toId as AnyObject?
        post("1.1/statuses/update.json", parameters: parameter, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            let dictionary = response as! NSDictionary
            let tweet = Tweet(dictionary: dictionary)
            success(tweet)
        }) { (task: URLSessionDataTask?, err: Error) in
            failure(err)
        }
    }
    
    func login(_ success: @escaping () -> Void, failture: @escaping (Error) -> Void) {
        deauthorize()
        loginSuccess = success
        loginFailture = failture
        fetchRequestToken(withPath: "oauth/request_token", method: "GET", callbackURL: URL(string: "twitterDemo://oauth"), scope: nil, success: { (requestToken: BDBOAuth1Credential!) in
            
            let token = requestToken.token
            let requestString = "https://api.twitter.com/oauth/authorize?oauth_token=\(token!)"
            
            let urr = URL(string: requestString)
            
            
            
            
            UIApplication.shared.openURL(urr!)
        }) { (err: Error!) in
            print(err.localizedDescription)
        }
    }
    
    func logout() {
        User.currentUser = nil
        deauthorize()
        NotificationCenter.default.post(name: Notification.Name(rawValue: User.USER_DID_LOGOUT_NOTIFICATION), object: nil)
    }
}



