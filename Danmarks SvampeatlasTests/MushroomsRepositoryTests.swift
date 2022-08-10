//
//  MushroomsRepositoryTests.swift
//  Danmarks SvampeatlasTests
//
//  Created by Emil Møller Lind on 30/12/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import XCTest
import CoreData
@testable import Danmarks_Svampeatlas

class MushroomsRepositoryTests: XCTestCase {

    var mockMushrooms: [Mushroom] = (0...5).map({Mushroom.init(id: $0, fullName: "Full name", fullNameAuthor: nil, updatedAt: nil, probability: nil, rankName: nil, statistics: .init(acceptedCount: $0, lastAcceptedRecord: "Last accepted Record", firstAcceptedRecord: "first Accepted Record"), attributes: nil, vernacularNameDK: nil, redlistData: nil, images: nil)})

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
               sut.mushroomsRepository.deleteAll { (_) in
                   exp.fulfill()
               }

               waitForExpectations(timeout: 2.0, handler: nil)
    }

    func testSave() {
        let exp = expectation(description: "Setup completion called")

        sut.mushroomsRepository.save(items: mockMushrooms) { (result) in
            switch result {
            case .failure: XCTFail()
            case .success:
                exp.fulfill()
            }
        }

        waitForExpectations(timeout: 1.0) { (_) in
            switch self.sut.mushroomsRepository.fetchAll() {
            case .failure: XCTFail()
            case .success(let mushrooms):
                XCTAssert(mushrooms.count == self.mockMushrooms.count)
            }
        }
    }

    func testDelete1() {
        let exp1 = expectation(description: "Save")
        let exp2 = expectation(description: "Delete")

        sut.mushroomsRepository.save(items: mockMushrooms) { (result) in
            switch result {
            case .failure: XCTFail()
            case .success:
                exp1.fulfill()
                self.sut.mushroomsRepository.delete(mushroom: self.mockMushrooms[0]) { (result) in
                switch result {
                case .failure: XCTFail()
                case .success: exp2.fulfill()
                }
                }
            }
        }

        waitForExpectations(timeout: 4.0) { (_) in
            switch self.sut.mushroomsRepository.fetchAll() {
            case .failure: XCTFail()
            case .success(let mushrooms):
                XCTAssert(mushrooms.count == self.mockMushrooms.count - 1)
            }
        }

    }

    func testDeleteAll() {
        guard sut.type == .production else {return}
        let exp1 = expectation(description: "Save all")

        sut.mushroomsRepository.save(items: mockMushrooms) { (result) in
            switch result {
            case .failure: XCTFail()
            case .success:
                self.sut.mushroomsRepository.deleteAll { (result) in
                    switch result {
                    case .failure: XCTFail()
                    case .success: exp1.fulfill()
                    }
                }

        }
        }

        waitForExpectations(timeout: 2.0) { (_) in
            switch self.sut.mushroomsRepository.fetchAll() {
            case .failure(let error):
                switch error {
                case .noEntries: return
                default: XCTFail()
                }
            case .success(let mushrooms):
                XCTAssert(mushrooms.isEmpty)
            }

        }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
