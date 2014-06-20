//
//  STBTableViewIndex.swift
//  STBTableViewIndex
//
//  Objective-C code Copyright (c) 2013 Benjamin Kreeger. All rights reserved.
//  Swift adaptation Copyright (c) 2014 Nicolas Gomollon. All rights reserved.
//

import Foundation
import UIKit

protocol STBTableViewIndexDelegate: NSObjectProtocol {
	
	func tableViewIndexChanged(index: Int, title: String)
	
}

class STBTableViewIndex: UIControl { }
