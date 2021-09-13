//
//  UILabel+SetMargins.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 11/09/2021.
//  Copyright © 2021 NaturhistoriskMuseum. All rights reserved.
//

import UIKit



extension UILabel {
    func setMargins(margin: CGFloat = 10) {
        if let textString = self.text {
            var paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.firstLineHeadIndent = margin
            paragraphStyle.headIndent = margin
            paragraphStyle.tailIndent = -margin
            let attributedString = NSMutableAttributedString(string: textString)
            attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
            attributedText = attributedString
        }
    }
}
