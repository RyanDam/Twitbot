//
//  MenuViewController.swift
//  Twitbot
//
//  Created by Dam Vu Duy on 3/30/16.
//  Copyright © 2016 dotRStudio. All rights reserved.
//

import UIKit

protocol MenuViewDelegate: NSObjectProtocol {
    func onChangedView(target view: UIViewController)
}

protocol MenuViewDataSource: NSObjectProtocol {
    func getSizeOfData() -> Int
    func getTitleAtPosition(position: Int) -> String
    func getViewControllerAtPosition(position: Int) -> UIViewController
    func getIconAtPosition(position: Int) -> UIImage
}

class MenuViewController: UIViewController {
    
    weak var delegate: MenuViewDelegate?
    weak var dataSource: MenuViewDataSource?
    
    @IBOutlet weak var menuTableView: UITableView!
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var userScreenName: UILabel!
    @IBOutlet weak var username: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let user = User.currentUser
        username.text = user?.name!
        userScreenName.text = "@\((user?.screenName)!)"
        userAvatar.setImageWithURL((user?.profileUrl)!)
        menuTableView.dataSource = self
        menuTableView.delegate = self
        userAvatar.clipsToBounds = true
        userAvatar.layer.cornerRadius = userAvatar.frame.size.width / 2
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension MenuViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (dataSource?.getSizeOfData())! + 1 ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MenuTableViewCell", forIndexPath: indexPath) as! MenuTableViewCell
        
        if indexPath.row == (dataSource?.getSizeOfData())! {
            cell.titleLabel.text = "Log out"
        }
        else {
            cell.titleLabel.text = dataSource?.getTitleAtPosition(indexPath.row)
        }
        
        cell.iconMenu.image = dataSource?.getIconAtPosition(indexPath.row)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.row == (dataSource?.getSizeOfData())! {
            TwitterClient.sharedInstance.logout()
        }
        else {
            delegate?.onChangedView(target: (dataSource?.getViewControllerAtPosition(indexPath.row))!)
        }
        
    }
}