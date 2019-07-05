//
//  MasterViewController.swift
//  IndexTest
//
//  Created by Nicolas Gomollon on 6/20/14.
//  Copyright (c) 2014 Techno-Magic. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController, STBTableViewIndexDelegate {
	
	var sections: Array<String> = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "#"]
	var indexView: STBTableViewIndex = .init()
	
	
	override func awakeFromNib() {
		super.awakeFromNib()
		indexView.delegate = self
		indexView.titles = sections
		navigationController?.view.addSubview(indexView)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		indexView.flashIndex()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	// MARK: - Table View
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return sections.count
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return sections[section]
	}
	
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 30.0
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 7
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
		
		let section: String = sections[indexPath.section]
		cell.textLabel?.text = "I’m cell \(indexPath.row + 1) in section \(section)"
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		// Implement your own `tableView:didSelectRowAtIndexPath:` here.
	}
	
	// MARK: - Section Title Bar
	
	func tableViewIndexChanged(_ index: Int, title: String) {
		let indexPath = IndexPath(row: 0, section: index)
		tableView.scrollToRow(at: indexPath, at: .top, animated: false)
	}
	
	func tableViewIndexTopLayoutGuideLength() -> CGFloat {
		// In most cases, just this line should be fine. Otherwise, uncomment the code below.
		return topLayoutGuide.length + tableView(tableView, heightForHeaderInSection: 0)
//		var topHeight: CGFloat = 0.0
//		let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
//		topHeight += statusBarHeight
//		if let navigationController = navigationController {
//			let navBarHeight = navigationController.navigationBar.frame.size.height
//			topHeight += navBarHeight
//		}
//		return topHeight
	}
	
	func tableViewIndexBottomLayoutGuideLength() -> CGFloat {
		// In most cases, just this line should be fine. Otherwise, uncomment the code below.
		return bottomLayoutGuide.length
//		var bottomHeight: CGFloat = 0.0
//		if let tabBarController = tabBarController {
//			let tabBarHeight = tabBarController.tabBar.frame.size.height
//			bottomHeight += tabBarHeight
//		}
//		return bottomHeight
	}
	
}

