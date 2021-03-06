//
//  PgaeViewController.swift
//  Pods
//
//  Created by Honghao Zhang on 2015-10-05.
//
//

import UIKit

public protocol PageViewControllerDataSource : class {
	func numberOfViewControllersInPageViewController(pageViewController: PageViewController) -> Int
	func pageViewController(pageViewController: PageViewController, viewControllerForIndex index: Int) -> UIViewController
}

public protocol PageViewControllerDelegate : class {
	/**
	Page view controller
	
	- parameter pageViewController: the page view controller
	- parameter selectedIndex:      current selected index
	- parameter offsetPercent:      offset in percent, 0 means the selected view controller is in center. -1.0 means left view controller of selected view controller is in center
	*/
	func pageViewController(pageViewController: PageViewController, didScrollWithSelectedIndex selectedIndex: Int, offsetPercent: CGFloat)
	func pageViewController(pageViewController: PageViewController, didSelectIndex selectedIndex: Int, selectedViewController: UIViewController)
}

// FIXME: Rotations
// FIXME: Potention bug: set selected index animated while draging

public class PageViewController : UIViewController {
	// TODO: Handling rotations
	
	// MARK: - Public
	public var scrollEnabled: Bool {
        get { return pageScrollView.scrollEnabled }
        set { pageScrollView.scrollEnabled = newValue }
	}
	
	/// Current selected index.
	public var selectedIndex: Int = -1 {
		didSet {
			setSelectedIndex(selectedIndex, animated: false)
		}
	}
	
	/// Current selected view controller
	public var selectedViewController: UIViewController? {
		return viewControllerForIndex(selectedIndex)
	}
	
	/// PageViewControllerDataSource, set this property will ignore viewControllers
	public weak var dataSource: PageViewControllerDataSource? {
		didSet {
			if let dataSource = dataSource where isViewLoaded() {
				setupViewControllersWithDataSource(dataSource)
			}
		}
	}
	
	/// child view controllers, set this peoperty will ignore dataSource
	public var viewControllers: [UIViewController]? {
		willSet {
			if let newValue = newValue {
				dataSource = nil
				willReplaceOldViewControllers(viewControllers, withNewViewControllers: newValue)
				setupChildViewControllerViews(newValue)
			}
		}
		didSet {
			if let viewControllers = viewControllers {
				_selectedIndex = 0
				pageScrollView.contentOffset = CGPoint(x: 0, y: pageScrollView.contentOffset.y)
				didReplaceOldViewControllers(oldValue, withNewViewControllers: viewControllers)
			}
		}
	}
	
	/// PageViewControllerDelegate
	public weak var delegate: PageViewControllerDelegate?
	
	
	// MARK: - Private
	
	/// internal selected index, this could be set before selectedIndex is set
	private var _selectedIndex: Int = -1 {
		didSet {
			selectedIndex = _selectedIndex
			if _selectedIndex < viewControllersCount {
				delegate?.pageViewController(self, didSelectIndex: _selectedIndex, selectedViewController: _selectedViewController!)
			}
		}
	}
	
	/// internal selected view controller
	private var _selectedViewController: UIViewController? {
		return viewControllerForIndex(_selectedIndex)
	}
	
	/// View controllers that loaded, this is used when dataSource used
	private var loadedViewControllers: [UIViewController]!
	
	// Count
	private var lastRecoredViewControllersCount: Int = 0
	private var viewControllersCount: Int {
		if let viewControllers = viewControllers {
			return viewControllers.count
		} else {
			if !isInTransition {
				let updatedCount = dataSource!.numberOfViewControllersInPageViewController(self)
				if lastRecoredViewControllersCount != updatedCount {
					pageScrollView.contentSize = CGSize(width: view.bounds.width * CGFloat(updatedCount), height: 0)
					lastRecoredViewControllersCount = updatedCount
				}
			}
			return lastRecoredViewControllersCount
		}
	}
	
	
	
	// MARK: - Dragging related
	private var isDragging: Bool = false
	private var beginDraggingContentOffsetX: CGFloat? {
		didSet {
			if let offsetX = beginDraggingContentOffsetX {
				// Round off begin content offset x
				if offsetX % view.bounds.width == 0 { return }
				beginDraggingContentOffsetX = CGFloat(Int(offsetX) / Int(view.bounds.width)) * view.bounds.width
			}
		}
	}
	private var willEndDraggingTargetContentOffsetX: CGFloat?
	
	private var draggingOffsetX: CGFloat? { return beginDraggingContentOffsetX == nil ? nil : pageScrollView.contentOffset.x - beginDraggingContentOffsetX! }
	private var draggingForward: Bool? {
		guard let draggingOffsetX = draggingOffsetX else { return nil }
		
		if draggingOffsetX == 0 {
			return nil
		} else {
			return draggingOffsetX > 0
		}
	}
	
	
	
	// MARK: - Properties
	var pageScrollView = UIScrollView()
	
	/// When dragging/scrolling/appearing ongoing, this property will be true
	private var isInTransition: Bool = false
	
	private var isVisible: Bool { return isViewLoaded() && (view.window != nil) }

    
	
	// MARK: - SetSelectedIndex
	private var setSelectedIndexCompletion: (Bool -> Void)?
	public func setSelectedIndex(index: Int, animated: Bool, completion: (Bool -> Void)? = nil) {
		if index < 0 || index >= viewControllersCount {
			return
		}
		if _selectedIndex == index { return }
		
        let targetContentOffset = CGPoint(x: CGFloat(index) * view.bounds.width, y: pageScrollView.contentOffset.y)
		pageScrollView.setContentOffset(targetContentOffset, animated: animated)
		if animated {
            // scrollViewDidEndScrollingAnimation: will be called when scrolling animation concludes
			isInTransition = true
			if isVisible {
				_selectedViewController?.zhh_beginAppearanceTransition(false, animated: true)
				viewControllerForIndex(index)?.zhh_beginAppearanceTransition(true, animated: true)
			}
			setSelectedIndexCompletion = completion
		} else {
			if isVisible {
				_selectedViewController?.zhh_beginAppearanceTransition(false, animated: false)
				_selectedViewController?.zhh_endAppearanceTransition()
				
				viewControllerForIndex(index)?.zhh_beginAppearanceTransition(true, animated: false)
				viewControllerForIndex(index)?.zhh_endAppearanceTransition()
			}
			_selectedIndex = index
			completion?(true)
		}
	}
    
    public func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        isInTransition = false
        loadedViewControllers.filter { $0.isAppearing != nil }.forEach { $0.zhh_endAppearanceTransition() }
        _selectedIndex = Int(scrollView.contentOffset.x) / Int(view.bounds.width)
        setSelectedIndexCompletion?(true)
        setSelectedIndexCompletion = nil
    }
}


// MARK: - Override
extension PageViewController {
	public override func shouldAutomaticallyForwardAppearanceMethods() -> Bool {
		return false
	}
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		setupViews()
		
		if let dataSource = dataSource {
			setupViewControllersWithDataSource(dataSource)
		} else if loadedViewControllers == nil {
			fatalError("dataSource is nil and no view controllers provided when view loaded")
		}
	}
	
	private func setupViews() {
		view.addSubview(pageScrollView)
		pageScrollView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
		pageScrollView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
		pageScrollView.delegate = self
		
		pageScrollView.pagingEnabled = true
		pageScrollView.bounces = true
		pageScrollView.alwaysBounceHorizontal = true
		pageScrollView.alwaysBounceVertical = false
		pageScrollView.directionalLockEnabled = true
		pageScrollView.scrollsToTop = false
		pageScrollView.showsHorizontalScrollIndicator = false
		pageScrollView.showsVerticalScrollIndicator = false
		
		pageScrollView.contentInset = UIEdgeInsetsZero
		automaticallyAdjustsScrollViewInsets = false
	}
	
	public override func viewWillAppear(animated: Bool) {
		_selectedViewController?.zhh_beginAppearanceTransition(true, animated: animated)
		isInTransition = true
		super.viewWillAppear(animated)
	}
	
	public override func viewDidAppear(animated: Bool) {
		_selectedViewController?.zhh_endAppearanceTransition()
		isInTransition = false
		super.viewDidAppear(animated)
	}
	
	public override func viewWillDisappear(animated: Bool) {
		_selectedViewController?.zhh_beginAppearanceTransition(false, animated: animated)
		isInTransition = true
		super.viewWillDisappear(animated)
	}
	
	public override func viewDidDisappear(animated: Bool) {
		_selectedViewController?.zhh_endAppearanceTransition()
		isInTransition = false
		super.viewDidDisappear(animated)
	}
	
	public func reloadViewControllers() {
		if let dataSource = dataSource {
			setupViewControllersWithDataSource(dataSource)
		} else if loadedViewControllers == nil {
			fatalError("dataSource is nil and no view controllers provided")
		}
	}
}



// MARK: - Getting View Controller
extension PageViewController {
	// MARK: - Getting forward/backward view controllers
	private var forwardViewController: UIViewController? {
		if let _ = viewControllers {
			// Use view controllers
			return _selectedIndex + 1 < viewControllersCount ? loadedViewControllers[_selectedIndex + 1] : nil
		} else {
			// Use data source
			if _selectedIndex + 1 < viewControllersCount {
				return viewControllerForIndex(_selectedIndex + 1)
			}
			
			return nil
		}
	}
	
	private var backwardViewController: UIViewController? {
		return _selectedIndex - 1 >= 0 ? viewControllerForIndex(_selectedIndex - 1) : nil
	}
	
	/**
	Get view controller for index
	
	- parameter index: target index
	
	- returns: the view controller at the index.
	*/
	private func viewControllerForIndex(index: Int) -> UIViewController? {
		if index == -1 || index >= viewControllersCount { return nil }
		if let _ = viewControllers {
			// Using view controllers
			return loadedViewControllers[index]
		} else {
			// Using data source
			if index >= loadedViewControllers.count {
				// view controller is not available, have to load
				loadViewControllerFromIndex(loadedViewControllers.count, toIndex: index)
			} else {
				// view controller is available, is not in transition, load on demand
				if !isInTransition && _selectedIndex != index {
					loadedViewControllers[index] = dataSource!.pageViewController(self, viewControllerForIndex: index)
				}
			}
			
			let viewController = loadedViewControllers[index]
			
			if !self.childViewControllers.contains(viewController) {
				addViewController(viewController)
			}
			viewController.view.frame = CGRect(x: CGFloat(index) * view.bounds.width, y: 0, width: view.bounds.width, height: view.bounds.height)
			
			return viewController
		}
	}
	
	/**
	When dataSource is used, before retreiving view controller, load necessary view controllers
	
	- parameter fromIndex: the fromIndex
	- parameter toIndex:   the toIndex
	*/
	private func loadViewControllerFromIndex(fromIndex: Int, toIndex: Int) {
		precondition(viewControllers == nil && dataSource != nil)
		if fromIndex > toIndex { return }
		for i in fromIndex ... toIndex {
			let viewController = dataSource!.pageViewController(self, viewControllerForIndex: i)
			if i < loadedViewControllers.count {
				loadedViewControllers[i] = viewController
			} else {
				loadedViewControllers.append(viewController)
			}
		}
	}
}

// MARK: - ViewControllers Related
extension PageViewController {
	// ViewControllers Setups
	private func willReplaceOldViewControllers(oldViewControllers: [UIViewController]?, withNewViewControllers newViewControllers: [UIViewController]) {
		loadedViewControllers = newViewControllers
		
		if let oldViewControllers = oldViewControllers {
			oldViewControllers.forEach({ removeViewController($0) })
		}
		
		if isVisible {
			_selectedViewController?.zhh_beginAppearanceTransition(false, animated: false)
			_selectedViewController?.zhh_endAppearanceTransition()
		}
		
		for viewController in newViewControllers {
			addViewController(viewController)
		}
	}
	
	// ViewControllers Setups
	private func didReplaceOldViewControllers(oldViewControllers: [UIViewController]?, withNewViewControllers newViewControllers: [UIViewController]) {
		if isVisible {
			_selectedViewController?.zhh_beginAppearanceTransition(true, animated: false)
			_selectedViewController?.zhh_endAppearanceTransition()
		}
	}
	
	// ViewControllers Setups
	private func setupChildViewControllerViews(viewControllers: [UIViewController]) {
		// TODO: layoutSubviews may need to update contentSize
		pageScrollView.contentSize = CGSize(width: view.bounds.width * CGFloat(viewControllers.count), height: 0)
		for (index, viewController) in viewControllers.enumerate() {
			viewController.view.frame = CGRect(x: CGFloat(index) * view.bounds.width, y: 0, width: view.bounds.width, height: view.bounds.height)
		}
	}
}

// MARK: - DataSource/Delegate Related
extension PageViewController {
	// DataSource Setups
	private func setupViewControllersWithDataSource(dataSource: PageViewControllerDataSource) {
		viewControllers = nil
        // Clean up old view controllers
        loadedViewControllers?.forEach({ removeViewController($0) })
		loadedViewControllers = []
		
		let numberOfViewControllers = dataSource.numberOfViewControllersInPageViewController(self)
		pageScrollView.contentSize = CGSize(width: view.bounds.width * CGFloat(numberOfViewControllers), height: 0)
		
		if numberOfViewControllers == 0 {
			return
		}
        
        // If no selected view controller, set to 0
        if _selectedIndex == -1 {
            _selectedIndex = 0
        }
	}
}

// MARK: - ChildViewController Adding/Removing
extension PageViewController {
	private func removeViewController(viewController: UIViewController) {
		viewController.willMoveToParentViewController(nil)
		viewController.view.removeFromSuperview()
		viewController.removeFromParentViewController()
	}
	
	private func addViewController(viewController: UIViewController) {
		addChildViewController(viewController)
		pageScrollView.addSubview(viewController.view)
		viewController.didMoveToParentViewController(self)
	}
}

// MARK: - UIScrollViewDelegate
extension PageViewController : UIScrollViewDelegate {
	public func scrollViewDidScroll(scrollView: UIScrollView) {
		// Vertical scrolling is disabled
		
		let scrollOffset = scrollView.contentOffset.x - CGFloat(selectedIndex) * view.bounds.width
		let scrollOffsetPercent = scrollOffset / view.bounds.width
		delegate?.pageViewController(self, didScrollWithSelectedIndex: selectedIndex, offsetPercent: scrollOffsetPercent)
		
		if !isDragging {
			guard let willEndDraggingTargetContentOffsetX =  willEndDraggingTargetContentOffsetX else { return }
			let willSelectedIndex = Int(willEndDraggingTargetContentOffsetX) / Int(view.bounds.width)
			let willSelectedViewController = viewControllerForIndex(willSelectedIndex)
			
			// If current appearing view controller is not will selected view controller, state is mismatched. End it's transition
			let appearingViewControllers = Set.init(loadedViewControllers.filter { $0.isAppearing == true })
			assert(appearingViewControllers.count <= 1)
			if let willAppearViewController = appearingViewControllers.first where willAppearViewController !== willSelectedViewController {
				willAppearViewController.zhh_endAppearanceTransition()
			}
			
			// If the view controller moving to appearance call is not called, call it
			if willSelectedViewController?.isAppearing == nil {
				willSelectedViewController?.zhh_beginAppearanceTransition(true, animated: true)
			}
			
			// If selected view controller disappearing call is not called, call it
			if _selectedViewController?.isAppearing == nil {
				_selectedViewController?.zhh_beginAppearanceTransition(false, animated: true)
			}
			
			return
		}
		
		// Dragging Zero offset
		guard let draggingForward = draggingForward else {
			if forwardViewController?.isAppearing != nil {
				forwardViewController?.zhh_beginAppearanceTransition(false, animated: false)
				forwardViewController?.zhh_endAppearanceTransition()
			}
			
			if backwardViewController?.isAppearing != nil {
				backwardViewController?.zhh_beginAppearanceTransition(false, animated: false)
				backwardViewController?.zhh_endAppearanceTransition()
			}
			
			return
		}
		
		_selectedViewController?.zhh_beginAppearanceTransition(false, animated: true)
		
		if draggingForward {
			if backwardViewController?.isAppearing != nil {
				backwardViewController?.zhh_beginAppearanceTransition(false, animated: false)
				backwardViewController?.zhh_endAppearanceTransition()
			}
			
			forwardViewController?.zhh_beginAppearanceTransition(true, animated: true)
		} else {
			if forwardViewController?.isAppearing != nil {
				forwardViewController?.zhh_beginAppearanceTransition(false, animated: false)
				forwardViewController?.zhh_endAppearanceTransition()
			}
			
			backwardViewController?.zhh_beginAppearanceTransition(true, animated: true)
		}
		
		if !isInTransition { isInTransition = true }
	}
	
	public func scrollViewWillBeginDragging(scrollView: UIScrollView) {
		// If when new dragging initiatied, last dragging is still in progress.
		// End appearance transition immediately
		// And set selectedIndex to willAppear view controller
		let appearingViewControllers = Set.init(loadedViewControllers.filter { $0.isAppearing == true })
		assert(appearingViewControllers.count <= 1)
		loadedViewControllers.filter { $0.isAppearing != nil }.forEach { $0.zhh_endAppearanceTransition() }
		
		if let willAppearViewController = appearingViewControllers.first {
			_selectedIndex = loadedViewControllers.indexOf(willAppearViewController)!
		}
		
		beginDraggingContentOffsetX = nil
		willEndDraggingTargetContentOffsetX = nil
		
		isDragging = true
		beginDraggingContentOffsetX = scrollView.contentOffset.x
	}
	
	public func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
		isDragging = false
		guard let beginDraggingContentOffsetX = beginDraggingContentOffsetX else { return }
		willEndDraggingTargetContentOffsetX = targetContentOffset.memory.x
		if willEndDraggingTargetContentOffsetX == beginDraggingContentOffsetX {
			// If will end equals begin dragging content offset x,
			// which means dragging cancels
			_selectedViewController?.zhh_beginAppearanceTransition(true, animated: true)
			
			if forwardViewController?.isAppearing != nil {
				forwardViewController?.zhh_beginAppearanceTransition(false, animated: true)
			}
			
			if backwardViewController?.isAppearing != nil {
				backwardViewController?.zhh_beginAppearanceTransition(false, animated: true)
			}
		}
	}
	
	public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		// If dragging ends at separator point, clean state
		if scrollView.contentOffset.x % view.bounds.width == 0 {
			loadedViewControllers.filter { $0.isAppearing != nil }.forEach { $0.zhh_endAppearanceTransition() }
			_selectedIndex = Int(scrollView.contentOffset.x) / Int(view.bounds.width)
			beginDraggingContentOffsetX = nil
			willEndDraggingTargetContentOffsetX = nil
			assert(loadedViewControllers.filter { $0.isAppearing != nil }.count == 0)
		}
	}
	
	public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
		isInTransition = false
		// If for some reasons, scrollView.contentOffset.x is not matched with willEndDraggingTargetContentOffset
		// End current transitions
		// Add missing transitions
		guard let willEndDraggingTargetContentOffsetX = willEndDraggingTargetContentOffsetX else { return }
		if willEndDraggingTargetContentOffsetX != scrollView.contentOffset.x {
			let appearingViewControllers = Set.init(loadedViewControllers.filter { $0.isAppearing == true })
			assert(appearingViewControllers.count <= 1)
			
			// End current transitions
			loadedViewControllers.filter { $0.isAppearing != nil }.forEach { $0.zhh_endAppearanceTransition() }
			
			if let willAppearViewController = appearingViewControllers.first {
				_selectedIndex = loadedViewControllers.indexOf(willAppearViewController)!
				
				// Add missing transitions
				_selectedViewController?.zhh_beginAppearanceTransition(false, animated: false)
				_selectedViewController?.zhh_endAppearanceTransition()
				
				let willSelectedIndex = Int(scrollView.contentOffset.x) / Int(view.bounds.width)
				let willSelectedViewController = viewControllerForIndex(willSelectedIndex)
				willSelectedViewController?.zhh_beginAppearanceTransition(true, animated: false)
				willSelectedViewController?.zhh_endAppearanceTransition()
				_selectedIndex = willSelectedIndex
			}
		} else {
			loadedViewControllers.filter { $0.isAppearing != nil }.forEach { $0.zhh_endAppearanceTransition() }
			_selectedIndex = Int(scrollView.contentOffset.x) / Int(view.bounds.width)
		}
		
		beginDraggingContentOffsetX = nil
		self.willEndDraggingTargetContentOffsetX = nil
		
		assert(loadedViewControllers.filter { $0.isAppearing != nil }.count == 0)
	}
}

// MARK: - ViewController Appearance State Swizzling
private extension UIViewController {
    private struct AssociatedKeys {
        static var AppearanceStateKey = "zhh_AppearanceStateKey"
    }

    /// Store `isAppearing` in beginAppearanceTransition
    /// `nil` means `beginAppearanceTransition` not get called
    /// `true` means `beginAppearanceTransition` called with `isAppearing: true`, view controller is appearning
    /// `false` means `beginAppearanceTransition` called with `isAppearing: false`, view controller is disappearning
    private var isAppearing: Bool? {
        get { return objc_getAssociatedObject(self, &AssociatedKeys.AppearanceStateKey) as? Bool }
        set { objc_setAssociatedObject(self, &AssociatedKeys.AppearanceStateKey, newValue as Bool? as? AnyObject, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    /**
     Wrapper on `beginAppearanceTransition`, this will ignore successive calls with same isAppearing
     
     - parameter isAppearing: isAppearing description
     - parameter animated:    animated description
     */
    private func zhh_beginAppearanceTransition(isAppearing: Bool, animated: Bool) {
        if self.isAppearing != isAppearing {
            beginAppearanceTransition(isAppearing, animated: animated)
            self.isAppearing = isAppearing
        }
    }

    /**
     Wrapper on `endAppearanceTransition`, this will avoid unnecessary calls if there's no `beginAppearanceTransition` is called.
     */ 
    private func zhh_endAppearanceTransition() {
        if isAppearing != nil {
            endAppearanceTransition()
            isAppearing = nil
        }
    }
}
