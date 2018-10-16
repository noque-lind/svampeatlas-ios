//
//  AppError.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 15/08/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import Foundation

struct AppError: Error {
    public private(set) var title: String
    public private(set) var message: String
}
