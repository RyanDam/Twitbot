//
//  ProfileViewController.swift
//  Twitbot
//
//  Created by Dam Vu Duy on 3/31/16.
//  Copyright © 2016 dotRStudio. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    weak var sideMenuCallback: SideMenuCallback?
    
    @IBOutlet weak var userCoverImage: UIImageView!
    @IBOutlet weak var userAvatarImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var userTweetCount: UILabel!
    @IBOutlet weak var userFollowingCount: UILabel!
    @IBOutlet weak var userFollowerCount: UILabel!
    @IBOutlet weak var mainTweetTableView: UITableView!
    @IBOutlet weak var tableTopConstraint: NSLayoutConstraint!
    
    var dataBrigde: TimelineTableViewController?
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
        self.navigationController?.view.backgroundColor = UIColor.clearColor()
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationItem.titleView?.tintColor = UIColor.whiteColor()
        
        userAvatarImage.setImageWithURL((user?.profileHighUrl)!)
        userAvatarImage.clipsToBounds = true
        userAvatarImage.layer.cornerRadius = userAvatarImage.frame.size.height / 2
        
        usernameLabel.text = user?.name
        
        userCoverImage.setImageWithURL((user?.profileCoverUrl)!)
        
        userFollowerCount.text = "\((user?.followerCount)!)"
        userFollowingCount.text = "\((user?.followingCount)!)"
        userTweetCount.text = "\((user?.favoritesCount)!)"
        
        
        dataBrigde = TimelineTableViewController(tblView: mainTweetTableView, mode: FetchDataMode.ProfileTimeline)
        dataBrigde?.userID = user?.userID
        dataBrigde?.scrollStateChangeDelegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onToggleSideMenuState(sender: UIBarButtonItem) {
        sideMenuCallback?.onToggleSideMenuState()
    }
    
    @IBAction func onBack(sender: UIBarButtonItem) {
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ProfileToProfile" {
            let gesture = sender as! UITapGestureRecognizer
            let cellContentView = gesture.view?.superview?.superview as! UITableViewCell
            
            let indexPath = mainTweetTableView.indexPathForCell(cellContentView)
            
            let targetVC = (segue.destinationViewController as! UINavigationController).viewControllers[0] as! ProfileViewController
            
            targetVC.user = dataBrigde?.tweets![(indexPath?.row)!].user
            targetVC.sideMenuCallback = self.sideMenuCallback
        }
    }
 
}

extension ProfileViewController: ScrollStateChangeDelegate {
    func onScrollChange(sender: UIScrollView) {
//        tableTopConstraint.constant = sender.contentOffset.y
    }
}
