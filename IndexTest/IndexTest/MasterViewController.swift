//
//  MasterViewController.swift
//  IndexTest
//
//  Created by Nicolas Gomollon on 6/20/14.
//  Copyright (c) 2014 Techno-Magic. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController, STBTableViewIndexDelegate {
	
	var sections = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "#"]
	var indexView = STBTableViewIndex()
	
	
	override func awakeFromNib() {
		super.awakeFromNib()
		indexView.delegate = self
		indexView.titles = sections
		navigationController.view.addSubview(indexView)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		indexView.flashIndex()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	// #pragma mark - Table View
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return sections.count
	}
	
	override func tableView(tableView: UITableView!, titleForHeaderInSection section: Int) -> String! {
		return sections[section]
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 7
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
		
		let section = sections[indexPath.section]
		cell.textLabel.text = "I’m cell \(indexPath.row + 1) in section \(section)"
		
		return cell
	}
	
	override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		// Implement your own `tableView:didSelectRowAtIndexPath:` here.
	}
	
	// #pragma mark - Section Title Bar
	
	func tableViewIndexChanged(index: Int, title: String) {
		let indexPath = NSIndexPath(forRow: 0, inSection: index)
		tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: false)
	}
	
	func tableViewIndexTopLayoutGuideLength() -> Double {
		// In most cases, just this line should be fine. Otherwise, uncomment the code below.
		return topLayoutGuide.length
//		var topHeight = 0.0
//		let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.size.height
//		topHeight += statusBarHeight
//		if let navigationController = navigationController {
//			let navBarHeight = navigationController.navigationBar.frame.size.height
//			topHeight += navBarHeight
//		}
//		return topHeight
	}
	
	func tableViewIndexBottomLayoutGuideLength() -> Double {
		// In most cases, just this line should be fine. Otherwise, uncomment the code below.
		return bottomLayoutGuide.length
//		var bottomHeight = 0.0
//		if let tabBarController = tabBarController {
//			let tabBarHeight = tabBarController.tabBar.frame.size.height
//			bottomHeight += tabBarHeight
//		}
//		return bottomHeight
	}
	
}

