//
//  TimelineTableViewController.swift
//  Twitbot
//
//  Created by Dam Vu Duy on 3/31/16.
//  Copyright © 2016 dotRStudio. All rights reserved.
//

import UIKit
//import SwiftLoader

enum FetchDataMode {
    case homeTimeline
    case profileTimeline
    case mentionTimeline
}

protocol ScrollStateChangeDelegate: NSObjectProtocol {
    func onScrollChange(_ sender: UIScrollView)
}

class TimelineTableViewController: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    var isMoreDataLoading = false
    
    var tweets: [Tweet]?
    var mainTableView: UITableView = UITableView()
    
    var timelineMode: FetchDataMode = .homeTimeline
    
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
        refreshControl.addTarget(self, action: #selector(TimelineTableViewController.refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        mainTableView.insertSubview(refreshControl, at: 0)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath) as! TweetTableViewCell
        
        let tweet = tweets![(indexPath as NSIndexPath).row]
        
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
                let calendar = Calendar.current
                let comp = (calendar as NSCalendar).components([.day, .month, .year], from: date as Date)
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
                cell.avatar.setImageWith(avatar as URL)
            }
        }
        else {
            cell.hideRetweetIndicate()
            cell.tweetText.text = tweet.text
            cell.username.text = tweet.user!.name
            cell.userScreenName.text = "@\(tweet.user!.screenName!)"
            if let avatar = tweet.user!.profileUrl {
                cell.avatar.setImageWith(avatar as URL)
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension TimelineTableViewController: TweetTableViewCellDelegate {
    func onShare(_ sender: TweetTableViewCell) {
        
    }
    func onTweet(_ sender: TweetTableViewCell) {
        let indexPath = mainTableView.indexPath(for: sender)
        if let index = indexPath {
            let tweet = self.tweets![(index as NSIndexPath).row]
            if !tweet.isRetweeted {
                TwitterClient.sharedInstance?.retweet(tweet.idStr!, success: { (tweeted: Tweet?) in
                    let tweet = self.tweets![(index as NSIndexPath).row]
                    tweet.retweetCount += 1
                    if tweet.retweetCount > 2000 {
                        sender.retweetCount.text = "\(Int(tweet.retweetCount/1000))K"
                    }
                    else {
                        sender.retweetCount.text = "\(Int(tweet.retweetCount))"
                    }
                    sender.isRetweeted = !sender.isRetweeted
                    self.tweets![(index as NSIndexPath).row].isUserRetweeted = sender.isRetweeted
                    }, failure: { (err: Error) in
                        print(err.localizedDescription)
                })
            }
            else {
                TwitterClient.sharedInstance?.unRetweet(tweet.idStr!, success: { (tweeted: Tweet?) in
                    let tweet = self.tweets![(index as NSIndexPath).row]
                    tweet.retweetCount -= 1
                    if tweet.retweetCount > 2000 {
                        sender.retweetCount.text = "\(Int(tweet.retweetCount/1000))K"
                    }
                    else {
                        sender.retweetCount.text = "\(Int(tweet.retweetCount))"
                    }
                    sender.isRetweeted = !sender.isRetweeted
                    self.tweets![(index as NSIndexPath).row].isUserRetweeted = sender.isRetweeted
                    }, failure: { (err: Error) in
                        print(err.localizedDescription)
                })
            }
        }
    }
    func onLike(_ sender: TweetTableViewCell) {
        let indexPath = mainTableView.indexPath(for: sender)
        if let index = indexPath {
            let tweet = self.tweets![(index as NSIndexPath).row]
            if !tweet.isFavourited! {
                TwitterClient.sharedInstance?.favorite(tweet.idStr!, success: { (tweeted: Tweet?) in
                    let tweet = self.tweets![(index as NSIndexPath).row]
                    tweet.favoritesCount += 1
                    if tweet.favoritesCount > 2000 {
                        sender.likeCount.text = "\(Int(tweet.favoritesCount/1000))K"
                    }
                    else {
                        sender.likeCount.text = "\(Int(tweet.favoritesCount))"
                    }
                    sender.isLiked = !sender.isLiked
                    self.tweets![(index as NSIndexPath).row].isFavourited = sender.isLiked
                    }, failure: { (err: Error) in
                        print(err.localizedDescription)
                })
            }
            else {
                TwitterClient.sharedInstance?.unFavorite(tweet.idStr!, success: { (tweeted: Tweet?) in
                    let tweet = self.tweets![(index as NSIndexPath).row]
                    tweet.favoritesCount -= 1
                    if tweet.favoritesCount > 2000 {
                        sender.likeCount.text = "\(Int(tweet.favoritesCount/1000))K"
                    }
                    else {
                        sender.likeCount.text = "\(Int(tweet.favoritesCount))"
                    }
                    sender.isLiked = !sender.isLiked
                    self.tweets![(index as NSIndexPath).row].isFavourited = sender.isLiked
                    }, failure: { (err: Error) in
                        print(err.localizedDescription)
                })
            }
        }
    }
}

extension TimelineTableViewController: UIScrollViewDelegate {
    func fetchDataTimeline() {
        showWaitingIndicate()
        if timelineMode == .homeTimeline {
            TwitterClient.sharedInstance?.homeTimeline({ (tweets: [Tweet]) in
                self.tweets = tweets
                self.mainTableView.reloadData()
                self.hideWaitingIndicate()
                self.isMoreDataLoading = false
            }) { (err: Error) in
                self.showErrorIndicate()
                print("Err")
                print(err.localizedDescription)
                self.isMoreDataLoading = false
            }
        }
        else if timelineMode == .mentionTimeline {
            TwitterClient.sharedInstance?.mentionTimeline({ (tweets: [Tweet]) in
                self.tweets = tweets
                self.mainTableView.reloadData()
                self.hideWaitingIndicate()
                self.isMoreDataLoading = false
            }) { (err: Error) in
                self.showErrorIndicate()
                print("Err")
                print(err.localizedDescription)
                self.isMoreDataLoading = false
            }
        }
        else if timelineMode == .profileTimeline {
            
            if let userID = userID {
                TwitterClient.sharedInstance?.userTimeline(withId: userID,success: { (tweets: [Tweet]) in
                    self.tweets = tweets
                    self.mainTableView.reloadData()
                    self.hideWaitingIndicate()
                    self.isMoreDataLoading = false
                }) { (err: Error) in
                    self.showErrorIndicate()
                    print("Err")
                    print(err.localizedDescription)
                    self.isMoreDataLoading = false
                }
            }
            else {
                TwitterClient.sharedInstance?.userTimeline({ (tweets: [Tweet]) in
                    self.tweets = tweets
                    self.mainTableView.reloadData()
                    self.hideWaitingIndicate()
                    self.isMoreDataLoading = false
                }) { (err: Error) in
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
        if timelineMode == .homeTimeline {
            TwitterClient.sharedInstance?.homeTimeline({ (tweets: [Tweet]) in
                self.tweets = tweets
                self.mainTableView.reloadData()
                self.hideWaitingIndicate()
                self.isMoreDataLoading = false
            }) { (err: Error) in
                self.showErrorIndicate()
                print("Err")
                print(err.localizedDescription)
                self.isMoreDataLoading = false
            }
        }
        else if timelineMode == .mentionTimeline {
            TwitterClient.sharedInstance?.mentionTimeline({ (tweets: [Tweet]) in
                self.tweets = tweets
                self.mainTableView.reloadData()
                self.hideWaitingIndicate()
                self.isMoreDataLoading = false
            }) { (err: Error) in
                self.showErrorIndicate()
                print("Err")
                print(err.localizedDescription)
                self.isMoreDataLoading = false
            }
        }
        else if timelineMode == .profileTimeline {
            if let userID = userID {
                TwitterClient.sharedInstance?.userTimeline(withId: userID,success: { (tweets: [Tweet]) in
                    self.tweets = tweets
                    self.mainTableView.reloadData()
                    self.hideWaitingIndicate()
                    self.isMoreDataLoading = false
                }) { (err: Error) in
                    self.showErrorIndicate()
                    print("Err")
                    print(err.localizedDescription)
                    self.isMoreDataLoading = false
                }
            }
            else {
                TwitterClient.sharedInstance?.userTimeline({ (tweets: [Tweet]) in
                    self.tweets = tweets
                    self.mainTableView.reloadData()
                    self.hideWaitingIndicate()
                    self.isMoreDataLoading = false
                }) { (err: Error) in
                    self.showErrorIndicate()
                    print("Err")
                    print(err.localizedDescription)
                    self.isMoreDataLoading = false
                }
            }
        }
    }
    
    func showWaitingIndicate() {
//        SwiftLoader.show(title: "Loading...", animated: true)
    
        hideErrorIndicate()
    }
    
    func hideWaitingIndicate() {
//        SwiftLoader.hide()
        refreshControl.endRefreshing()
    }
    
    func showErrorIndicate() {
        hideWaitingIndicate()
    }
    
    func hideErrorIndicate() {
        
    }
    
    // MARK: Refresh controll
    
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        fetchDataTimeline()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        scrollStateChangeDelegate?.onScrollChange(scrollView)
        
        if (!isMoreDataLoading) {
            let scrollViewContentHeight = mainTableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - mainTableView.bounds.size.height
            if(scrollView.contentOffset.y > scrollOffsetThreshold && mainTableView.isDragging) {
                isMoreDataLoading = true
                fetchDataTimeline()
            }
        }
    }
}


