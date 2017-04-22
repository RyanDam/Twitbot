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
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationItem.titleView?.tintColor = UIColor.white
        
        userAvatarImage.setImageWith((user?.profileHighUrl)! as URL)
        userAvatarImage.clipsToBounds = true
        userAvatarImage.layer.cornerRadius = userAvatarImage.frame.size.height / 2
        
        usernameLabel.text = user?.name
        
        userCoverImage.setImageWith((user?.profileCoverUrl)! as URL)
        
        userFollowerCount.text = "\((user?.followerCount)!)"
        userFollowingCount.text = "\((user?.followingCount)!)"
        userTweetCount.text = "\((user?.favoritesCount)!)"
        
        dataBrigde = TimelineTableViewController(tblView: mainTweetTableView, mode: FetchDataMode.profileTimeline)
        dataBrigde?.userID = user?.userID
        dataBrigde?.scrollStateChangeDelegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onToggleSideMenuState(_ sender: UIBarButtonItem) {
        sideMenuCallback?.onToggleSideMenuState()
    }
    
    @IBAction func onBack(_ sender: UIBarButtonItem) {
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ProfileToProfile" {
            let gesture = sender as! UITapGestureRecognizer
            let cellContentView = gesture.view?.superview?.superview as! UITableViewCell
            
            let indexPath = mainTweetTableView.indexPath(for: cellContentView)
            
            let targetVC = (segue.destination as! UINavigationController).viewControllers[0] as! ProfileViewController
            
            targetVC.user = dataBrigde?.tweets![((indexPath as NSIndexPath?)?.row)!].user
            targetVC.sideMenuCallback = self.sideMenuCallback
        }
    }
 
}

extension ProfileViewController: ScrollStateChangeDelegate {
    func onScrollChange(_ sender: UIScrollView) {
//        tableTopConstraint.constant = sender.contentOffset.y
    }
}
