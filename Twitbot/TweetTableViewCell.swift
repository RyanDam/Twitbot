//
//  TweetTableViewCell.swift
//  Twitbot
//
//  Created by Dam Vu Duy on 3/24/16.
//  Copyright © 2016 dotRStudio. All rights reserved.
//

import UIKit

protocol TweetTableViewCellDelegate: NSObjectProtocol {
    func onShare(sender: TweetTableViewCell) -> Void
    func onTweet(sender: TweetTableViewCell) -> Void
    func onLike(sender: TweetTableViewCell) -> Void
}

class TweetTableViewCell: UITableViewCell {
    
    weak var delegate: TweetTableViewCellDelegate?
    
    var callback: UITableView?
    
    @IBOutlet weak var topReplyButtonConstraint: NSLayoutConstraint!
    @IBOutlet weak var imagePreview: UIImageView!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var avatarTopContraint: NSLayoutConstraint!
    @IBOutlet weak var retweetImageIndicate: UIImageView!
    @IBOutlet weak var retweetLabelIndicate: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var userScreenName: UILabel!
    @IBOutlet weak var timestamp: UILabel!
    @IBOutlet weak var tweetText: UILabel!
    @IBOutlet weak var retweetCount: UILabel!
    @IBOutlet weak var likeCount: UILabel!

    var isLiked: Bool = false {
        didSet {
            if isLiked {
                likeButton.setImage(UIImage(named: "like-ed"), forState: UIControlState.Normal)
            }
            else {
                likeButton.setImage(UIImage(named: "like"), forState: UIControlState.Normal)
            }
        }
    }
    
    var isRetweeted: Bool = false {
        didSet {
            if isRetweeted {
                retweetButton.setImage(UIImage(named: "retweeted"), forState: UIControlState.Normal)
            }
            else {
                retweetButton.setImage(UIImage(named: "retweet"), forState: UIControlState.Normal)
            }
        }
    }
    
    func showRetweetIndicate(name: String) {
        retweetImageIndicate.hidden = false
        retweetLabelIndicate.hidden = false
        retweetLabelIndicate.text = "\(name) retweeted:"
        avatarTopContraint.constant = 16
    }
    
    func hideRetweetIndicate() {
        retweetImageIndicate.hidden = true
        retweetLabelIndicate.hidden = true
        avatarTopContraint.constant = -8
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    func setImageToPreview(url: NSURL) {
        imagePreview.setImageWithURL(url)
        imagePreview.setImageWithURLRequest(NSURLRequest(URL: url), placeholderImage: UIImage(), success: { (request: NSURLRequest, response: NSHTTPURLResponse?, img: UIImage) in
            self.callback?.reloadData()
        }) { (request: NSURLRequest, response: NSHTTPURLResponse?, err: NSError) in
            print(err.localizedDescription)
        }
        imagePreview.hidden = false
        topReplyButtonConstraint.constant = 8
    }
    
    func noneImage() {
        imagePreview.hidden = true
        topReplyButtonConstraint.constant = -150
    }
    
    @IBAction func onShare(sender: UIButton) {
        self.delegate?.onShare(self)
    }
    @IBAction func onTweet(sender: UIButton) {
        self.delegate?.onTweet(self)
    }
    @IBAction func onLike(sender: UIButton) {
        self.delegate?.onLike(self)
    }
}
