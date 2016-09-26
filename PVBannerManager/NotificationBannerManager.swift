//
//  NotificationBannerManager.swift
//  PVBannerManager
//
//  Created by Peter Vu on 9/26/16.
//  Copyright © 2016 Peter Vu. All rights reserved.
//

import UIKit

public class NotificationBannerManager {
    
    public static let `default` = NotificationBannerManager()
    
    public typealias PresentCompletion = (Void) -> (Void)
    public typealias DismissCompletion = (Void) -> (Void)
    
    private lazy var bannerView: NotificationBannerContainerView = NotificationBannerContainerView()
    private lazy var bannerWindow: UIWindow = {
        let window: PassthroughWindow = PassthroughWindow(frame: UIScreen.main.bounds)
        window.windowLevel = UIWindowLevelStatusBar
        window.addSubview(self.bannerView)
        return window
    }()
    
    private var isShowing: Bool = false
    private var currentBannerAnimator: NotificationBannerAnimator?
    private var oldKeyWindow: UIWindow?
    private var dismissTimer: Timer?
    
    // MARK: - Present, Dismiss
    public func present(content: NotificationContentProvider,
                        forDuration duration: TimeInterval = 60,
                        withAnimator animator: NotificationBannerAnimator = SlideNotificationBannerAnimator(),
                        animated: Bool = true,
                        presentCompletionHandler: PresentCompletion? = nil) {
        assert(duration > animator.animationDuration, "Showing duration must greater than animation duration")
        
        currentBannerAnimator = animator
        oldKeyWindow = UIApplication.shared.keyWindow
        
        content.bannerManager = self
        dismissTimer?.invalidate()
        dismissTimer = Timer.scheduledTimer(timeInterval: duration, target: self, selector: #selector(dismissTimmerFired(sender:)), userInfo: animated, repeats: false)
        
        bannerView.contentProvider = content
        bannerWindow.isHidden = false
        bannerWindow.makeKeyAndVisible()
        
        let initialBannerAttributes = animator.initialBannerAttributes(forContentHeight: content.bannerHeight, inRect: bannerWindow.bounds)
        let finalBannerAttributes = animator.finalBannerAttributes(forContentHeight: content.bannerHeight, inRect: bannerWindow.bounds)
        
        let targetBannerFrame = finalBannerAttributes.frame
        
        if animated && !isShowing {
            bannerView.alpha = initialBannerAttributes.alpha
            bannerView.frame = initialBannerAttributes.frame
            
            UIView.animate(withDuration: animator.animationDuration,
                           delay: 0,
                           options: animator.animationOptions,
                           animations: { [weak self] in
                            self?.bannerView.frame = targetBannerFrame
                            self?.bannerView.alpha = finalBannerAttributes.alpha
                },
                           completion: { [weak self] completed in
                            if completed {
                                self?.isShowing = true
                                presentCompletionHandler?()
                            }
                })
        } else {
            bannerView.frame = targetBannerFrame
            bannerView.alpha = finalBannerAttributes.alpha
            isShowing = true
            presentCompletionHandler?()
        }
        
        bannerView.layoutIfNeeded()
    }
    
    @objc private func dismissTimmerFired(sender: Timer) {
        let animated = (sender.userInfo as? Bool) ?? false
        dismiss(animated: animated)
    }
    
    public func dismiss(content: NotificationContentProvider, animated: Bool, completionHandler dismissCompletionHandler: DismissCompletion? = nil) {
        let contentView = content.bannerContent
        if contentView == bannerView.contentView {
            dismiss(animated: animated, completionHandler: dismissCompletionHandler)
        } else {
            isShowing = false
            dismissCompletionHandler?()
        }
    }
    
    public func dismiss(animated: Bool, completionHandler dismissCompletionHandler: DismissCompletion? = nil) {
        guard let animator = currentBannerAnimator else {
            bannerView.frame = .zero
            removeBannerWindow()
            dismissCompletionHandler?()
            return
        }
        
        let targetBannerAttributes = animator.initialBannerAttributes(forContentHeight: bannerView.frame.height, inRect: bannerWindow.bounds)
        
        let targetBannerFrame = targetBannerAttributes.frame
        
        if animated {
            UIView.animate(withDuration: animator.animationDuration,
                           delay: 0,
                           options: animator.animationOptions,
                           animations: { [weak self] in
                            self?.bannerView.frame = targetBannerFrame
                            self?.bannerView.alpha = targetBannerAttributes.alpha
                }, completion: { [weak self] completed in
                    if completed {
                        self?.removeBannerWindow()
                        self?.bannerView.alpha = 1
                        self?.isShowing = false
                        dismissCompletionHandler?()
                    }
                })
        } else {
            bannerView.alpha = 1
            bannerView.frame = targetBannerFrame
            isShowing = false
            removeBannerWindow()
            dismissCompletionHandler?()
        }
    }
    
    private func removeBannerWindow() {
        bannerWindow.removeFromSuperview()
        bannerWindow.isHidden = true
        bannerWindow.resignKey()
        oldKeyWindow?.becomeKey()
    }
    
    deinit {
        removeBannerWindow()
    }
}

private class NotificationBannerContainerView: UIView {
    private static let DefaultHeight: CGFloat = 50
    
    fileprivate var contentProvider: NotificationContentProvider? {
        didSet {
            contentView?.removeFromSuperview()
            guard let newContentProvider = contentProvider else {
                contentView = nil
                contentHeight = NotificationBannerContainerView.DefaultHeight
                return
            }
            let newContentView = newContentProvider.bannerContent
            contentView = newContentView
            contentHeight = newContentProvider.bannerHeight
            addSubview(newContentView)
            
            invalidateIntrinsicContentSize()
            layoutIfNeeded()
        }
    }
    
    fileprivate var contentView: UIView?
    private var contentHeight: CGFloat = NotificationBannerContainerView.DefaultHeight
    
    private override func layoutSubviews() {
        contentView?.frame = bounds
    }
    
    private override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: contentHeight)
    }
}

private class PassthroughWindow: UIWindow {
    private override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        for view in subviews {
            if let passthroughHitView = view.hitTest(convert(point, to: view), with: event) {
                return passthroughHitView
            }
        }
        return nil
    }
}
