//
//  AppError.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 15/08/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import Foundation


public enum mRecoveryAction {
    case openSettings
    case tryAgain
    case login
    case activate
    
    var localizableText: String {
        switch self {
        case .openSettings: return LocalizableStrings.RecoveryAction.openSettings
        case .login: return LocalizableStrings.RecoveryAction.login
        case .activate: return LocalizableStrings.RecoveryAction.activate
        case .tryAgain: return LocalizableStrings.RecoveryAction.tryAgain
        }
    }
    
}

public protocol AppError: Error {
    var errorDescription: String { get }
    var errorTitle: String { get }
    var recoveryAction: mRecoveryAction? { get }
}
