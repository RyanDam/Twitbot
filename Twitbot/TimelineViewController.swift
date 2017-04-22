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
    
    var timelineMode: FetchDataMode = FetchDataMode.homeTimeline
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.statusBarStyle = .default
    }

    @IBAction func onLogout(_ sender: UIBarButtonItem) {
        sideMenuCallback?.onToggleSideMenuState()
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ViewTweet" {
            let cell = sender as! TweetTableViewCell
            let indexPath = mainTableView.indexPath(for: cell)!
            let tweet = self.dataBridge!.tweets![(indexPath as NSIndexPath).row]
            let targetView = (segue.destination as! UINavigationController).viewControllers[0] as! TweetViewController
            targetView.tweet = tweet
        }
        else if segue.identifier == "NewTweet" {
            
        }
    }
 
    @IBAction func onSaveUnwind(_ segue: UIStoryboardSegue) {
        let source = segue.source as! NewTweetViewController
        let text = source.inputWord.text
        if (text?.characters.count)! > 0 {
            
            TwitterClient.sharedInstance?.newTweet(text!, success: { (tweet: Tweet?) in
                if let tweet = tweet {
                    self.dataBridge!.tweets?.insert(tweet, at: 0)
                    self.mainTableView.reloadData()
                }
            }, failure: { (err: Error) in
                print(err.localizedDescription)
            })
        }
    }
    
    @IBAction func onCancelUnwind(segue: UIStoryboardSegue) {
        
    }

}
