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
    static let sharedInstance = TwitterClient(baseURL: NSURL(string: "https://api.twitter.com")!
        , consumerKey: "1FWmBO3kyYNZwUEN4YIKuW95B"
        , consumerSecret: "X6PMSVywL5wPSTIOhgL1zG1k6HPYfO1Y9gg3DwTgPUz69SvtOZ")
    
    var loginSuccess: (() -> Void)?
    var loginFailture: ((NSError) -> Void)?
    
    func homeTimeline(success: ([Tweet]) -> Void, failture: (NSError) -> Void) {
        GET("1.1/statuses/home_timeline.json", parameters: nil, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) in
            let dictionaries = response as! [NSDictionary]
            print(dictionaries)
            let tweets = Tweet.TweetsFromArray(dictionaries)
            success(tweets)
            }, failure: { (task: NSURLSessionDataTask?, err: NSError) in
                failture(err)
        })
    }
    
    func userTimeline(success: ([Tweet]) -> Void, failture: (NSError) -> Void) {
        GET("1.1/statuses/user_timeline.json", parameters: nil, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) in
            let dictionaries = response as! [NSDictionary]
            let tweets = Tweet.TweetsFromArray(dictionaries)
            success(tweets)
            }, failure: { (task: NSURLSessionDataTask?, err: NSError) in
                failture(err)
        })
    }
    
    func currentAcount(success: (User) -> Void, failture: (NSError) -> Void) {
        GET("1.1/account/verify_credentials.json", parameters: nil, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) in
            let userDictionary = response as! NSDictionary
            let user = User(dictionary: userDictionary)
            success(user)
            }, failure: { (task: NSURLSessionDataTask?, err: NSError) in
                failture(err)
        })

    }
    
    func handleUrl(url: NSURL) {
        let requestToken = BDBOAuth1Credential(queryString: url.query)
        fetchAccessTokenWithPath("oauth/access_token", method: "POST", requestToken: requestToken, success: { (accessToken: BDBOAuth1Credential!) in
            self.currentAcount({ (user: User) in
                User.currentUser = user
                self.loginSuccess?()
            }, failture: { (err: NSError) in
                self.loginFailture?(err)
            })
        }) { (err: NSError!) in
            print(err.localizedDescription)
            self.loginFailture?(err)
        }

    }
    
    func newTweet(text: String, success: (Tweet?) -> Void, failure: (NSError) -> Void) {
        var parameter: [String: AnyObject] = [:]
        parameter["status"] = text
        POST("1.1/statuses/update.json", parameters: parameter, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) in
            let dictionary = response as! NSDictionary
            let tweet = Tweet(dictionary: dictionary)
            success(tweet)
        }) { (task: NSURLSessionDataTask?, err: NSError) in
            failure(err)
        }
    }
    
    func retweet(id: String, success: (Tweet?) -> Void, failure: (NSError) -> Void) {
        POST("1.1/statuses/retweet/\(id).json", parameters: nil, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) in
            let dictionary = response as! NSDictionary
            let tweet = Tweet(dictionary: dictionary)
            success(tweet)
        }) { (task: NSURLSessionDataTask?, err: NSError) in
            failure(err)
        }
    }
    
    func favorite(id: String, success: (Tweet?) -> Void, failure: (NSError) -> Void) {
        var parameter: [String: AnyObject] = [:]
        parameter["id"] = id
        POST("1.1/favorites/create.json", parameters: parameter, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) in
            let dictionary = response as! NSDictionary
            let tweet = Tweet(dictionary: dictionary)
            success(tweet)
        }) { (task: NSURLSessionDataTask?, err: NSError) in
            failure(err)
        }
    }
    
    func unRetweet(id: String, success: (Tweet?) -> Void, failure: (NSError) -> Void) {
        POST("1.1/statuses/unretweet/\(id).json", parameters: nil, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) in
            let dictionary = response as! NSDictionary
            let tweet = Tweet(dictionary: dictionary)
            success(tweet)
        }) { (task: NSURLSessionDataTask?, err: NSError) in
            failure(err)
        }
    }
    
    func unFavorite(id: String, success: (Tweet?) -> Void, failure: (NSError) -> Void) {
        var parameter: [String: AnyObject] = [:]
        parameter["id"] = id
        POST("1.1/favorites/destroy.json", parameters: parameter, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) in
            let dictionary = response as! NSDictionary
            let tweet = Tweet(dictionary: dictionary)
            success(tweet)
        }) { (task: NSURLSessionDataTask?, err: NSError) in
            failure(err)
        }
    }
    
    func replyToTweet(text: String, toId: String, success: (Tweet?) -> Void, failure: (NSError) -> Void) {
        var parameter: [String: AnyObject] = [:]
        parameter["status"] = text
        parameter["in_reply_to_status_id"] = toId
        POST("1.1/statuses/update.json", parameters: parameter, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) in
            let dictionary = response as! NSDictionary
            let tweet = Tweet(dictionary: dictionary)
            success(tweet)
        }) { (task: NSURLSessionDataTask?, err: NSError) in
            failure(err)
        }
    }
    
    func login(success: () -> Void, failture: (NSError) -> Void) {
        deauthorize()
        loginSuccess = success
        loginFailture = failture
        fetchRequestTokenWithPath("oauth/request_token", method: "GET", callbackURL: NSURL(string: "twitterDemo://oauth"), scope: nil, success: { (requestToken: BDBOAuth1Credential!) in
            let url = NSURL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token)")!
            UIApplication.sharedApplication().openURL(url)
        }) { (err: NSError!) in
            print(err.localizedDescription)
        }
    }
    
    func logout() {
        User.currentUser = nil
        deauthorize()
        NSNotificationCenter.defaultCenter().postNotificationName(User.USER_DID_LOGOUT_NOTIFICATION, object: nil)
    }
}



