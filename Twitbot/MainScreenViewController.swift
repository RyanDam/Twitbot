//
//  MainScreenViewController.swift
//  Twitbot
//
//  Created by Dam Vu Duy on 3/30/16.
//  Copyright © 2016 dotRStudio. All rights reserved.
//

import UIKit

protocol SideMenuCallback: NSObjectProtocol {
    func onToggleSideMenuState()
}

class MainScreenViewController: UIViewController {
    
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var viewContainerConstraint: NSLayoutConstraint!
    
    var menuViewController: MenuViewController?
    var viewControllers: [UIViewController] = []
    
    var sideMenuStateOpened: Bool = true {
        willSet(opened) {
            if opened {
                openSideMenu()
            }
            else {
                closeSideMenu()
            }
        }
    }
    
    var viewContainerController: UIViewController! {
        willSet(newVC) {
            if let currentVC = self.viewContainerController {
                currentVC.removeFromParentViewController()
            }
            self.viewContainer.addSubview(newVC.view)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let profileTimeline = storyboard.instantiateViewControllerWithIdentifier("ProfileNavigationController") as! UINavigationController
        (profileTimeline.viewControllers[0] as! ProfileViewController).sideMenuCallback = self
        (profileTimeline.viewControllers[0] as! ProfileViewController).user = User.currentUser
        viewControllers.append(profileTimeline)
        
        let homeTimeline = storyboard.instantiateViewControllerWithIdentifier("HomeTweetNavigationController") as! UINavigationController
        (homeTimeline.viewControllers[0] as! TimelineViewController).sideMenuCallback = self
        (homeTimeline.viewControllers[0] as! TimelineViewController).timelineMode = FetchDataMode.HomeTimeline
        viewControllers.append(homeTimeline)
        
        let mentionTimeline = storyboard.instantiateViewControllerWithIdentifier("HomeTweetNavigationController") as! UINavigationController
        (mentionTimeline.viewControllers[0] as! TimelineViewController).sideMenuCallback = self
        (mentionTimeline.viewControllers[0] as! TimelineViewController).timelineMode = FetchDataMode.MentionTimeline
        viewControllers.append(mentionTimeline)
        
        self.menuViewController = storyboard.instantiateViewControllerWithIdentifier("MenuViewController") as? MenuViewController
        menuViewController?.delegate = self
        menuViewController?.dataSource = self
        menuView.addSubview((self.menuViewController?.view)!)
        
        self.viewContainerController = homeTimeline
        
        constraintDefault = self.viewContainerConstraint.constant
        
        let shadowPath = UIBezierPath(rect: viewContainer.bounds)
        viewContainer.layer.masksToBounds = false
        viewContainer.layer.shadowColor = UIColor.blackColor().CGColor
        viewContainer.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        viewContainer.layer.shadowOpacity = 0.2
        viewContainer.layer.shadowRadius = 16
        viewContainer.layer.shadowPath = shadowPath.CGPath
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var constraintDefault: CGFloat = 0
    
    @IBAction func onSwipe(sender: UIPanGestureRecognizer) {
        let translation = sender.translationInView(self.view)
        let velocity = sender.velocityInView(self.view)
        if sender.state == UIGestureRecognizerState.Began {
            
        }
        else if sender.state == UIGestureRecognizerState.Changed {
            viewContainerConstraint.constant = constraintDefault + translation.x
            var scale = (view.frame.size.width - viewContainerConstraint.constant) / view.frame.size.width
            if scale < 0.8 {
                scale = 0.8
            }
            else if scale > 1 {
                scale = 1
            }
            viewContainer.transform = CGAffineTransformMakeScale(scale, scale)
        }
        else if sender.state == UIGestureRecognizerState.Ended {
            if (velocity.x >= 0) {
                sideMenuStateOpened = true
            }
            else {
                sideMenuStateOpened = false
            }
        }
        view.layoutIfNeeded()
    }
}

extension MainScreenViewController: MenuViewDataSource, MenuViewDelegate {
    func onChangedView(target view: UIViewController) {
        self.viewContainerController = view
        self.sideMenuStateOpened = false
        
    }
    
    func getSizeOfData() -> Int {
        return viewControllers.count
    }
    
    func getTitleAtPosition(position: Int) -> String {
        switch position {
        case 0:
            return "Profile"
        case 1:
            return "Home timeline"
        case 2:
            return "Mention"
        case 3:
            return "Log out"
        default:
            return ""
        }
    }
    
    func getViewControllerAtPosition(position: Int) -> UIViewController {
        return viewControllers[position]
    }
}

extension MainScreenViewController: SideMenuCallback {
    
    func openSideMenu() {
        UIView.animateWithDuration(0.2, animations: {
            self.viewContainerConstraint.constant = self.view.frame.size.width - 130
            self.viewContainer.transform = CGAffineTransformMakeScale(0.8, 0.8)
            self.constraintDefault = self.view.frame.size.width - 130
            self.view.layoutIfNeeded()
        })
    }
    
    func closeSideMenu() {
        UIView.animateWithDuration(0.2, animations: {
            self.viewContainerConstraint.constant = 0
            self.viewContainer.transform = CGAffineTransformMakeScale(1, 1)
            self.constraintDefault = 0
            self.view.layoutIfNeeded()
            })
    }
    
    func onToggleSideMenuState() {
        sideMenuStateOpened = !sideMenuStateOpened
    }
    
    func getIconAtPosition(position: Int) -> UIImage {
        switch position {
        case 0:
            return UIImage(named: "profile")!
        case 1:
            return UIImage(named: "home")!
        case 2:
            return UIImage(named: "mention")!
        case 3:
            return UIImage(named: "logout")!
        default:
            return UIImage()
        }
    }
}