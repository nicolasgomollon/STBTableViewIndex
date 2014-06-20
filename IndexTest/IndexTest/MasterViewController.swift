//
//  MasterViewController.swift
//  IndexTest
//
//  Created by Nicolas Gomollon on 6/20/14.
//  Copyright (c) 2014 Techno-Magic. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {
	
	var sections = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "#"]
	
	
	override func awakeFromNib() {
		super.awakeFromNib()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
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
	
//	
	
}

