//
//  ViewController.swift
//  Twitbot
//
//  Created by Dam Vu Duy on 3/23/16.
//  Copyright © 2016 dotRStudio. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class LoginViewController: UIViewController {
    
    @IBOutlet weak var mainLoginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        mainLoginButton.layer.cornerRadius = 8
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onLogin(_ sender: AnyObject) {
        TwitterClient.sharedInstance?.login({ () in
            self.performSegue(withIdentifier: "LoginSegue", sender: self)
        }) { (err: Error) in
            print(err.localizedDescription)
        }
    }
}

