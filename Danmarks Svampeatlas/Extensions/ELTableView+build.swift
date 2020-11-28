//
//  ELTableView+appBuild.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 02/11/2020.
//  Copyright © 2020 NaturhistoriskMuseum. All rights reserved.
//

import Foundation
import ELKit

extension ELTableView {
    static func build(provider: Providor) -> ELTableView<T, Providor> {
        return ELTableViewBuilder.init(cellProvidor: provider)
            .setSectionHeaderCell(cellClass: SectionHeaderView.self)
            .setErrorCell(cellClass: ErrorCell.self)
            .build()
    }
}
