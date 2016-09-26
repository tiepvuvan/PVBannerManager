//
//  NotificationContentProvider.swift
//  PVBannerManager
//
//  Created by Peter Vu on 9/26/16.
//  Copyright © 2016 Peter Vu. All rights reserved.
//

import UIKit

public protocol NotificationContentProvider: class {
    var bannerContent: UIView { get }
    var bannerHeight: CGFloat { get }
    var bannerManager: NotificationBannerManager? { get set }
}

extension NotificationContentProvider where Self: UIView {
    var bannerContent: UIView { return self }
}
