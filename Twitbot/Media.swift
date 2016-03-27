//
//  Media.swift
//  Twitbot
//
//  Created by Dam Vu Duy on 3/27/16.
//  Copyright © 2016 dotRStudio. All rights reserved.
//

import UIKit

class Media: NSObject {
    var imageUrl: NSURL?
    init(dictionary: NSDictionary) {
        imageUrl = NSURL(string: dictionary["media_url"] as! String)!
    }
}
