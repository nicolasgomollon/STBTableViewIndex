//
//  STBTableViewIndex.swift
//  STBTableViewIndex
//
//  Objective-C code Copyright (c) 2013 Benjamin Kreeger. All rights reserved.
//  Swift adaptation Copyright (c) 2014 Nicolas Gomollon. All rights reserved.
//

import Foundation
import UIKit

public let STBTableViewIndexLayoutDidChange: NSNotification.Name = UIDevice.orientationDidChangeNotification

public protocol STBTableViewIndexDelegate: NSObjectProtocol {
	
	func tableViewIndexChanged(_ index: Int, title: String)
	
	func tableViewIndexTopLayoutGuideLength() -> CGFloat
	
	func tableViewIndexBottomLayoutGuideLength() -> CGFloat
	
}

open class STBTableViewIndex: UIControl {
	
	open weak var delegate: STBTableViewIndexDelegate!
	fileprivate var panGestureRecognizer: UIPanGestureRecognizer!
	fileprivate var tapGestureRecognizer: UITapGestureRecognizer!
	fileprivate var feedbackGenerator: AnyObject?
	
	open var currentIndex: Int = 0
	open var currentTitle: String { return titles[currentIndex] }
	
	open var view: UIView = UIView(frame: .zero)
	
	open var titles: [String] {
		didSet {
			createLabels()
		}
	}
	
	open var autoHides: Bool = true
	open var visible: Bool {
		didSet {
			UIView.animate(withDuration: 0.2, animations: {
				self.view.alpha = self.visible ? 1.0 : 0.0
			})
		}
	}
	
	open var labels: [UILabel] = .init()
	
	fileprivate var canAutoHide: Bool {
		guard !UIAccessibility.isVoiceOverRunning else { return false }
		return autoHides
	}
	
	fileprivate var width: CGFloat { return 16.0 }
	fileprivate var horizontalPadding: CGFloat { return 5.0 }
	fileprivate var verticalPadding: CGFloat { return 5.0 }
	fileprivate var endPadding: CGFloat { return 3.0 }
	
	fileprivate var controlSizeWidth: CGFloat { return width + (horizontalPadding * 2.0) }
	fileprivate var controlOriginX: CGFloat {
		let superviewWidth: CGFloat = superview?.frame.size.width ?? UIScreen.main.bounds.size.width
		return superviewWidth - controlSizeWidth
	}
	fileprivate var controlOriginY: CGFloat {
		return delegate?.tableViewIndexTopLayoutGuideLength() ?? 0.0
	}
	fileprivate var controlSizeHeight: CGFloat {
		var sizeHeight: CGFloat = 0.0
		let screenHeight: CGFloat = UIScreen.main.bounds.size.height
		sizeHeight = screenHeight
		sizeHeight -= controlOriginY
		sizeHeight -= delegate?.tableViewIndexBottomLayoutGuideLength() ?? 0.0
		return sizeHeight
	}
	
	fileprivate var controlFrame: CGRect {
		return CGRect(x: controlOriginX, y: controlOriginY, width: controlSizeWidth, height: controlSizeHeight)
	}
	
	fileprivate var controlBounds: CGRect {
		return CGRect(x: 0.0, y: 0.0, width: controlSizeWidth, height: controlSizeHeight)
	}
	
	fileprivate var viewFrame: CGRect {
		return controlBounds.insetBy(dx: horizontalPadding, dy: verticalPadding)
	}
	
	fileprivate var viewBounds: CGRect {
		return CGRect(x: 0.0, y: 0.0, width: viewFrame.size.width, height: viewFrame.size.height)
	}
	
	
	public convenience init() {
		self.init(frame: .zero)
	}
	
	public override init(frame: CGRect) {
		titles = .init()
		visible = true
		super.init(frame: .zero)
		initialize()
	}
	
	public required init?(coder aDecoder: NSCoder) {
		titles = .init()
		visible = true
		super.init(coder: aDecoder)
		initialize()
	}
	
	fileprivate func initialize() {
		panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(STBTableViewIndex._handleGesture(_:)))
		addGestureRecognizer(panGestureRecognizer)
		
		tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(STBTableViewIndex._handleGesture(_:)))
		addGestureRecognizer(tapGestureRecognizer)
		
		view.backgroundColor = .white
		view.layer.borderColor = UIColor(white: 0.0, alpha: 0.1).cgColor
		view.layer.borderWidth = 1.0
		view.layer.masksToBounds = true
		addSubview(view)
		
		isAccessibilityElement = true
		shouldGroupAccessibilityChildren = true
		accessibilityLabel = NSLocalizedString("STBTableViewIndex-LABEL", tableName: "STBTableViewIndex", bundle: .main, value: "Table index", comment: "")
		accessibilityTraits = [.adjustable]
		
		NotificationCenter.default.addObserver(self, selector: #selector(accessibilityVoiceOverStatusChanged), name: UIAccessibility.voiceOverStatusDidChangeNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(setNeedsLayout), name: STBTableViewIndexLayoutDidChange, object: nil)
		setNeedsLayout()
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	open override func layoutSubviews() {
		super.layoutSubviews()
		
		frame = controlFrame
		view.frame = viewFrame
		view.layer.cornerRadius = view.frame.width / 2.0
		
		var labelOriginY: CGFloat = endPadding
		let labelWidth: CGFloat = view.frame.width
		let labelHeight: CGFloat = (view.frame.height - (endPadding * 2.0)) / CGFloat(labels.count)
		
		for label in labels {
			let labelFrame = CGRect(x: 0.0, y: labelOriginY, width: labelWidth, height: labelHeight)
			label.frame = labelFrame.integral
			labelOriginY += labelHeight
		}
	}
	
	fileprivate func createLabels() {
		for label in labels {
			label.removeFromSuperview()
		}
		labels.removeAll()
		for (tag, title) in titles.enumerated() {
			let label: UILabel = .init(frame: .zero)
			label.backgroundColor = .clear
			label.font = .boldSystemFont(ofSize: 10.0)
			label.textColor = view.tintColor
			label.textAlignment = .center
			label.text = title
			label.tag = tag
			view.addSubview(label)
			labels += [label]
		}
	}
	
	fileprivate func setNewIndex(point p: CGPoint) {
		var point: CGPoint = p
		point.x = view.frame.width / 2.0
		for label in labels {
			guard label.frame.contains(point),
				label.tag != currentIndex else { continue }
			currentIndex = label.tag
			delegate?.tableViewIndexChanged(currentIndex, title: currentTitle)
			hapticFeedbackSelectionChanged()
		}
	}
	
	@objc open func hideIndex() {
		visible = false
	}
	
	open func showIndex() {
		visible = true
	}
	
	open func flashIndex() {
		view.alpha = 1.0
		guard canAutoHide else { return }
		Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(hideIndex), userInfo: nil, repeats: false)
	}
	
	open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		hapticFeedbackSetup()
		guard let location: CGPoint = touches.first?.location(in: self) else { return }
		setNewIndex(point: location)
		guard canAutoHide else { return }
		visible = true
	}
	
	open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		hapticFeedbackFinalize()
		guard canAutoHide else { return }
		visible = false
	}
	
	@objc internal func _handleGesture(_ gesture: UIGestureRecognizer) {
		switch gesture.state {
		case .began:
			hapticFeedbackSetup()
		case .ended,
			 .cancelled,
			 .failed:
			hapticFeedbackFinalize()
		default:
			break
		}
		let location: CGPoint = gesture.location(in: self)
		setNewIndex(point: location)
		guard canAutoHide else { return }
		visible = !(gesture.state == .ended)
	}
	
	@objc internal func accessibilityVoiceOverStatusChanged() {
		guard autoHides else { return }
		visible = UIAccessibility.isVoiceOverRunning
	}
	
	open override func accessibilityElementDidLoseFocus() {
		accessibilityValue = nil
	}
	
	open override func accessibilityIncrement() {
		if currentIndex < (labels.count - 1) {
			currentIndex += 1
		}
		delegate?.tableViewIndexChanged(currentIndex, title: currentTitle)
		accessibilityValue = currentTitle.lowercased()
	}
	
	open override func accessibilityDecrement() {
		if currentIndex > 0 {
			currentIndex -= 1
		}
		delegate?.tableViewIndexChanged(currentIndex, title: currentTitle)
		accessibilityValue = currentTitle.lowercased()
	}
	
}

extension STBTableViewIndex {
	
	fileprivate func hapticFeedbackSetup() {
		guard #available(iOS 10.0, *) else { return }
		let feedbackGenerator: UISelectionFeedbackGenerator = .init()
		feedbackGenerator.prepare()
		self.feedbackGenerator = feedbackGenerator
	}
	
	fileprivate func hapticFeedbackSelectionChanged() {
		guard #available(iOS 10.0, *),
			let feedbackGenerator: UISelectionFeedbackGenerator = self.feedbackGenerator as? UISelectionFeedbackGenerator else { return }
		feedbackGenerator.selectionChanged()
		feedbackGenerator.prepare()
	}
	
	fileprivate func hapticFeedbackFinalize() {
		guard #available(iOS 10.0, *) else { return }
		self.feedbackGenerator = nil
	}
	
}
