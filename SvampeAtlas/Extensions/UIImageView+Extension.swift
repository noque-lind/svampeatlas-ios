//
//  UIImageView+Extension.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 02/10/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

extension UIImageView {
    func fadeToNewImage(image: UIImage) {
        let crossFade: CABasicAnimation = CABasicAnimation(keyPath: "contents")
        crossFade.duration = 0.3
        crossFade.fromValue = self.image
        crossFade.toValue = image
        self.image = image
        self.layer.add(crossFade, forKey: "animateContents")
    }
}
