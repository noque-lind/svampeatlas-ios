//
//  AppError.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 15/08/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import Foundation

public protocol AppError: Error {
    var errorDescription: String { get }
    var errorTitle: String { get }
}
