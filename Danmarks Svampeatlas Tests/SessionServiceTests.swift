//
//  SessionServiceTests.swift
//  Danmarks SvampeatlasTests
//
//  Created by Emil Møller Lind on 14/03/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import XCTest
@testable import Danmarks_Svampeatlas

class SessionServiceTests: XCTestCase {

    enum CategoryViewTestsEnum {
        case none
        case full
    }
    
    
    var categoryView: CategoryView<CategoryViewTestsEnum>?
    
    override func setUp() {
//        categoryView = CategoryView<CategoryViewTestsEnum>.init(categories: [CategoryViewTestsEnum.none, CategoryViewTestsEnum.full], firstIndex: 0)
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        categoryView = nil
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        
        
        
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
