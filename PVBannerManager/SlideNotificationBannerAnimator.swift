//
//  SlideNotificationBannerAnimator.swift
//  PVBannerManager
//
//  Created by Peter Vu on 9/26/16.
//  Copyright © 2016 Peter Vu. All rights reserved.
//

import UIKit

public class SlideNotificationBannerAnimator: NotificationBannerAnimator {
    public enum Direction {
        case fromTop, fromBottom
    }
    
    public var animationDuration: TimeInterval
    public var animationOptions: UIViewAnimationOptions
    public var direction: Direction
    
    init(direction: Direction = .fromTop,
         animationDuration: TimeInterval = 0.28,
         animationOptions: UIViewAnimationOptions = []) {
        self.direction = direction
        self.animationDuration = animationDuration
        self.animationOptions = animationOptions
    }
    
    public func initialBannerAttributes(forContentHeight contentHeight: CGFloat, inRect rect: CGRect) -> NotificationBannerAttributes {
        switch direction {
        case .fromBottom:
            return NotificationBannerAttributes(alpha: 1, frame: CGRect(x: 0, y: rect.height, width: rect.width, height: contentHeight))
        case .fromTop:
            return NotificationBannerAttributes(alpha: 1, frame: CGRect(x: 0, y: -contentHeight, width: rect.width, height: contentHeight))
        }
    }
    
    public func finalBannerAttributes(forContentHeight contentHeight: CGFloat, inRect rect: CGRect) -> NotificationBannerAttributes {
        switch direction {
        case .fromBottom:
            return NotificationBannerAttributes(alpha: 1, frame: CGRect(x: 0, y: rect.height - contentHeight, width: rect.width, height: contentHeight))
        case .fromTop:
            return NotificationBannerAttributes(alpha: 1, frame: CGRect(x: 0, y: 0, width: rect.width, height: contentHeight))
        }
    }
    
}
