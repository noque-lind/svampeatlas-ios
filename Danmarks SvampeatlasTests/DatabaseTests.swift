//
//  DatabaseTests.swift
//  Danmarks SvampeatlasTests
//
//  Created by Emil Møller Lind on 30/12/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import XCTest
import CoreData
@testable import Danmarks_Svampeatlas

class DatabaseTests: XCTestCase {

    let sut = Database.init(type: .test)

    override func setUp() {

    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

 func testSetup() {
        let setupExpectation = expectation(description: "Setup completion called")

    sut.setup {
        setupExpectation.fulfill()
    }

        waitForExpectations(timeout: 1.0) { (_) in
            XCTAssertTrue(self.sut.persistentContainer.persistentStoreCoordinator.persistentStores.count > 0)
        }
    }

    func testContainerType() {
               waitForExpectations(timeout: 1.0) { (_) in
                XCTAssertEqual(self.sut.persistentContainer.persistentStoreDescriptions.first?.type, NSInMemoryStoreType)
               }
    }
}
