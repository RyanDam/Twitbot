 //
//  Tweet.swift
//  Twitbot
//
//  Created by Dam Vu Duy on 3/24/16.
//  Copyright © 2016 dotRStudio. All rights reserved.
//

import UIKit

class Tweet: NSObject {
    var idStr: String?
    var text: String?
    var timestamp: NSDate?
    var retweetCount: Int = 0
    var favoritesCount: Int = 0
    var user: User?
    var isFavourited: Bool? = false
    var isUserRetweeted: Bool? = false
    var isRetweeted: Bool = false
    var sourceTweet: Tweet?
    var media: [Media]?
    
    
    init(dictionary: NSDictionary) {
        text = dictionary["text"] as? String
        retweetCount = (dictionary["retweet_count"] as? Int) ?? 0
        favoritesCount = (dictionary["favorite_count"] as? Int) ?? 0
        user = User(dictionary: dictionary["user"] as! NSDictionary)
        isFavourited = dictionary["favorited"] as? Bool
        idStr = dictionary["id_str"] as? String
        isUserRetweeted = dictionary["retweeted"] as? Bool
        
        if let entities = dictionary["entities"] as? NSDictionary {
            if let medias = entities["media"] as? [NSDictionary] {
                self.media = [Media]()
                for media in medias {
                    self.media?.append(Media(dictionary: media))
                }
            }
        }
        
        if let dic = dictionary["retweeted_status"] as? NSDictionary {
            isRetweeted = true
            sourceTweet = Tweet(dictionary: dic)
        }
        let timestampString = dictionary["created_at"] as? String
        let dataFormater = NSDateFormatter()
        dataFormater.dateFormat = "EEE MMM d HH:mm:ss Z y"
        if let timestampString = timestampString {
            timestamp = dataFormater.dateFromString(timestampString)
        }
    }
    
    class func TweetsFromArray(dictionaries: [NSDictionary]) -> [Tweet] {
        var tweets: [Tweet] = []
        for dictionary in dictionaries {
            tweets.append(Tweet(dictionary: dictionary))
        }
        return tweets
    }
}
