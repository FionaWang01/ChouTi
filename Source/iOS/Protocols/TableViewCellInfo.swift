//
//  TableViewCellInfo.swift
//  ChouTi
//
//  Created by Honghao Zhang on 2015-08-11.
//

import UIKit

// Use `class` instead of `static` to let subclass override class method
// Reference: http://stackoverflow.com/questions/29636633/static-vs-class-functions-variables-in-swift-classes

public protocol TableViewCellInfo {
	// return NSStringFromClass(<#Cell#>.self)
    static func identifier() -> String
	
	// return <#RowHeight#>
    static func estimatedRowHeight() -> CGFloat
	
	// tableView.registerClass(<#Cell#>.self, forCellReuseIdentifier: <#Cell#>.identifier())
    static func registerInTableView(tableView: UITableView)
}