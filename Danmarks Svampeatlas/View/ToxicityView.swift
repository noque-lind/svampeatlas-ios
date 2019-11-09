//
//  ToxicityView
//  SvampeAtlas
//
//  Created by Emil Lind on 08/05/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class ToxicityView: UIView {

    private lazy var imageView: UIImageView = {
       let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "Glyphs_Poisonous")
        imageView.widthAnchor.constraint(equalToConstant: 14).isActive = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .center
        return imageView
    }()
    
    private lazy var label: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.appPrimary()
        label.textColor = UIColor.appWhite()
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.text = "Giftig"
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
        setContentHuggingPriority(.required, for: .horizontal)
        setContentCompressionResistancePriority(.required, for: .horizontal)
        
        layer.cornerRadius = CGFloat.cornerRadius()
        backgroundColor = UIColor.red
        
        addSubview(imageView)
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).isActive = true
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    
        addSubview(label)
        label.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 4).isActive = true
        label.topAnchor.constraint(equalTo: topAnchor, constant: 4).isActive = true
        label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4).isActive = true
        label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8).isActive = true
    }
    
    func configure(_ toxicityReport: String?) {
        if let toxicityReport = toxicityReport, toxicityReport.lowercased().contains("giftig") {
            self.isHidden = false
        } else {
            self.isHidden = true
        }
}
}
