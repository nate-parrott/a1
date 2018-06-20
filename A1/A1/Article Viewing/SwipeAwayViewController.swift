//
//  SwipeAwayViewController.swift
//  fast-news-ios
//
//  Created by Nate Parrott on 2/13/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

import UIKit

class SwipeAwayViewController: UIViewController, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate, UIDynamicAnimatorDelegate, UIGestureRecognizerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0, alpha: 0)
        if contentView == nil {
            contentView = UIView()
            contentView.backgroundColor = UIColor.white
        }
        if contentView.superview == nil {
            view.addSubview(contentView)
        }
        _panRec = SSWDirectionalPanGestureRecognizer(target: self, action: #selector(_swiped(rec:)))
        _panRec.delegate = self
        _panRec.direction = .right
        view.addGestureRecognizer(_panRec)
    }
    @IBOutlet var contentView: UIView!
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        contentView.bounds = view.bounds
        _snap?.snapPoint = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
    }
    
    // MARK: Interaction
    var _panRec: SSWDirectionalPanGestureRecognizer!
    var _attachment: UIAttachmentBehavior!
    var _attachmentStartPos: CGPoint!
    @objc func _swiped(rec: SSWDirectionalPanGestureRecognizer) {
        switch _transitionState {
        case .Entrance: return
        default: ()
        }
        var end = false
        switch rec.state {
        case .began:
            _attachmentStartPos = contentView.center
            _attachment = UIAttachmentBehavior(item: contentView, attachedToAnchor: _attachmentStartPos)
            _animator.addBehavior(_attachment)
        case .changed:
            if _attachment != nil {
                _attachment.anchorPoint = _attachmentStartPos + CGPoint(x: rec.translation(in: view).x, y: 0)
            }
        case .ended:
            end = true
            if abs(rec.velocity(in: view).x) > 50 {
                _snapActive = false // continue the exit; just let contentView fly out of sight
            } else {
                _snapActive = true
            }
        case .failed:
            end = true
            _snapActive = true
        default: ()
        }
        if end && _attachment != nil {
            _animator.removeBehavior(_attachment)
            _attachment = nil
            _itemBehavior.addLinearVelocity(CGPoint(x: rec.velocity(in: view).x, y: 0), for: contentView)
        }
    }
    
    // MARK: Static transition
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        let presenting = (toVC === self)
        let root = transitionContext.containerView
        
        if presenting {
            root.addSubview(view)
            view.frame = transitionContext.finalFrame(for: toVC)
            _setupAnimator()
            _transitionState = .Entrance
            transitionContext.completeTransition(true)
        } else {
            view.removeFromSuperview()
            transitionContext.completeTransition(true)
        }
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if presented === self {
            return self
        } else {
            return nil
        }
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed === self {
            return self
        } else {
            return nil
        }
    }
    
    func presentFrom(parent: UIViewController) {
        transitioningDelegate = self
        modalPresentationStyle = .custom
        parent.present(self, animated: true, completion: nil)
    }
    
    // MARK: Dynamics
    func _setupAnimator() {
        contentView.bounds = view.bounds
        contentView.center = CGPoint(x: contentView.bounds.width * 1.5, y: view.bounds.midY)
        
        _animator = UIDynamicAnimator(referenceView: view)
        _animator.delegate = self
        
        _itemBehavior = UIDynamicItemBehavior(items: [contentView])
        _itemBehavior.allowsRotation = false
        _animator.addBehavior(_itemBehavior)
    }
    enum DynamicTransitionState {
        case NotSetUp
        case Entrance
        case Presented
        case Exit
    }
    var _transitionState = DynamicTransitionState.NotSetUp {
        didSet (oldState) {
            switch _transitionState {
            case .Entrance:
                _snapActive = true
            case .Presented: ()
                // TODO
            default: ()
            }
        }
    }
    
    var _snapActive = false {
        didSet (old) {
            if old != _snapActive {
                if _snapActive {
                    if _snap == nil {
                        _snap = UISnapBehavior(item: contentView, snapTo: CGPoint(x: view.bounds.midX, y: view.bounds.midY))
                    }
                    _animator.addBehavior(_snap)
                } else {
                    _animator.removeBehavior(_snap)
                }
            }
        }
    }
    var _snap: UISnapBehavior!
    func _induceExit() {
        _animator.removeAllBehaviors()
        UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseIn], animations: {
            self.contentView.center = self.contentView.center + CGPoint(x: self.contentView.bounds.width, y: 0)
            self.view.backgroundColor = UIColor.clear
            StatusBarHacks.opacity = 1
        }) { (_) in
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    var _animator: UIDynamicAnimator!
    var _itemBehavior: UIDynamicItemBehavior!
    func dynamicAnimatorWillResume(_ animator: UIDynamicAnimator) {
        _dynamicAnimatorActive = true
    }
    func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator) {
        _dynamicAnimatorActive = false
    }
    var _dynamicAnimatorActive = false {
        didSet (old) {
            if _dynamicAnimatorActive != old {
                if _dynamicAnimatorActive {
                    _displayLink = CADisplayLink(target: self, selector: #selector(_dynamicAnimationTick))
                    _displayLink!.add(to: RunLoop.main, forMode: RunLoopMode.commonModes)
                } else {
                    _displayLink?.invalidate()
                    _displayLink = nil
                    _dynamicAnimationTick()
                }
            }
        }
    }
    var _displayLink: CADisplayLink?
    @objc func _dynamicAnimationTick() {
        view.backgroundColor = UIColor(white: 0, alpha: 0.7 * _contentViewScreenOverlap)
        StatusBarHacks.opacity = 1 - _contentViewScreenOverlap
        
        switch _transitionState {
        case .Entrance: _checkIfDynamicEntranceCompleted()
        case .Exit: _checkIfDynamicExitCompleted()
        case .Presented: _checkIfDynamicExitBegan()
        default: ()
        }
    }
    var _contentViewScreenOverlap: CGFloat {
        get {
            if contentView.frame.intersects(view.bounds) {
                let overlapSize = contentView.frame.intersection(view.bounds).size
                return overlapSize.width * overlapSize.height / (view.bounds.size.width * view.bounds.size.height)
            } else {
                return 0
            }
        }
    }
    func _checkIfDynamicEntranceCompleted() {
        if !_dynamicAnimatorActive && _contentViewScreenOverlap > 0.95 {
            contentView.center = view.center
            _transitionState = .Presented
        }
    }
    func _checkIfDynamicExitCompleted() {
        if !_dynamicAnimatorActive && _contentViewScreenOverlap == 1 {
            _transitionState = .Presented
        } else if _contentViewScreenOverlap == 0 {
            dismiss(animated: true, completion: nil)
            _animator.removeAllBehaviors()
        }
    }
    func _checkIfDynamicExitBegan() {
        if _dynamicAnimatorActive && _contentViewScreenOverlap < 1 {
            _transitionState = .Exit
        }
    }
}
