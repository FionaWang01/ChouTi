//
//  CodeSnippet_UITableViewCell.swift
//  Pods
//
//  Created by Honghao Zhang on 2015-11-20.
//
//

//class <#Cell#>: UITableViewCell {
//	
//	let <#view#> = UIView()

//	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
//		super.init(style: style, reuseIdentifier: reuseIdentifier)
//		commonInit()
//	}
//	
//	required init?(coder aDecoder: NSCoder) {
//		super.init(coder: aDecoder)
//		commonInit()
//	}
//	
//	private func commonInit() {
//		setupViews()
//		setupConstraints()
//	}
//
//	private func setupViews() {
//		// TODO: Setup view hierarchy
//		<#view#>.translatesAutoresizingMaskIntoConstraints = false
//		contentView.addSubview(<#view#>)
//	}
//
//	private func setupConstraints() {
//		preservesSuperviewLayoutMargins = false
//		layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//		contentView.preservesSuperviewLayoutMargins = false
//		contentView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//
//		let views = [
//			"view" : <#view#>
//		]
//
//		let metrics: [String : CGFloat] = [
//			"vertical_spacing" : 4.0
//		]
//
//		var constraints = [NSLayoutConstraint]()
//
//		// TODO: Add constraints
//		constraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-[view]-|", options: [], metrics: metrics, views: views)
//
//		NSLayoutConstraint.activateConstraints(constraints)
//	}
//}
//
//extension <#Cell#> : TableViewCellRegistrable {
//    public class func estimatedHeight() -> CGFloat {
//        return 44.0
//    }
//    
//    public class func identifier() -> String {
//        return String(self)
//    }
//    
//    public class func registerInTableView(tableView: UITableView) {
//        tableView.registerClass(self, forCellReuseIdentifier: identifier())
//    }
//    
//    public class func registerNib(nib: UINib, inTableView tableView: UITableView) {
//        tableView.registerNib(nib, forCellReuseIdentifier: identifier())
//    }
//    
//    public class func deregisterInTableView(tableView: UITableView) {
//        tableView.registerClass(nil, forCellReuseIdentifier: identifier())
//    }
//    
//    public class func deregisterNibInTableView(tableView: UITableView) {
//        tableView.registerNib(nil, forCellReuseIdentifier: identifier())
//    }
//}




// MARK: - Common Usage
//cell.selectionStyle = .None
