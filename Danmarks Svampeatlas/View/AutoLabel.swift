//
//  AutoLabel.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 03/08/2022.
//  Copyright © 2022 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class AutoLabel: UILabel {

    override var bounds: CGRect {
        didSet {
            if bounds.size.width != oldValue.size.width {
                self.setNeedsUpdateConstraints()
            }
        }
    }

    override func updateConstraints() {
        if self.preferredMaxLayoutWidth != self.bounds.size.width {
            self.preferredMaxLayoutWidth = self.bounds.size.width
        }
        super.updateConstraints()
    }
}
