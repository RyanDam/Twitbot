//
//  TimelineTableViewController.swift
//  Twitbot
//
//  Created by Dam Vu Duy on 3/31/16.
//  Copyright © 2016 dotRStudio. All rights reserved.
//

import UIKit
import SwiftLoader

enum FetchDataMode {
    case HomeTimeline
    case ProfileTimeline
    case MentionTimeline
}

protocol ScrollStateChangeDelegate: NSObjectProtocol {
    func onScrollChange(sender: UIScrollView)
}

class TimelineTableViewController: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    var isMoreDataLoading = false
    
    var tweets: [Tweet]?
    var mainTableView: UITableView = UITableView()
    
    var timelineMode: FetchDataMode = .HomeTimeline
    
    var scrollStateChangeDelegate: ScrollStateChangeDelegate?
    
    let refreshControl = UIRefreshControl()
    
    var userID: String?
    
    init(tblView: UITableView, mode: FetchDataMode) {
        super.init()
        mainTableView = tblView
        tblView.delegate = self
        tblView.dataSource = self
        timelineMode = mode
        fetchDataTimeline()
        mainTableView.estimatedRowHeight = 100
        mainTableView.rowHeight = UITableViewAutomaticDimension
        refreshControl.addTarget(self, action: #selector(TimelineTableViewController.refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        mainTableView.insertSubview(refreshControl, atIndex: 0)
    }
    
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
            else if Int(time/(60*60*24*30)) == 0 {
                timeRet = "\(Int(time/(60*60*24)))d"
            }
            else {
                let calendar = NSCalendar.currentCalendar()
                let comp = calendar.components([.Day, .Month, .Year], fromDate: date)
                timeRet = "\(comp.day)\\\(comp.month)\\\(comp.year)"
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
        cell.imagePreview.layer.cornerRadius = 8
        cell.imagePreview.clipsToBounds = true
        
        cell.layoutIfNeeded()
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}

extension TimelineTableViewController: TweetTableViewCellDelegate {
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

extension TimelineTableViewController: UIScrollViewDelegate {
    func fetchDataTimeline() {
        showWaitingIndicate()
        if timelineMode == .HomeTimeline {
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
        else if timelineMode == .MentionTimeline {
            TwitterClient.sharedInstance.mentionTimeline({ (tweets: [Tweet]) in
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
        else if timelineMode == .ProfileTimeline {
            
            if let userID = userID {
                TwitterClient.sharedInstance.userTimeline(withId: userID,success: { (tweets: [Tweet]) in
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
            else {
                TwitterClient.sharedInstance.userTimeline({ (tweets: [Tweet]) in
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
        }
    }
    
    func fetchMoreData() {
        showWaitingIndicate()
        if timelineMode == .HomeTimeline {
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
        else if timelineMode == .MentionTimeline {
            TwitterClient.sharedInstance.mentionTimeline({ (tweets: [Tweet]) in
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
        else if timelineMode == .ProfileTimeline {
            if let userID = userID {
                TwitterClient.sharedInstance.userTimeline(withId: userID,success: { (tweets: [Tweet]) in
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
            else {
                TwitterClient.sharedInstance.userTimeline({ (tweets: [Tweet]) in
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
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        scrollStateChangeDelegate?.onScrollChange(scrollView)
        
        if (!isMoreDataLoading) {
            let scrollViewContentHeight = mainTableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - mainTableView.bounds.size.height
            if(scrollView.contentOffset.y > scrollOffsetThreshold && mainTableView.dragging) {
                isMoreDataLoading = true
                fetchDataTimeline()
            }
        }
    }
}


