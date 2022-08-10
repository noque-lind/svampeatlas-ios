//
//  SubstrateGroupRepositoryTests.swift
//  Danmarks SvampeatlasTests
//
//  Created by Emil Møller Lind on 30/12/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import XCTest
import CoreData
@testable import Danmarks_Svampeatlas

class SubstrateGroupRepositoryTests: XCTestCase {

    var mockSubstrateGroups: [SubstrateGroup] = (0...5).map { SubstrateGroup.init(dkName: "Substrat \($0)", enName: "Substrate \($0)", substrates: (0...30).map {Substrate.init(id: $0, dkName: "Substrat \($0)", enName: "Substrate \($0)")})}

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
        sut.substrateGroupsRepository.deleteAll { (_) in
            exp.fulfill()
        }

        waitForExpectations(timeout: 2.0, handler: nil)
    }

    func testDelete() {
        guard sut.type == .production else {return}
        let exp = expectation(description: "Wait for delete")

        sut.substrateGroupsRepository.deleteAll { (_) in
            exp.fulfill()
        }

        waitForExpectations(timeout: 2.0) { (_) in
            self.sut.substrateGroupsRepository.fetchAll().onFailure { (error) in
                switch error {
                case .noEntries: return
                default: XCTFail()
                }
            }
        }
    }

    func testSave() {

        sut.substrateGroupsRepository.fetchAll().onSuccess { (substrateGroups) in
            XCTAssertTrue(substrateGroups.isEmpty)
        }

        let exp = expectation(description: "Wait for save")

        sut.substrateGroupsRepository.save(items: mockSubstrateGroups) { (_) in
            exp.fulfill()
        }

        waitForExpectations(timeout: 1) { (_) in
            switch self.sut.substrateGroupsRepository.fetchAll() {
            case .failure:
                XCTFail()
            case .success(let items):
                XCTAssertTrue(items.count == self.mockSubstrateGroups.count)
            }
        }
    }

    func testOverride() {

        sut.substrateGroupsRepository.fetchAll().onSuccess { (substrateGroups) in
            XCTAssertTrue(substrateGroups.isEmpty)
        }

        let exp = expectation(description: "Wait for first save")
        let exp2 = expectation(description: "Wait for second save")

        sut.substrateGroupsRepository.save(items: mockSubstrateGroups) { (_) in
            exp.fulfill()
            sut.substrateGroupsRepository.save(items: mockSubstrateGroups) { (_) in
                exp2.fulfill()
            }
            }

        waitForExpectations(timeout: 3.0) { (_) in
            switch self.sut.substrateGroupsRepository.fetchAll() {
            case .failure:
                XCTFail()
            case .success(let items):
                XCTAssertTrue(items.count == self.mockSubstrateGroups.count)
            }

            switch self.sut.substrateGroupsRepository.fetchSubstratesOnly() {
            case .failure:
                XCTFail()
            case .success(let substrates):
                XCTAssertTrue(substrates.count == 31)
            }
        }
        }

    func testSubstrate() {

    }

}
