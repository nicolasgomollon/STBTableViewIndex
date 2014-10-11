//
//  STBTableViewIndex.swift
//  STBTableViewIndex
//
//  Objective-C code Copyright (c) 2013 Benjamin Kreeger. All rights reserved.
//  Swift adaptation Copyright (c) 2014 Nicolas Gomollon. All rights reserved.
//

import Foundation
import UIKit

let STBTableViewIndexLayoutDidChange = UIDeviceOrientationDidChangeNotification

protocol STBTableViewIndexDelegate: NSObjectProtocol {
	
	func tableViewIndexChanged(index: Int, title: String)
	
	func tableViewIndexTopLayoutGuideLength() -> CGFloat
	
	func tableViewIndexBottomLayoutGuideLength() -> CGFloat
	
}

class STBTableViewIndex: UIControl {
	
	var delegate: STBTableViewIndexDelegate!
	var panGestureRecognizer: UIPanGestureRecognizer!
	var tapGestureRecognizer: UITapGestureRecognizer!
	
	var currentIndex = 0
	var currentTitle: String { return titles[currentIndex] }
	
	var view = UIView(frame: CGRectZero)
	
	var titles: Array<String> {
	didSet {
		createLabels()
	}
	}
	
	var visible: Bool {
	didSet {
		UIView.animateWithDuration(0.2, animations: {
			self.view.alpha = self.visible ? 1.0 : 0.0
		})
	}
	}
	
	var labels = Array<UILabel>()
	
	var width: CGFloat { return 16.0 }
	var horizontalPadding: CGFloat { return 5.0 }
	var verticalPadding: CGFloat { return 5.0 }
	var endPadding: CGFloat { return 3.0 }
	
	var controlSizeWidth: CGFloat { return width + (horizontalPadding * 2.0) }
	var controlOriginX: CGFloat {
		let screenWidth = UIScreen.mainScreen().bounds.size.width
		return screenWidth - controlSizeWidth
	}
	var controlOriginY: CGFloat {
		if let topHeight = delegate?.tableViewIndexTopLayoutGuideLength() {
			return topHeight
		}
		return 0.0
	}
	var controlSizeHeight: CGFloat {
		var sizeHeight: CGFloat = 0.0
		let screenHeight = UIScreen.mainScreen().bounds.size.height
		sizeHeight = screenHeight
		sizeHeight -= controlOriginY
		if let bottomHeight = delegate?.tableViewIndexBottomLayoutGuideLength() {
			sizeHeight -= bottomHeight
		}
		return sizeHeight
	}
	
	var controlFrame: CGRect {
		return CGRectMake(controlOriginX, controlOriginY, controlSizeWidth, controlSizeHeight)
	}
	
	var controlBounds: CGRect {
		return CGRectMake(0.0, 0.0, controlSizeWidth, controlSizeHeight)
	}
	
	var viewFrame: CGRect {
		return CGRectInset(controlBounds, horizontalPadding, verticalPadding)
	}
	
	var viewBounds: CGRect {
		return CGRectMake(0.0, 0.0, viewFrame.size.width, viewFrame.size.height)
	}
	
	
	convenience override init() {
		self.init(frame: CGRectZero)
	}
	
	override init(frame: CGRect) {
		titles = Array<String>()
		visible = true
		super.init(frame: CGRectZero)
		initialize()
	}
	
	required init(coder aDecoder: NSCoder) {
		titles = Array<String>()
		visible = true
		super.init(coder: aDecoder)
		initialize()
	}
	
	func initialize() {
		panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handleGesture:")
		addGestureRecognizer(panGestureRecognizer)
		
		tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleGesture:")
		addGestureRecognizer(tapGestureRecognizer)
		
		view.backgroundColor = UIColor.whiteColor()
		view.layer.borderColor = UIColor(white: 0.0, alpha: 0.1).CGColor
		view.layer.borderWidth = 1.0
		view.layer.masksToBounds = true
		addSubview(view)
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "setNeedsLayout", name: STBTableViewIndexLayoutDidChange, object: nil)
		setNeedsLayout()
	}
	
	override func layoutSubviews() {
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
	
	func createLabels() {
		for label in labels {
			label.removeFromSuperview()
		}
		labels.removeAll()
		for (tag, title) in enumerate(titles) {
			var label = UILabel(frame: CGRectZero)
			label.backgroundColor = UIColor.clearColor()
			label.font = UIFont.boldSystemFontOfSize(10.0)
			label.textColor = view.tintColor
			label.textAlignment = .Center
			label.text = title
			label.tag = tag
			view.addSubview(label)
			labels += [label]
		}
	}
	
	func setNewIndex(var #point: CGPoint) {
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
	
	func hideIndex() {
		visible = false
	}
	
	func showIndex() {
		visible = true
	}
	
	func flashIndex() {
		view.alpha = 1.0
		NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "hideIndex", userInfo: nil, repeats: false)
	}
	
	override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
		let touch = touches.anyObject() as UITouch
		let location = touch.locationInView(self)
		setNewIndex(point: location)
		visible = true
	}
	
	override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
		visible = false
	}
	
	func handleGesture(gesture: UIGestureRecognizer) {
		let location = gesture.locationInView(self)
		setNewIndex(point: location)
		visible = !(gesture.state == .Ended)
	}
	
}
