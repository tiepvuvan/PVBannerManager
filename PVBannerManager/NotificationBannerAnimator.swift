//
//  NotificationBannerAnimator.swift
//  PVBannerManager
//
//  Created by Peter Vu on 9/26/16.
//  Copyright © 2016 Peter Vu. All rights reserved.
//

import UIKit

public struct NotificationBannerAttributes {
    var alpha: CGFloat = 1
    var frame: CGRect = .zero
}

public protocol NotificationBannerAnimator {
    var animationDuration: TimeInterval { get }
    var animationOptions: UIViewAnimationOptions { get }
    
    func initialBannerAttributes(forContentHeight contentHeight: CGFloat, inRect rect: CGRect) -> NotificationBannerAttributes
    func finalBannerAttributes(forContentHeight contentHeight: CGFloat, inRect rect: CGRect) -> NotificationBannerAttributes
}
