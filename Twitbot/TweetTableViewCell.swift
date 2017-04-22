//
//  TweetTableViewCell.swift
//  Twitbot
//
//  Created by Dam Vu Duy on 3/24/16.
//  Copyright © 2016 dotRStudio. All rights reserved.
//

import UIKit

protocol TweetTableViewCellDelegate: NSObjectProtocol {
    func onShare(_ sender: TweetTableViewCell) -> Void
    func onTweet(_ sender: TweetTableViewCell) -> Void
    func onLike(_ sender: TweetTableViewCell) -> Void
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
                likeButton.setImage(UIImage(named: "like-ed"), for: UIControlState())
            }
            else {
                likeButton.setImage(UIImage(named: "like"), for: UIControlState())
            }
        }
    }
    
    var isRetweeted: Bool = false {
        didSet {
            if isRetweeted {
                retweetButton.setImage(UIImage(named: "retweeted"), for: UIControlState())
            }
            else {
                retweetButton.setImage(UIImage(named: "retweet"), for: UIControlState())
            }
        }
    }
    
    func showRetweetIndicate(_ name: String) {
        retweetImageIndicate.isHidden = false
        retweetLabelIndicate.isHidden = false
        retweetLabelIndicate.text = "\(name) retweeted:"
        avatarTopContraint.constant = 16
    }
    
    func hideRetweetIndicate() {
        retweetImageIndicate.isHidden = true
        retweetLabelIndicate.isHidden = true
        avatarTopContraint.constant = -8
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    func setImageToPreview(_ url: URL) {
        imagePreview.setImageWith(url)
        imagePreview.setImageWith(URLRequest(url: url), placeholderImage: UIImage(), success: { (request: URLRequest, response: HTTPURLResponse?, img: UIImage) in
            self.callback?.reloadData()
        }) { (request: URLRequest, response: HTTPURLResponse?, err: Error) in
            print(err.localizedDescription)
        }
        imagePreview.isHidden = false
        topReplyButtonConstraint.constant = 8
    }
    
    func noneImage() {
        imagePreview.isHidden = true
        topReplyButtonConstraint.constant = -150
    }
    
    @IBAction func onShare(_ sender: UIButton) {
        self.delegate?.onShare(self)
    }
    @IBAction func onTweet(_ sender: UIButton) {
        self.delegate?.onTweet(self)
    }
    @IBAction func onLike(_ sender: UIButton) {
        self.delegate?.onLike(self)
    }
}
