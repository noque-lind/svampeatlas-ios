//
//  VegetationTypeRespositoryTests.swift
//  Danmarks SvampeatlasTests
//
//  Created by Emil Møller Lind on 11/01/2020.
//  Copyright © 2020 NaturhistoriskMuseum. All rights reserved.
//

import XCTest
@testable import Danmarks_Svampeatlas

class VegetationTypeRespositoryTests: XCTestCase {

    var mockVegeationTypes: [VegetationType] = (0...5).map { VegetationType.init(id: $0, dkName: "DK NAME: \($0)", enName: "EN NAME: \($0)") }

       var sut: Database = .init(type: .production)

       override func setUp() {
           let exp = expectation(description: "Setup")

           sut.setup {
               debugPrint("Was setup")
               exp.fulfill()
           }

           waitForExpectations(timeout: 2.0, handler: nil)
       }

       override func tearDown() {
           let exp = expectation(description: "deleting")
        sut.vegetationTypeRepository.deleteAll { (_) in
               exp.fulfill()
           }

           waitForExpectations(timeout: 2.0, handler: nil)
       }

       func testDelete() {
           guard sut.type == .production else {return}
           let exp = expectation(description: "Wait for delete")

        sut.vegetationTypeRepository.deleteAll { (_) in
               exp.fulfill()
           }

           waitForExpectations(timeout: 2.0) { (_) in
               self.sut.vegetationTypeRepository.fetchAll().onFailure { (error) in
                   switch error {
                   case .noEntries: return
                   default: XCTFail()
                   }
               }
           }
       }

       func testSave() {

           sut.substrateGroupsRepository.fetchAll().onSuccess { (vegetationTypes) in
               XCTAssertTrue(vegetationTypes.isEmpty)
           }

           let exp = expectation(description: "Wait for save")

           sut.vegetationTypeRepository.save(items: mockVegeationTypes) { (_) in
               exp.fulfill()
           }

           waitForExpectations(timeout: 1) { (_) in
               switch self.sut.vegetationTypeRepository.fetchAll() {
               case .failure:
                   XCTFail()
               case .success(let items):
                   XCTAssertTrue(items.count == self.mockVegeationTypes.count)
               }
           }
       }

       func testOverride() {

           sut.vegetationTypeRepository.fetchAll().onSuccess { (substrateGroups) in
               XCTAssertTrue(substrateGroups.isEmpty)
           }

           let exp = expectation(description: "Wait for first save")
           let exp2 = expectation(description: "Wait for second save")

        sut.vegetationTypeRepository.save(items: self.mockVegeationTypes) { (_) in
               exp.fulfill()
            self.sut.vegetationTypeRepository.save(items: self.mockVegeationTypes) { (_) in
                   exp2.fulfill()
               }
               }

           waitForExpectations(timeout: 3.0) { (_) in
               switch self.sut.vegetationTypeRepository.fetchAll() {
               case .failure:
                   XCTFail()
               case .success(let items):
                   XCTAssertTrue(items.count == self.mockVegeationTypes.count)
               }
           }
           }

}
