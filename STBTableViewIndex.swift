//
//  STBTableViewIndex.swift
//  STBTableViewIndex
//
//  Objective-C code Copyright (c) 2013 Benjamin Kreeger. All rights reserved.
//  Swift adaptation Copyright (c) 2014 Nicolas Gomollon. All rights reserved.
//

import Foundation
import UIKit

public let STBTableViewIndexLayoutDidChange = UIDeviceOrientationDidChangeNotification

public protocol STBTableViewIndexDelegate: NSObjectProtocol {
	
	func tableViewIndexChanged(index: Int, title: String)
	
	func tableViewIndexTopLayoutGuideLength() -> CGFloat
	
	func tableViewIndexBottomLayoutGuideLength() -> CGFloat
	
}

public class STBTableViewIndex: UIControl {
	
	public weak var delegate: STBTableViewIndexDelegate!
	private var panGestureRecognizer: UIPanGestureRecognizer!
	private var tapGestureRecognizer: UITapGestureRecognizer!
	
	public var currentIndex = 0
	public var currentTitle: String { return titles[currentIndex] }
	
	public var view = UIView(frame: CGRectZero)
	
	public var titles: Array<String> {
		didSet {
			createLabels()
		}
	}
	
	public var autoHides = true
	public var visible: Bool {
		didSet {
			UIView.animateWithDuration(0.2, animations: { [unowned self] in
				self.view.alpha = self.visible ? 1.0 : 0.0
			})
		}
	}
	
	public var labels = Array<UILabel>()
	
	private var canAutoHide: Bool {
		if UIAccessibilityIsVoiceOverRunning() { return false }
		return autoHides
	}
	
	private var width: CGFloat { return 16.0 }
	private var horizontalPadding: CGFloat { return 5.0 }
	private var verticalPadding: CGFloat { return 5.0 }
	private var endPadding: CGFloat { return 3.0 }
	
	private var controlSizeWidth: CGFloat { return width + (horizontalPadding * 2.0) }
	private var controlOriginX: CGFloat {
		let screenWidth = UIScreen.mainScreen().bounds.size.width
		return screenWidth - controlSizeWidth
	}
	private var controlOriginY: CGFloat {
		if let topHeight = delegate?.tableViewIndexTopLayoutGuideLength() {
			return topHeight
		}
		return 0.0
	}
	private var controlSizeHeight: CGFloat {
		var sizeHeight: CGFloat = 0.0
		let screenHeight = UIScreen.mainScreen().bounds.size.height
		sizeHeight = screenHeight
		sizeHeight -= controlOriginY
		if let bottomHeight = delegate?.tableViewIndexBottomLayoutGuideLength() {
			sizeHeight -= bottomHeight
		}
		return sizeHeight
	}
	
	private var controlFrame: CGRect {
		return CGRectMake(controlOriginX, controlOriginY, controlSizeWidth, controlSizeHeight)
	}
	
	private var controlBounds: CGRect {
		return CGRectMake(0.0, 0.0, controlSizeWidth, controlSizeHeight)
	}
	
	private var viewFrame: CGRect {
		return CGRectInset(controlBounds, horizontalPadding, verticalPadding)
	}
	
	private var viewBounds: CGRect {
		return CGRectMake(0.0, 0.0, viewFrame.size.width, viewFrame.size.height)
	}
	
	
	public convenience init() {
		self.init(frame: CGRectZero)
	}
	
	public override init(frame: CGRect) {
		titles = Array<String>()
		visible = true
		super.init(frame: CGRectZero)
		initialize()
	}
	
	public required init?(coder aDecoder: NSCoder) {
		titles = Array<String>()
		visible = true
		super.init(coder: aDecoder)
		initialize()
	}
	
	private func initialize() {
		panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(STBTableViewIndex._handleGesture(_:)))
		addGestureRecognizer(panGestureRecognizer)
		
		tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(STBTableViewIndex._handleGesture(_:)))
		addGestureRecognizer(tapGestureRecognizer)
		
		view.backgroundColor = .whiteColor()
		view.layer.borderColor = UIColor(white: 0.0, alpha: 0.1).CGColor
		view.layer.borderWidth = 1.0
		view.layer.masksToBounds = true
		addSubview(view)
		
		isAccessibilityElement = true
		shouldGroupAccessibilityChildren = true
		accessibilityLabel = NSLocalizedString("STBTableViewIndex-LABEL", tableName: "STBTableViewIndex", bundle: NSBundle.mainBundle(), value: "Table index", comment: "")
		accessibilityTraits = UIAccessibilityTraitAdjustable
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(STBTableViewIndex.accessibilityVoiceOverStatusChanged), name: UIAccessibilityVoiceOverStatusChanged, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UIView.setNeedsLayout), name: STBTableViewIndexLayoutDidChange, object: nil)
		setNeedsLayout()
	}
	
	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
	public override func layoutSubviews() {
		super.layoutSubviews()
		
		frame = controlFrame
		view.frame = viewFrame
		view.layer.cornerRadius = CGRectGetWidth(view.frame) / 2.0
		
		var labelOriginY = endPadding
		let labelWidth = CGRectGetWidth(view.frame)
		let labelHeight = (CGRectGetHeight(view.frame) - (endPadding * 2.0)) / CGFloat(labels.count)
		
		for label in labels {
			let labelFrame = CGRectMake(0.0, labelOriginY, labelWidth, labelHeight)
			label.frame = CGRectIntegral(labelFrame)
			labelOriginY += labelHeight
		}
	}
	
	private func createLabels() {
		for label in labels {
			label.removeFromSuperview()
		}
		labels.removeAll()
		for (tag, title) in titles.enumerate() {
			let label = UILabel(frame: CGRectZero)
			label.backgroundColor = .clearColor()
			label.font = .boldSystemFontOfSize(10.0)
			label.textColor = view.tintColor
			label.textAlignment = .Center
			label.text = title
			label.tag = tag
			view.addSubview(label)
			labels += [label]
		}
	}
	
	private func setNewIndex(point p: CGPoint) {
		var point = p
		point.x = CGRectGetWidth(view.frame) / 2.0
		for label in labels {
			if CGRectContainsPoint(label.frame, point) {
				let newIndex = label.tag
				if newIndex != currentIndex {
					currentIndex = newIndex
					delegate?.tableViewIndexChanged(currentIndex, title: currentTitle)
				}
			}
		}
	}
	
	public func hideIndex() {
		visible = false
	}
	
	public func showIndex() {
		visible = true
	}
	
	public func flashIndex() {
		view.alpha = 1.0
		if canAutoHide {
			NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(STBTableViewIndex.hideIndex), userInfo: nil, repeats: false)
		}
	}
	
	public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		let touch = touches.first
		if let location = touch?.locationInView(self) {
			setNewIndex(point: location)
			if canAutoHide {
				visible = true
			}
		}
	}
	
	public override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
		if canAutoHide {
			visible = false
		}
	}
	
	internal func _handleGesture(gesture: UIGestureRecognizer) {
		let location = gesture.locationInView(self)
		setNewIndex(point: location)
		if canAutoHide {
			visible = !(gesture.state == .Ended)
		}
	}
	
	internal func accessibilityVoiceOverStatusChanged() {
		if autoHides {
			visible = UIAccessibilityIsVoiceOverRunning()
		}
	}
	
	public override func accessibilityElementDidLoseFocus() {
		accessibilityValue = nil
	}
	
	public override func accessibilityIncrement() {
		if currentIndex < (labels.count - 1) {
			currentIndex += 1
		}
		delegate?.tableViewIndexChanged(currentIndex, title: currentTitle)
		accessibilityValue = currentTitle.lowercaseString
	}
	
	public override func accessibilityDecrement() {
		if currentIndex > 0 {
			currentIndex -= 1
		}
		delegate?.tableViewIndexChanged(currentIndex, title: currentTitle)
		accessibilityValue = currentTitle.lowercaseString
	}
	
}
