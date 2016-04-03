//
//  TweetViewController.swift
//  Twitbot
//
//  Created by Dam Vu Duy on 3/25/16.
//  Copyright © 2016 dotRStudio. All rights reserved.
//

import UIKit

class TweetViewController: UIViewController {
    
    @IBOutlet weak var avatarTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var retweetLabelIndicate: UILabel!
    @IBOutlet weak var retweetImageIndicate: UIImageView!
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var topConstraintReplyButton: NSLayoutConstraint!
    
    @IBOutlet weak var imagePreview: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var userScreenName: UILabel!
    @IBOutlet weak var timestamp: UILabel!
    @IBOutlet weak var tweetText: UILabel!
    @IBOutlet weak var retweetCount: UILabel!
    @IBOutlet weak var favouriteCount: UILabel!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    var isLiked: Bool = false {
        didSet {
            if isLiked {
                favoriteButton.setImage(UIImage(named: "like-ed"), forState: UIControlState.Normal)
            }
            else {
                
                favoriteButton.setImage(UIImage(named: "like"), forState: UIControlState.Normal)
            }
        }
    }
    
    var isUserRetweeted: Bool = false {
        didSet {
            if isUserRetweeted {
                retweetButton.setImage(UIImage(named: "retweeted"), forState: UIControlState.Normal)
            }
            else {
                retweetButton.setImage(UIImage(named: "retweet"), forState: UIControlState.Normal)
            }
        }
    }
    
    var tweet: Tweet?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let logoImageView = UIImageView(image: UIImage(named: "twitter"))
        self.navigationItem.titleView = logoImageView
        
        imagePreview.layer.cornerRadius = 8
        imagePreview.clipsToBounds = true
        if let tweet = self.tweet {
            if tweet.favoritesCount > 2000 {
                self.favouriteCount.text = "\(Int(tweet.favoritesCount/1000))K"
            }
            else {
                self.favouriteCount.text = "\(Int(tweet.favoritesCount))"
            }
            
            if tweet.retweetCount > 2000 {
                self.retweetCount.text = "\(Int(tweet.retweetCount/1000))K"
            }
            else {
                self.retweetCount.text = "\(Int(tweet.retweetCount))"
            }
            
            if let date = tweet.timestamp {
                var timeRet = ""
                let time = -Double(date.timeIntervalSinceNow.description)!
                if Int(time/60) == 0 {
                    timeRet = "\(Int(time))s"
                }
                else if Int(time/(60*60)) == 0 {
                    timeRet = "\(Int(time/60))m"
                }
                else if Int(time/(60*60*24)) == 0{
                    timeRet = "\(Int(time/(60*60)))h"
                }
                else {
                    let calendar = NSCalendar.currentCalendar()
                    let comp = calendar.components([.Day, .Month], fromDate: date)
                    timeRet = "\(comp.day)\\\(comp.month)"
                }
                self.timestamp.text = timeRet
            }
            
            if tweet.isRetweeted {
                self.showRetweetIndicate(tweet.user!.name!)
                self.tweetText.text = tweet.sourceTweet!.text
                self.username.text = tweet.sourceTweet!.user!.name
                self.userScreenName.text = "@\(tweet.sourceTweet!.user!.screenName!)"
                if let avatar = tweet.sourceTweet!.user!.profileUrl {
                    self.userAvatar.setImageWithURL(avatar)
                }
            }
            else {
                self.hideRetweetIndicate()
                self.tweetText.text = tweet.text
                self.username.text = tweet.user!.name
                self.userScreenName.text = "@\(tweet.user!.screenName!)"
                if let avatar = tweet.user!.profileUrl {
                    self.userAvatar.setImageWithURL(avatar)
                }
            }
            
            self.userAvatar.layer.cornerRadius = 8
            self.isLiked = tweet.isFavourited!
            
            if let medias = tweet.media {
                setImageToPreview(medias[0].imageUrl!)
            }
            else {
                noneImage()
            }
        }
    }

    func setImageToPreview(url: NSURL) {
        imagePreview.setImageWithURL(url)
        imagePreview.setImageWithURLRequest(NSURLRequest(URL: url), placeholderImage: UIImage(), success: { (request: NSURLRequest, response: NSHTTPURLResponse?, img: UIImage) in
            // code
        }) { (request: NSURLRequest, response: NSHTTPURLResponse?, err: NSError) in
            print(err.localizedDescription)
        }
        imagePreview.hidden = false
        topConstraintReplyButton.constant = 8
    }
    
    func noneImage() {
        imagePreview.hidden = true
        topConstraintReplyButton.constant = -150
    }
    
    func showRetweetIndicate(name: String) {
        retweetImageIndicate.hidden = false
        retweetLabelIndicate.hidden = false
        retweetLabelIndicate.text = "\(name) retweeted:"
        avatarTopConstraint.constant = 16
    }
    
    func hideRetweetIndicate() {
        retweetImageIndicate.hidden = true
        retweetLabelIndicate.hidden = true
        avatarTopConstraint.constant = -8
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onBack(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func onReply(sender: UIBarButtonItem) {
        
    }
    @IBAction func onReplyButton(sender: AnyObject) {
    }
    
    @IBAction func onRetweetButton(sender: AnyObject) {
        onTweet()
    }
    
    @IBAction func onFavoriteButton(sender: AnyObject) {
        onLike()
    }
    
    func onShare() {
        
    }
    func onTweet() {
        let sender = self
        let tweet = self.tweet
        if !tweet!.isUserRetweeted! {
            TwitterClient.sharedInstance.retweet(tweet!.idStr!, success: { (tweeted: Tweet?) in
                let tweet = self.tweet
                tweet!.retweetCount += 1
                if tweet!.retweetCount > 2000 {
                    sender.retweetCount.text = "\(Int(tweet!.retweetCount/1000))K"
                }
                else {
                    sender.retweetCount.text = "\(Int(tweet!.retweetCount))"
                }
                sender.tweet!.isUserRetweeted = !sender.tweet!.isUserRetweeted!
                sender.isUserRetweeted = !sender.isUserRetweeted
                }, failure: { (err: NSError) in
                    print(err.localizedDescription)
            })
        }
        else {
            TwitterClient.sharedInstance.unRetweet(tweet!.idStr!, success: { (tweeted: Tweet?) in
                let tweet = self.tweet
                tweet!.retweetCount -= 1
                if tweet!.retweetCount > 2000 {
                    sender.retweetCount.text = "\(Int(tweet!.retweetCount/1000))K"
                }
                else {
                    sender.retweetCount.text = "\(Int(tweet!.retweetCount))"
                }
                sender.tweet!.isUserRetweeted = !sender.tweet!.isUserRetweeted!
                sender.isUserRetweeted = !sender.isUserRetweeted
                }, failure: { (err: NSError) in
                    print(err.localizedDescription)
            })
        }
        
    }
    func onLike() {
        let sender = self
        let tweet = self.tweet!
        if !tweet.isFavourited! {
            TwitterClient.sharedInstance.favorite(tweet.idStr!, success: { (tweeted: Tweet?) in
                let tweet = self.tweet!
                tweet.favoritesCount += 1
                if tweet.favoritesCount > 2000 {
                    sender.favouriteCount.text = "\(Int(tweet.favoritesCount/1000))K"
                }
                else {
                    sender.favouriteCount.text = "\(Int(tweet.favoritesCount))"
                }
                sender.isLiked = !sender.isLiked
                tweet.isFavourited = sender.isLiked
                }, failure: { (err: NSError) in
                    print(err.localizedDescription)
            })
        }
        else {
            TwitterClient.sharedInstance.unFavorite(tweet.idStr!, success: { (tweeted: Tweet?) in
                let tweet = self.tweet!
                tweet.favoritesCount -= 1
                if tweet.favoritesCount > 2000 {
                    sender.favouriteCount.text = "\(Int(tweet.favoritesCount/1000))K"
                }
                else {
                    sender.favouriteCount.text = "\(Int(tweet.favoritesCount))"
                }
                sender.isLiked = !sender.isLiked
                tweet.isFavourited = sender.isLiked
                }, failure: { (err: NSError) in
                    print(err.localizedDescription)
            })
        }
    }

}
