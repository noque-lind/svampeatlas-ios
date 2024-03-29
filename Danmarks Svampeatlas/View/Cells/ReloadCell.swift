//
//  LoadMoreCell.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 13/11/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class ReloadCell: UITableViewCell {
    
    enum ´Type {
    case showMore
        case tryAgain
    
        var description: String {
            switch self {
            case .showMore: return NSLocalizedString("reloadCell_showMore", comment: "")
            case .tryAgain: return NSLocalizedString("reloadCell_tryAgain", comment: "")
            }
        }
}
    
    static let identifier = "ReloadCell"
    
    private var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: 14).isActive = true
        imageView.contentMode = .scaleAspectFit
        imageView.image = #imageLiteral(resourceName: "Glyphs_Reload")
        return imageView
    }()
    
//    private var contentBackgroundView: UIView = {
//       let view = UIView()
//        view.backgroundColor = UIColor.black
//        view.alpha = 0.2
//        view.layer.cornerRadius = 5
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
    
    private var label: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.appWhite()
        label.font = UIFont.appPrimaryHightlighed()
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupView() {
        backgroundColor = UIColor.clear
        selectionStyle = .none
        separatorInset = UIEdgeInsets(top: 0, left: 10000, bottom: 0, right: 0)
        accessoryType = .none
        
        let contentStackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.spacing = 8
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(iconImageView)
            stackView.addArrangedSubview(label)
            return stackView
        }()
        
        contentView.addSubview(contentStackView)
        contentStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        contentStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
//        contentView.insertSubview(contentBackgroundView, belowSubview: contentStackView)
//        contentBackgroundView.leadingAnchor.constraint(equalTo: contentStackView.leadingAnchor, constant: -5).isActive = true
//        contentBackgroundView.trailingAnchor.constraint(equalTo: contentStackView.trailingAnchor, constant: 5).isActive = true
//        contentBackgroundView.topAnchor.constraint(equalTo: contentStackView.topAnchor, constant: -5).isActive = true
//        contentBackgroundView.bottomAnchor.constraint(equalTo: contentStackView.bottomAnchor, constant: 5).isActive = true
    }
    
    func configureCell(type: ´Type) {
        label.text = type.description
    }
}
