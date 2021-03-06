//
//  NSObject+AssociatedObjectTests.swift
//  ChouTi_FrameworkTests
//
//  Created by Honghao Zhang on 2015-12-14.
//  Copyright © 2015 Honghao Zhang. All rights reserved.
//

import XCTest
@testable import ChouTi

class NSObject_AssociatedObjectTests: ChouTiTests {
	var host: NSObject!
	
	override func setUp() {
		super.setUp()
		host = NSObject()
	}
	
	override func tearDown() {
		super.tearDown()
		host = nil
	}
	
	func testAssociatedObject() {
		let associatedNumber = 123
		host.associatedObject = associatedNumber
		XCTAssertEqual(host.associatedObject as? Int, 123)
		host.associatedObject = nil
		XCTAssertNil(host.associatedObject)
	}
	
	func testGetAssociatedObject() {
		host.setAssociatedObejct("998")
		XCTAssertEqual(host.getAssociatedObject() as? String, "998")
		XCTAssertEqual(host.setAssociatedObejct(778) as? String, "998")
		XCTAssertEqual(host.clearAssociatedObject() as? Int, 778)
		XCTAssertNil(host.getAssociatedObject())
	}
    
    private struct TestAssociateObjectKey {
        static var Key = "TestAssociateObjectKey"
    }
    
    func testAssociatedObjectWithPointer() {
        host.setAssociatedObejct("998", forKeyPointer: &TestAssociateObjectKey.Key)
        XCTAssertEqual(host.setAssociatedObejct(778, forKeyPointer: &TestAssociateObjectKey.Key) as? String, "998")
        XCTAssertEqual(host.clearAssociatedObject(forKeyPointer: &TestAssociateObjectKey.Key) as? Int, 778)
        XCTAssertNil(host.getAssociatedObject(forKeyPointer: &TestAssociateObjectKey.Key))
    }
}
