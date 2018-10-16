//
//  NavigationDelegate.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 23/09/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

protocol NavigationDelegate: class {
    func presentVC(_ vc: UIViewController)
    func pushVC(_ vc: UIViewController)
}
