//
//  TimelineViewController.swift
//  Twitbot
//
//  Created by Dam Vu Duy on 3/24/16.
//  Copyright © 2016 dotRStudio. All rights reserved.
//

import UIKit
import SwiftLoader

class TimelineViewController: UIViewController {

    weak var sideMenuCallback: SideMenuCallback?
    
    @IBOutlet weak var mainTableView: UITableView!
    
    let refreshControl = UIRefreshControl()
    
    var dataBridge: TimelineTableViewController?
    
    var timelineMode: FetchDataMode = FetchDataMode.HomeTimeline
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataBridge = TimelineTableViewController(tblView: mainTableView, mode: timelineMode)
        let logoImageView = UIImageView(image: UIImage(named: "twitter"))
        self.navigationItem.titleView = logoImageView
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
        sideMenuCallback?.onToggleSideMenuState()
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ViewTweet" {
            let cell = sender as! TweetTableViewCell
            let indexPath = mainTableView.indexPathForCell(cell)!
            let tweet = self.dataBridge!.tweets![indexPath.row]
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
                    self.dataBridge!.tweets?.insert(tweet, atIndex: 0)
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