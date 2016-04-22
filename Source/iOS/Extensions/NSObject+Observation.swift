//
//  NSObject+Observation.swift
//  Pods
//
//  Created by Honghao Zhang on 2016-02-11.
//
//

import Foundation

// NOTE: Be sure to removeObservation before this object is deallocated

public extension NSObject {
    typealias ObserverHandler = (oldValue: AnyObject, newValue: AnyObject) -> Void
    
    // Observer
    class Observer: NSObject {
        var handlerDictionary = [String : ObserverHandler]()
        
        public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
            guard let keyPath = keyPath else {
                print("Warning: Observer: keyPath is nil")
                return
            }
            
            guard let change = change else {
                print("Warning: Observer: change dictionary is nil")
                return
            }
            
            guard let handler = handlerDictionary[keyPath] else {
                print("Warning: Observer: handler for keyPath: \(keyPath) is nil")
                return
            }
            
            guard let oldValue = change[NSKeyValueChangeOldKey] else {
                print("Warning: Observer: oldValue not found")
                return
            }
            
            guard let newValue = change[NSKeyValueChangeNewKey] else {
                print("Warning: Observer: newValue not found")
                return
            }
            
            handler(oldValue: oldValue, newValue: newValue)
        }
    }
    
    // Add an Observer
    private struct ObserveKey {
        static var Key = "zhh_ObserveKey"
    }
    
    private var observer: Observer? {
        get {
            if let existingObserver = objc_getAssociatedObject(self, &ObserveKey.Key) as? Observer {
                return existingObserver
            } else {
                let newObserver = Observer()
                objc_setAssociatedObject(self, &ObserveKey.Key, newObserver, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return newObserver
            }
        }
        
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &ObserveKey.Key, newValue as Observer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            } else {
                objc_setAssociatedObject(self, &ObserveKey.Key, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    private struct ObservingContext {
        static var Key = "zhObservingContextKey"
    }
    
    // MARK: - Public
	/**
	Observe property with keyPath.
	Note: `dynamic` attribute is necessary for Swift classes
	
	- parameter keyPath: keyPath for the property
	- parameter handler: Observer handler
	*/
    public func observe(keyPath: String, withHandler handler: ObserverHandler) {
        guard let observer = observer else {
            print("Error: observer is nil")
            return
        }
        
        observer.handlerDictionary[keyPath] = handler
        addObserver(observer, forKeyPath: keyPath, options: [.Old, .New], context: &NSObject.ObservingContext.Key)
    }
	
	/**
	Remove the observation for keyPath
	
	- parameter keyPath: keyPath of the observation
	*/
    public func removeObservation(forKeyPath keyPath: String) {
        guard let observer = observer else {
            print("Error: observer is nil")
            return
        }
        
        removeObserver(observer, forKeyPath: keyPath, context: &NSObject.ObservingContext.Key)
        observer.handlerDictionary.removeValueForKey(keyPath)
        
        // Clean observer if needed
        if observer.handlerDictionary.isEmpty {
            self.observer = nil
        }
    }
}
