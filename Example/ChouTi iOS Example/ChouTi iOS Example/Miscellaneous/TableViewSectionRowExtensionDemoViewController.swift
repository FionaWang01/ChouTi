//
//  TableViewSectionRowExtensionDemoViewController.swift
//  ChouTi iOS Example
//
//  Created by Honghao Zhang on 2015-12-02.
//  Copyright © 2015 Honghao Zhang. All rights reserved.
//

import UIKit
import ChouTi

class TableViewSectionRowExtensionDemoViewController: UIViewController {

    let tableView = UITableView(frame: CGRect.zero, style: {
        return (Bool.random() ? .Grouped : .Plain) }()
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "TableView+SectionRow"
        
		tableView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(tableView)
		tableView.constrainToFullSizeInSuperview()
		tableView.rowHeight = UITableViewAutomaticDimension
		
		tableView.sections = []
		tableView.sections?.append(TableViewSection(headerTitle: "Section1",
			rows: [
				TableViewRow(title: "Cell with .Value1 Style",
					subtitle: "Detail Text",
					cellInitialization: { indexPath in
						var cell = self.tableView.dequeueReusableCellWithIdentifier(TableViewCell.identifier())
						if cell == nil {
							cell = TableViewCell(style: .Value1, reuseIdentifier: TableViewCell.identifier())
						}
						return cell!
					},
					tableView: tableView
				),
				TableViewRow(title: "Cell with .Value2 Style",
					subtitle: "Detail Text",
					cellInitialization: { indexPath in
						return self.tableView.dequeueReusableCellWithIdentifier(TableViewCellValue2.identifier())!
					},
					tableView: tableView
				),
				TableViewRow(title: "Cell with default Style (.Subtitle Style)",
					subtitle: "By default Cell Style is .Subtitle",
					tableView: tableView
				),
				TableViewRow(title: "我是一个Cell的主标题",
					subtitle: "我是副标题",
					tableView: tableView)
			],
			tableView: tableView)
		)
		
		var section2 = TableViewSection(headerTitle: "I'm Section2 Header Text",
			rows: [
				TableViewRow(title: "Customized Cell",
					subtitle: "Subtitle...",
					cellInitialization: { (indexPath) -> UITableViewCell in
						var cell = self.tableView.dequeueReusableCellWithIdentifier(TableViewCell.identifier())
						if cell == nil {
							cell = TableViewCell(style: .Subtitle, reuseIdentifier: TableViewCell.identifier())
						}
						
						return cell!
					},
					cellConfiguration: { (cell) -> Void in
						(cell as? TableViewCell)?.cellHeight = 200
						cell.textLabel?.text = "Click on Me"
						cell.textLabel?.font = UIFont.boldSystemFontOfSize(22)
						
						cell.detailTextLabel?.text = "Now height is 200.0, it is calculated by constraints automatically!"
						cell.detailTextLabel?.font = UIFont.systemFontOfSize(18)
						cell.detailTextLabel?.numberOfLines = 0
						cell.backgroundColor = UIColor.random()
					},
					tableView: tableView,
					cellSelectAction: { (indexPath, cell) -> Void in
						self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
						cell?.textLabel?.textColor = UIColor.random()
						cell?.detailTextLabel?.textColor = UIColor.random()
						cell?.backgroundColor = UIColor.random()
					},
					cellDeselectAction: { (indexPath, cell) -> Void in
						//
				}),
				TableViewRow(title: "",
					cellInitialization: { (indexPath) -> UITableViewCell in
						var cell = self.tableView.dequeueReusableCellWithIdentifier(SeparatorCell.identifier())
						if cell == nil {
							cell = TableViewCell(style: .Default, reuseIdentifier: SeparatorCell.identifier())
						}
						
						(cell as? SeparatorCell)?.separatorView.backgroundColor = UIColor.redColor()
						
						cell?.layoutMargins = UIEdgeInsets(top: 1, left: 0, bottom: 1, right: 0)
						cell?.contentView.layoutMargins = UIEdgeInsets(top: 1, left: 0, bottom: 1, right: 0)
						
						// FIXME: Height is not settable
						
						return cell!
					},
					tableView: tableView
				)
			],
			tableView: tableView
		)
		section2.footerTitle = "I'm Section2 Footer Text"
		
		tableView.sections?.append(section2)
	}
}
