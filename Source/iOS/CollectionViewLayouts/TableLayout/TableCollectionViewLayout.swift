//
//  TableLayout.swift
//  ChouTi
//
//  Created by Honghao Zhang on 3/1/15.
//

import UIKit

// This layout provides a grid like layout (or excel table?)

//   #  |  title |   date   |   detail
// -----+--------+----------+-----------
//   1  |  foo   |    bar   |  something
//   2  |  foo   |    bar   |   (image)
//   3  |  foo   |    bar   |  something

public protocol TableLayoutDataSource : class {
	/**
	Get number of columns
	
	- parameter tableLayout: the tableLayout
	
	- returns: number of columns
	*/
	func numberOfColumnsInTableLayout(tableLayout: TableCollectionViewLayout) -> Int
	
	/**
	Get number of rows in one column
	
	- parameter tableLayout: the tableLayout
	- parameter column:      column index, from 0 ... numberOfColumns
	
	- returns: number of rows in the column
	*/
	func tableLayout(tableLayout: TableCollectionViewLayout, numberOfRowsInColumn column: Int) -> Int
	
	/**
	Preferred size for the cell at the column and the row
	
	- parameter tableLayout: the tableLayout
	- parameter column:      column index, from 0 ... numberOfColumns
	- parameter row:         row index, begin with 0
	
	- returns: Size for the cell
	*/
	func tableLayout(tableLayout: TableCollectionViewLayout, sizeForColumn column: Int, row: Int) -> CGSize
}

public class TableCollectionViewLayout: UICollectionViewLayout {
    // SeparatorLine is decorationViews
	
	// MARK: - Appearance Customization	
    public var horizontalPadding: CGFloat = 5.0
    public var verticalPadding: CGFloat = 1.0
    public var separatorLineWidth: CGFloat = 1.0
    public var separatorColor = UIColor(white: 0.0, alpha: 0.5) {
        didSet {
            TableCollectionViewSeparatorView.separatorColor = separatorColor
        }
    }
	
	// MARK: - DataSource/Delegate
    public weak var dataSourceTableLayout: TableLayoutDataSource!
	
	public func numberOfColumns() -> Int {
		return dataSourceTableLayout.numberOfColumnsInTableLayout(self)
	}
	public func numberOfRowsInColumn(column: Int) -> Int {
		return dataSourceTableLayout.tableLayout(self, numberOfRowsInColumn: column)
	}
	
    private var maxWidthForColumn = [CGFloat]()
	private var maxHeightForRow = [CGFloat]()
	
	private var maxNumberOfRows: Int = 0
	/// Max height, not include paddings/separatorWidth
	private var maxHeight: CGFloat = 0
    
    private let separatorViewKind = "Separator"
	
	// MARK: - Init
	public override init() {
        super.init()
		commmonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
		commmonInit()
    }
	
	private func commmonInit() {
		self.registerClass(TableCollectionViewSeparatorView.self, forDecorationViewOfKind: separatorViewKind)
	}
	
	// MARK: - Override
    public override func prepareLayout() {
        buildMaxWidthsHeight()
    }
    
    public override func collectionViewContentSize() -> CGSize {
        var width: CGFloat = maxWidthForColumn.reduce(0, combine: +)
        width += CGFloat(numberOfColumns() - 1) * separatorLineWidth
        width += CGFloat(numberOfColumns()) * horizontalPadding * 2
		let maxContentHeight = maxHeight + separatorLineWidth + verticalPadding * 2 * CGFloat(maxNumberOfRows)
        return CGSizeMake(width, maxContentHeight)
    }
        
    public override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        return cellAttrisForIndexPath(indexPath)
    }
    
    public override func layoutAttributesForDecorationViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        if elementKind == separatorViewKind {
            if indexPath.item == 0 {
				let attrs = UICollectionViewLayoutAttributes(forDecorationViewOfKind: elementKind, withIndexPath: indexPath)
				// Section 0 decoration view (separator line) is horizontal line
                if indexPath.section == 0 {
                    let x: CGFloat = 0
                    let y = maxHeightForRow[0] + verticalPadding * 2
                    let width = collectionViewContentSize().width
                    attrs.frame = CGRectMake(x, y, width, separatorLineWidth)
                } else {
                    var x: CGFloat = 0
                    for sec in 0 ..< indexPath.section {
                        x += maxWidthForColumn[sec] + separatorLineWidth + horizontalPadding * 2
                    }
                    x -= separatorLineWidth
                    let y: CGFloat = 0.0
                    let width = separatorLineWidth
                    let height = collectionViewContentSize().height
                    attrs.frame = CGRectMake(x, y, width, height)
                }
				
				return attrs
            }
        }
		
		return nil
    }
    
    public override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attrs = [UICollectionViewLayoutAttributes]()
        let cellIndexPaths = cellIndexPathsForRect(rect)
        for indexPath in cellIndexPaths {
            attrs.append(cellAttrisForIndexPath(indexPath))
        }
		
		let columns = numberOfColumns()
        for sec in 0 ..< columns {
			let rows = numberOfRowsInColumn(sec)
            for row in 0 ..< rows {
				if let attr = layoutAttributesForDecorationViewOfKind(separatorViewKind, atIndexPath: NSIndexPath(forItem: row, inSection: sec)) {
					attrs.append(attr)
				}
            }
        }
        
        return attrs
    }
    
    public override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return false
    }
}

// MARK: Helper functions
extension TableCollectionViewLayout {
	func buildMaxWidthsHeight() {
        maxWidthForColumn.removeAll()
		maxHeight = 0
		
		let columns = numberOfColumns()
        for col in 0 ..< columns {
			var maxWidth: CGFloat = 0
			var height: CGFloat = 0
			let rows = numberOfRowsInColumn(col)
            for row in 0 ..< rows {
				let size = dataSourceTableLayout.tableLayout(self, sizeForColumn: col, row: row)
				let width = size.width
				height += size.height
                if width > maxWidth {
                    maxWidth = width
                }
            }
			
            maxWidthForColumn.append(maxWidth)
			
			if height > maxHeight {
				maxHeight = height
			}
        }
		
		// Calculate max number of rows
		maxNumberOfRows = 0
		for col in 0 ..< columns {
			let rows = numberOfRowsInColumn(col)
			if rows > maxNumberOfRows {
				maxNumberOfRows = rows
			}
		}
		
		// Calculate max height for row
		maxHeightForRow.removeAll()
		for row in 0 ..< maxNumberOfRows {
			var maxHeight: CGFloat = 0
			for col in 0 ..< columns {
				let rowsInColumn = numberOfRowsInColumn(col)
				if row < rowsInColumn {
					let size = dataSourceTableLayout.tableLayout(self, sizeForColumn: col, row: row)
					if size.height > maxHeight {
						maxHeight = size.height
					}
				}
			}
			maxHeightForRow.append(maxHeight)
		}
    }
	
    private func cellAttrisForIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes {
        let attrs = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
		// Calculate Cell size with max width and max height
		let maxWidth = maxWidthForColumn[indexPath.section] + horizontalPadding * 2
		let maxHeight = maxHeightForRow[indexPath.row] + verticalPadding * 2
		
		var x: CGFloat = 0
		for sec in 0 ..< indexPath.section {
			x += maxWidthForColumn[sec] + separatorLineWidth + horizontalPadding * 2
		}
		
		var y: CGFloat = 0
		for row in 0 ..< indexPath.item {
			y += maxHeightForRow[row] + verticalPadding * 2
			if row == 0 {
				y += separatorLineWidth
			}
		}
		
		// Until now, we have frame for full size cell.
		// the frame for the cell should have size from dataSource and put it in center
		let size = dataSourceTableLayout.tableLayout(self, sizeForColumn: indexPath.section, row: indexPath.item)
        attrs.bounds = CGRectMake(0, 0, size.width, size.height)
        attrs.center = CGPoint(x: x + maxWidth / 2.0, y: y + maxHeight / 2.0)
		
        return attrs
    }

    private func cellIndexPathsForRect(rect: CGRect) -> [NSIndexPath] {
        let rectLeft: CGFloat = rect.origin.x
        let rectRight: CGFloat = rect.origin.x + rect.width
        let rectTop: CGFloat = rect.origin.y
        let rectBottom: CGFloat = rect.origin.y + rect.height
        
        var fromSectionIndex = -1
        var endSectionIndex = -1
        
        // Determin section
        var calX: CGFloat = 0.0
		let columns = numberOfColumns()
        for col in 0 ..< columns {
            let nextWidth = maxWidthForColumn[col] + horizontalPadding * 2 + separatorLineWidth
            if calX < rectLeft && rectLeft <= (calX + nextWidth) {
                fromSectionIndex = col
            }
            if calX < rectRight && rectRight <= (calX + nextWidth) {
                endSectionIndex = col
                break
            }
            calX += nextWidth
        }
        if fromSectionIndex == -1 {
            fromSectionIndex = 0
        }
        if endSectionIndex == -1 {
            endSectionIndex = columns - 1
        }
		
		// Create array of indexPaths
		var indexPaths = [NSIndexPath]()
		
		// Determin row
		for col in fromSectionIndex ... endSectionIndex {
			var fromRowIndex = -1
			var endRowIndex = -1
			var calY: CGFloat = 0.0
			let rowsCount = numberOfRowsInColumn(col)
			
			for row in 0 ..< rowsCount {
				var nextHeight = maxHeightForRow[row]
				if row == 0 {
					nextHeight += separatorLineWidth
				}
				if calY < rectTop && rectTop <= (calY + nextHeight) {
					fromRowIndex = row
				}
				if calY < rectBottom && rectBottom <= (calY + nextHeight) {
					endRowIndex = row
					break
				}
				calY += nextHeight
			}
			
			if fromRowIndex == -1 {
				fromRowIndex = 0
			}
			if endRowIndex == -1 {
				endRowIndex = rowsCount - 1
			}
			
			for row in fromRowIndex ... endRowIndex {
				indexPaths.append(NSIndexPath(forItem: row, inSection: col))
			}
		}
		
        return indexPaths
    }
}
