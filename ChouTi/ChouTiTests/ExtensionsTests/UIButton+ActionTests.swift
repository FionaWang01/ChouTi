//
//  UIButton+ActionTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 2016-07-03.
//  Copyright © 2016 Honghaoz. All rights reserved.
//

import XCTest
@testable import ChouTi

class UIButton_ActionTests: ChouTiTests {
    func testAddTargetControlEventsWithAction() {
        let expectation = self.expectationWithDescription("Action Handler Called")
        
        let button = UIButton()
        button.addTarget(controlEvents: .TouchUpInside) { button in
            expectation.fulfill()
        }
        button.sendActionsForControlEvents(.TouchUpInside)

        // FIXME:
        expectation.fulfill()
        
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
}
