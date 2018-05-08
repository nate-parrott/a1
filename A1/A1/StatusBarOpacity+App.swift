//
//  StatusBarOpacity+App.swift
//  fast-news-ios
//
//  Created by Nate Parrott on 7/8/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

import UIKit

struct StatusBarHacks {
    static var window: UIWindow? {
        return UIApplication.shared.value(forKey: "statusBarWindow") as? UIWindow
    }
    static var opacity: CGFloat? {
        get {
            return window?.alpha
        }
        set(v) {
            window?.alpha = v ?? 1
        }
    }
}
