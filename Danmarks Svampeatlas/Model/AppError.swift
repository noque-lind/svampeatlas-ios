//
//  AppError.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 15/08/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import Foundation

public enum RecoveryAction: String {
    case openSettings = "Åben indstillinger"
    case tryAgain = "Prøv igen"
    case login = "Log ind"
    case activate = "Aktivér"
}

public protocol AppError: Error {
    var errorDescription: String { get }
    var errorTitle: String { get }
    var recoveryAction: RecoveryAction? { get }
}
