//
//  NewTweetViewController.swift
//  Twitbot
//
//  Created by Dam Vu Duy on 3/25/16.
//  Copyright © 2016 dotRStudio. All rights reserved.
//

import UIKit

class NewTweetViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var userScreenName: UILabel!
    @IBOutlet weak var wordCounterLabel: UILabel!
    @IBOutlet weak var inputWord: UITextView!
    
    var maxInputCount = 140
    var inputTextColor: UIColor = UIColor()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        username.text = User.currentUser?.name
        userScreenName.text = User.currentUser?.screenName
        userAvatar.setImageWithURL((User.currentUser?.profileUrl)!)
        userAvatar.layer.cornerRadius = 8
        inputWord.delegate = self
        inputTextColor = inputWord.textColor!
        inputWord.becomeFirstResponder()
        setPlaceHoderMode()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textViewDidChange(sender: UITextView) {
        if sender.text?.characters.count > 140 {
            wordCounterLabel.text = "140/140"
            let index = sender.text?.endIndex.advancedBy(-((sender.text?.characters.count)! - 140))
            sender.text = sender.text?.substringToIndex(index!)
        }
        else {
            wordCounterLabel.text = "\((sender.text?.characters.count)!)/140"
        }
    }
    
    func textViewShouldEndEditing(sender: UITextView) -> Bool {
        if sender.text!.characters.count == 0 {
            setPlaceHoderMode()
        }
        return true
    }
    
    var isPlaceholderMode = false
    
    func textViewShouldBeginEditing(sender: UITextView) -> Bool {
        if isPlaceholderMode {
            isPlaceholderMode = false
            inputWord.setPlaceHolder("", color: inputTextColor)
        }
        return true
    }

    func setPlaceHoderMode() {
        isPlaceholderMode = true
        inputWord.setPlaceHolder("Tap to compose new tweet...", color: UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1))
    }
    
    @IBAction func onTapOutside(sender: UITapGestureRecognizer) {
        inputWord.endEditing(true)
    }
}

extension UITextView {
    func setPlaceHolder(text: String, color: UIColor) {
        self.text = text
        self.textColor = color
    }
    
}
