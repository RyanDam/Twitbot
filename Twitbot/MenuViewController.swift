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
    func getTitleAtPosition(_ position: Int) -> String
    func getViewControllerAtPosition(_ position: Int) -> UIViewController
    func getIconAtPosition(_ position: Int) -> UIImage
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
        userAvatar.setImageWith((user?.profileUrl)! as URL)
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (dataSource?.getSizeOfData())! + 1 ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuTableViewCell", for: indexPath) as! MenuTableViewCell
        
        if (indexPath as NSIndexPath).row == (dataSource?.getSizeOfData())! {
            cell.titleLabel.text = "Log out"
        }
        else {
            cell.titleLabel.text = dataSource?.getTitleAtPosition((indexPath as NSIndexPath).row)
        }
        
        cell.iconMenu.image = dataSource?.getIconAtPosition((indexPath as NSIndexPath).row)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if (indexPath as NSIndexPath).row == (dataSource?.getSizeOfData())! {
            TwitterClient.sharedInstance?.logout()
        }
        else {
            delegate?.onChangedView(target: (dataSource?.getViewControllerAtPosition((indexPath as NSIndexPath).row))!)
        }
        
    }
}
