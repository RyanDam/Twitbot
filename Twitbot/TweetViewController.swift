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
                favoriteButton.setImage(UIImage(named: "like-ed"), for: UIControlState())
            }
            else {
                
                favoriteButton.setImage(UIImage(named: "like"), for: UIControlState())
            }
        }
    }
    
    var isUserRetweeted: Bool = false {
        didSet {
            if isUserRetweeted {
                retweetButton.setImage(UIImage(named: "retweeted"), for: UIControlState())
            }
            else {
                retweetButton.setImage(UIImage(named: "retweet"), for: UIControlState())
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
                    let calendar = Calendar.current
                    let comp = (calendar as NSCalendar).components([.day, .month], from: date as Date)
                    timeRet = "\(String(describing: comp.day))\\\(String(describing: comp.month))"
                }
                self.timestamp.text = timeRet
            }
            
            if tweet.isRetweeted {
                self.showRetweetIndicate(name: tweet.user!.name!)
                self.tweetText.text = tweet.sourceTweet!.text
                self.username.text = tweet.sourceTweet!.user!.name
                self.userScreenName.text = "@\(tweet.sourceTweet!.user!.screenName!)"
                if let avatar = tweet.sourceTweet!.user!.profileUrl {
                    self.userAvatar.setImageWith(avatar as URL)
                }
            }
            else {
                self.hideRetweetIndicate()
                self.tweetText.text = tweet.text
                self.username.text = tweet.user!.name
                self.userScreenName.text = "@\(tweet.user!.screenName!)"
                if let avatar = tweet.user!.profileUrl {
                    self.userAvatar.setImageWith(avatar as URL)
                }
            }
            
            self.userAvatar.layer.cornerRadius = 8
            self.isLiked = tweet.isFavourited!
            
            if let medias = tweet.media {
                setImageToPreview(url: medias[0].imageUrl! as URL)
            }
            else {
                noneImage()
            }
        }
    }

    func setImageToPreview(url: URL) {
        imagePreview.setImageWith(url)
        
        imagePreview.setImageWith(URLRequest(url: url), placeholderImage: UIImage(), success: { (request: URLRequest, response: HTTPURLResponse?, img: UIImage) in
            // code
        }) { (request: URLRequest, response: HTTPURLResponse?, err: Error) in
            print(err.localizedDescription)
        }
        
        imagePreview.isHidden = false
        topConstraintReplyButton.constant = 8
    }
    
    func noneImage() {
        imagePreview.isHidden = true
        topConstraintReplyButton.constant = -150
    }
    
    func showRetweetIndicate(name: String) {
        retweetImageIndicate.isHidden = false
        retweetLabelIndicate.isHidden = false
        retweetLabelIndicate.text = "\(name) retweeted:"
        avatarTopConstraint.constant = 16
    }
    
    func hideRetweetIndicate() {
        retweetImageIndicate.isHidden = true
        retweetLabelIndicate.isHidden = true
        avatarTopConstraint.constant = -8
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onBack(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func onReply(_ sender: UIBarButtonItem) {
        
    }
    @IBAction func onReplyButton(_ sender: AnyObject) {
    }
    
    @IBAction func onRetweetButton(_ sender: AnyObject) {
        onTweet()
    }
    
    @IBAction func onFavoriteButton(_ sender: AnyObject) {
        onLike()
    }
    
    func onShare() {
        
    }
    func onTweet() {
        let sender = self
        let tweet = self.tweet
        if !tweet!.isUserRetweeted! {
            TwitterClient.sharedInstance?.retweet(tweet!.idStr!, success: { (tweeted: Tweet?) in
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
                }, failure: { (err: Error) in
                    print(err.localizedDescription)
            })
        }
        else {
            TwitterClient.sharedInstance?.unRetweet(tweet!.idStr!, success: { (tweeted: Tweet?) in
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
                }, failure: { (err: Error) in
                    print(err.localizedDescription)
            })
        }
        
    }
    func onLike() {
        let sender = self
        let tweet = self.tweet!
        if !tweet.isFavourited! {
            TwitterClient.sharedInstance?.favorite(tweet.idStr!, success: { (tweeted: Tweet?) in
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
                }, failure: { (err: Error) in
                    print(err.localizedDescription)
            })
        }
        else {
            TwitterClient.sharedInstance?.unFavorite(tweet.idStr!, success: { (tweeted: Tweet?) in
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
                }, failure: { (err: Error) in
                    print(err.localizedDescription)
            })
        }
    }

}
