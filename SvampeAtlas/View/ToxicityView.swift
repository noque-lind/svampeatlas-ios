//
//  ToxicityView
//  SvampeAtlas
//
//  Created by Emil Lind on 08/05/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class ToxicityView: UIView {

    private lazy var toxicityIcon: UIImageView = {
       let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true
        return imageView
    }()
    
    private lazy var label: UILabel = {
       let label = UILabel()
        label.font = UIFont.appPrimaryHightlighed()
        label.textColor = UIColor.appWhite()
        label.textAlignment = .center
        return label
    }()
    
    
    init() {
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    private func setupView() {
        heightAnchor.constraint(equalToConstant: 15).isActive = true
        
        backgroundColor = UIColor.clear
        addSubview(toxicityIcon)
        toxicityIcon.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        toxicityIcon.topAnchor.constraint(equalTo: topAnchor).isActive = true
        toxicityIcon.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    
        addSubview(label)
        label.leadingAnchor.constraint(equalTo: toxicityIcon.trailingAnchor, constant: 4).isActive = true
        label.topAnchor.constraint(equalTo: topAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    func configure(_ toxicityLevel: ToxicityLevel) {
        label.text = toxicityLevel.rawValue
        
        switch toxicityLevel {
                case .eatable:
                    label.textColor = UIColor.appGreen()
                    toxicityIcon.image = #imageLiteral(resourceName: "Edible")
                case .toxic:
                    label.textColor = UIColor.appRed()
                case .cautious:
                    label.textColor = UIColor.appYellow()
                }
}
}
