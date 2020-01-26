//
//  ToxicityView
//  SvampeAtlas
//
//  Created by Emil Lind on 08/05/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class ToxicityViewHolder: UIView {
    
    private lazy var toxicityView: ToxicityView = {
       let view = ToxicityView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var heightConstraint = NSLayoutConstraint()
    
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupView() {
        backgroundColor = .clear
        heightConstraint = heightAnchor.constraint(equalToConstant: 0)
    }
    
    func configure(isPoisonous: Bool) {
        if isPoisonous {
            heightConstraint.isActive = false
            addSubview(toxicityView)
            toxicityView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            toxicityView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            toxicityView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
                } else {
            toxicityView.removeFromSuperview()
            heightConstraint.isActive = true
                }
    }
    
}

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
        label.setContentHuggingPriority(.required, for: .vertical)
//        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.text = NSLocalizedString("toxicityLevel_poisonous", comment: "")
        label.textAlignment = .center
        return label
    }()
    
    override func sizeToFit() {
        label.sizeToFit()
    }
    

    
    init() {
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    private func setupView() {
        setContentHuggingPriority(.required, for: .horizontal)
        setContentHuggingPriority(.required, for: .vertical)
        setContentCompressionResistancePriority(.required, for: .vertical)
        
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
    
    func configure(isPoisonous: Bool) {
        if isPoisonous {
            isHidden = false
                } else {
           isHidden = true
            }
    }
}
