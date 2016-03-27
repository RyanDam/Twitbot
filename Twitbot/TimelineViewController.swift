//
//  TimelineViewController.swift
//  Twitbot
//
//  Created by Dam Vu Duy on 3/24/16.
//  Copyright © 2016 dotRStudio. All rights reserved.
//

import UIKit
import SwiftLoader

class TimelineViewController: UIViewController, UIScrollViewDelegate {

    var tweets: [Tweet]?
    
    @IBOutlet weak var mainTableView: UITableView!
    
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainTableView.delegate = self
        mainTableView.dataSource = self
        mainTableView.estimatedRowHeight = 100
        mainTableView.rowHeight = UITableViewAutomaticDimension
        fetchDataTimeline()
        
        refreshControl.addTarget(self, action: #selector(TimelineViewController.refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        mainTableView.insertSubview(refreshControl, atIndex: 0)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.sharedApplication().statusBarStyle = .Default
    }

    @IBAction func onLogout(sender: UIBarButtonItem) {
        TwitterClient.sharedInstance.logout()
    }
    
    func fetchDataTimeline() {
        showWaitingIndicate()
        TwitterClient.sharedInstance.homeTimeline({ (tweets: [Tweet]) in
            self.tweets = tweets
            self.mainTableView.reloadData()
            self.hideWaitingIndicate()
            self.isMoreDataLoading = false
        }) { (err: NSError) in
            self.showErrorIndicate()
            print("Err")
            print(err.localizedDescription)
            self.isMoreDataLoading = false
        }
    }
    
    func fetchMoreData() {
        showWaitingIndicate()
        TwitterClient.sharedInstance.homeTimeline({ (tweets: [Tweet]) in
            self.tweets = tweets
            self.mainTableView.reloadData()
            self.hideWaitingIndicate()
            self.isMoreDataLoading = false
        }) { (err: NSError) in
            self.showErrorIndicate()
            print("Err")
            print(err.localizedDescription)
            self.isMoreDataLoading = false
        }
    }
    
    func showWaitingIndicate() {
        SwiftLoader.show(title: "Loading...", animated: true)
        hideErrorIndicate()
    }
    
    func hideWaitingIndicate() {
        SwiftLoader.hide()
        refreshControl.endRefreshing()
    }
    
    func showErrorIndicate() {
        hideWaitingIndicate()
    }
    
    func hideErrorIndicate() {
        
    }
    
    // MARK: Refresh controll
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        fetchDataTimeline()
    }
    
    var isMoreDataLoading = false
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            let scrollViewContentHeight = mainTableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - mainTableView.bounds.size.height
            if(scrollView.contentOffset.y > scrollOffsetThreshold && mainTableView.dragging) {
                isMoreDataLoading = true
                fetchDataTimeline()
            }
        }
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ViewTweet" {
            let cell = sender as! TweetTableViewCell
            let indexPath = mainTableView.indexPathForCell(cell)!
            let tweet = self.tweets![indexPath.row]
            let targetView = (segue.destinationViewController as! UINavigationController).viewControllers[0] as! TweetViewController
            targetView.tweet = tweet
        }
        else if segue.identifier == "NewTweet" {
            
        }
    }
 
    @IBAction func onSaveUnwind(segue: UIStoryboardSegue) {
        let source = segue.sourceViewController as! NewTweetViewController
        let text = source.inputWord.text
        if text.characters.count > 0 {
            TwitterClient.sharedInstance.newTweet(text, success: { (tweet: Tweet?) in
                if let tweet = tweet {
                    self.tweets?.insert(tweet, atIndex: 0)
                    self.mainTableView.reloadData()
                }
            }) { (err: NSError) in
                print(err.localizedDescription)
            }
        }
    }
    
    @IBAction func onCancelUnwind(segue: UIStoryboardSegue) {
        
    }

}

extension TimelineViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TweetCell", forIndexPath: indexPath) as! TweetTableViewCell
        
        let tweet = tweets![indexPath.row]
        
        if let medias = tweet.media {
            cell.setImageToPreview(medias[0].imageUrl!)
        }
        else {
            cell.noneImage()
        }
        
        if tweet.favoritesCount > 2000 {
            cell.likeCount.text = "\(Int(tweet.favoritesCount/1000))K"
        }
        else {
            cell.likeCount.text = "\(Int(tweet.favoritesCount))"
        }
        
        if tweet.retweetCount > 2000 {
            cell.retweetCount.text = "\(Int(tweet.retweetCount/1000))K"
        }
        else {
            cell.retweetCount.text = "\(Int(tweet.retweetCount))"
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
            cell.timestamp.text = timeRet
        }
        
        if tweet.isRetweeted {
            cell.showRetweetIndicate(tweet.user!.name!)
            cell.tweetText.text = tweet.sourceTweet!.text
            cell.username.text = tweet.sourceTweet!.user!.name
            cell.userScreenName.text = "@\(tweet.sourceTweet!.user!.screenName!)"
            if let avatar = tweet.sourceTweet!.user!.profileUrl {
                cell.avatar.setImageWithURL(avatar)
            }
        }
        else {
            cell.hideRetweetIndicate()
            cell.tweetText.text = tweet.text
            cell.username.text = tweet.user!.name
            cell.userScreenName.text = "@\(tweet.user!.screenName!)"
            if let avatar = tweet.user!.profileUrl {
                cell.avatar.setImageWithURL(avatar)
            }
        }
        
        cell.avatar.layer.cornerRadius = 8
        cell.delegate = self
        cell.isLiked = tweet.isFavourited!
        cell.isRetweeted = tweet.isUserRetweeted!
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

extension TimelineViewController: TweetTableViewCellDelegate {
    func onShare(sender: TweetTableViewCell) {
        
    }
    func onTweet(sender: TweetTableViewCell) {
        let indexPath = mainTableView.indexPathForCell(sender)
        if let index = indexPath {
            let tweet = self.tweets![index.row]
            if !tweet.isRetweeted {
                TwitterClient.sharedInstance.retweet(tweet.idStr!, success: { (tweeted: Tweet?) in
                    let tweet = self.tweets![index.row]
                    tweet.retweetCount += 1
                    if tweet.retweetCount > 2000 {
                        sender.retweetCount.text = "\(Int(tweet.retweetCount/1000))K"
                    }
                    else {
                        sender.retweetCount.text = "\(Int(tweet.retweetCount))"
                    }
                    sender.isRetweeted = !sender.isRetweeted
                    self.tweets![index.row].isUserRetweeted = sender.isRetweeted
                    }, failure: { (err: NSError) in
                        print(err.localizedDescription)
                })
            }
            else {
                TwitterClient.sharedInstance.unRetweet(tweet.idStr!, success: { (tweeted: Tweet?) in
                    let tweet = self.tweets![index.row]
                    tweet.retweetCount -= 1
                    if tweet.retweetCount > 2000 {
                        sender.retweetCount.text = "\(Int(tweet.retweetCount/1000))K"
                    }
                    else {
                        sender.retweetCount.text = "\(Int(tweet.retweetCount))"
                    }
                    sender.isRetweeted = !sender.isRetweeted
                    self.tweets![index.row].isUserRetweeted = sender.isRetweeted
                    }, failure: { (err: NSError) in
                        print(err.localizedDescription)
                })
            }
        }
    }
    func onLike(sender: TweetTableViewCell) {
        let indexPath = mainTableView.indexPathForCell(sender)
        if let index = indexPath {
            let tweet = self.tweets![index.row]
            if !tweet.isFavourited! {
                TwitterClient.sharedInstance.favorite(tweet.idStr!, success: { (tweeted: Tweet?) in
                    let tweet = self.tweets![index.row]
                    tweet.favoritesCount += 1
                    if tweet.favoritesCount > 2000 {
                        sender.likeCount.text = "\(Int(tweet.favoritesCount/1000))K"
                    }
                    else {
                        sender.likeCount.text = "\(Int(tweet.favoritesCount))"
                    }
                    sender.isLiked = !sender.isLiked
                    self.tweets![index.row].isFavourited = sender.isLiked
                }, failure: { (err: NSError) in
                    print(err.localizedDescription)
                })
            }
            else {
                TwitterClient.sharedInstance.unFavorite(tweet.idStr!, success: { (tweeted: Tweet?) in
                    let tweet = self.tweets![index.row]
                    tweet.favoritesCount -= 1
                    if tweet.favoritesCount > 2000 {
                        sender.likeCount.text = "\(Int(tweet.favoritesCount/1000))K"
                    }
                    else {
                        sender.likeCount.text = "\(Int(tweet.favoritesCount))"
                    }
                    sender.isLiked = !sender.isLiked
                    self.tweets![index.row].isFavourited = sender.isLiked
                    }, failure: { (err: NSError) in
                        print(err.localizedDescription)
                })
            }
        }
    }
}