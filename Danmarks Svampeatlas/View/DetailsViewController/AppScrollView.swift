//
//  AppScrollView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 29/05/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class AppScrollView: UIScrollView {
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 32
        return stackView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        view.addSubview(contentStackView)
        contentStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        contentStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        contentStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16).isActive = true
        contentStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16).isActive = true
        return view
    }()
    
    weak var customDelegate: NavigationDelegate?
    
    init() {
        super.init(frame: CGRect.zero)
        contentInsetAdjustmentBehavior = .never
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    internal func setupView() {
        addSubview(contentView)
        contentView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        contentView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
    }
    
    func configureHeader(title: String, subtitle: String?, user: String?) {
        let stackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.alignment = .center
            stackView.spacing = 4
            
            let titleLabel: UILabel = {
                let label = UILabel()
                label.font = UIFont.appTitle()
                label.textColor = UIColor.appWhite()
                label.textAlignment = .center
                label.text = title
                return label
            }()
            
            stackView.addArrangedSubview(titleLabel)
            
            if let subtitle = subtitle, subtitle != "" {
                let subtitleLabel: UILabel = {
                    let label = UILabel()
                    label.font = UIFont.appPrimaryHightlighed()
                    label.textColor = UIColor.appWhite()
                    label.textAlignment = .center
                    label.text = subtitle
                    return label
                }()
                
                stackView.addArrangedSubview(subtitleLabel)
            }
            
            if let user = user, user != "" {
                let userStackView: UIStackView = {
                    let stackView = UIStackView()
                    stackView.axis = .horizontal
                    stackView.spacing = 4
                    
                    let iconView: UIImageView = {
                        let view = UIImageView()
                        view.translatesAutoresizingMaskIntoConstraints = false
                        view.image = #imageLiteral(resourceName: "Glyphs_Profile")
                        view.contentMode = .center
                        view.widthAnchor.constraint(equalTo: view.heightAnchor).isActive = true
                        return view
                    }()
                    
                    let userLabel: UILabel = {
                        let label = UILabel()
                        label.font = UIFont.appPrimaryHightlighed()
                        label.textColor = UIColor.appWhite()
                        label.textAlignment = .center
                        label.text = user
                        return label
                    }()
                    
                    stackView.addArrangedSubview(iconView)
                    stackView.addArrangedSubview(userLabel)
                    return stackView
                }()
                stackView.addArrangedSubview(userStackView)
            }
            return stackView
        }()
        contentStackView.addArrangedSubview(stackView)
    }
    
    func configureHeader(title: NSAttributedString, subtitle: NSAttributedString?, user: String?) {
        let stackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.spacing = 4
            
            let titleLabel: UILabel = {
                let label = UILabel()
                label.font = UIFont.appTitle()
                label.textColor = UIColor.appWhite()
                label.textAlignment = .center
                label.attributedText = title
                return label
            }()
            
            stackView.addArrangedSubview(titleLabel)
            
            if let subtitle = subtitle, subtitle.string != "" {
                let subtitleLabel: UILabel = {
                    let label = UILabel()
                    label.font = UIFont.appPrimaryHightlighed()
                    label.textColor = UIColor.appWhite()
                    label.textAlignment = .center
                    label.attributedText = subtitle
                    return label
                }()
                
                stackView.addArrangedSubview(subtitleLabel)
            }
            
            if let user = user, user != "" {
                let userStackView: UIStackView = {
                    let stackView = UIStackView()
                    stackView.axis = .horizontal
                    stackView.spacing = 4
                    stackView.alignment = .center
                    
                    let iconView: UIImageView = {
                        let view = UIImageView()
                        view.translatesAutoresizingMaskIntoConstraints = false
                        view.image = #imageLiteral(resourceName: "Glyphs_Profile")
                        view.contentMode = .center
                        view.widthAnchor.constraint(equalTo: view.heightAnchor).isActive = true
                        return view
                    }()
                    
                    let userLabel: UILabel = {
                        let label = UILabel()
                        label.font = UIFont.appPrimaryHightlighed()
                        label.textColor = UIColor.appWhite()
                        label.textAlignment = .center
                        label.text = user
                        return label
                    }()
                    
                    stackView.addArrangedSubview(iconView)
                    stackView.addArrangedSubview(userLabel)
                    return stackView
                }()
                stackView.addArrangedSubview(userStackView)
            }
            return stackView
        }()
        contentStackView.addArrangedSubview(stackView)
    }
    
    func addContent(title: String?, content: UIView, padding: UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 8, bottom: 0.0, right: 8)) {
        func createContentStackView(padding: UIEdgeInsets) -> UIStackView {
            let stackView: UIStackView = {
                let stackView = UIStackView()
                stackView.isLayoutMarginsRelativeArrangement = true
                stackView.layoutMargins = padding
                stackView.addArrangedSubview(content)
                return stackView
            }()
            return stackView
        }
        
        if let title = title {
            let stackView: UIStackView = {
               let stackView = UIStackView()
                stackView.axis = .vertical
                stackView.spacing = 8
                
                let header: SectionHeaderView = {
                   let view = SectionHeaderView()
                    view.configure(title: title)
                    return view
                }()
                
                stackView.addArrangedSubview(header)
                stackView.addArrangedSubview(createContentStackView(padding: padding))
                return stackView
            }()
            
            contentStackView.addArrangedSubview(stackView)
        } else {
            contentStackView.addArrangedSubview(createContentStackView(padding: padding))
        }
    }
    
    func addText(title: String, text: String?) {
        guard let text = text, text != "" else {return}
        
        let textLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont.appPrimary()
            label.textColor = UIColor.appWhite()
            label.numberOfLines = 0
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = NSTextAlignment.justified
            paragraphStyle.hyphenationFactor = 1.0
            
            // Swift 4.2++
            let attributedString = NSMutableAttributedString(string: text.capitalizeFirst(), attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
            label.attributedText = attributedString
            return label
        }()
        
        addContent(title: title, content: textLabel)
    }
    
    func addInformation(information: [(String, String)]) {
        guard information.count != 0 else {return}
        
        func createStackView(_ withInfo: (String, String)) -> UIStackView {
            let leftLabel: UILabel = {
                let label = UILabel()
                label.numberOfLines = 1
                label.font = UIFont.appPrimary()
                label.textColor = UIColor.appWhite()
                label.text = withInfo.0
                label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
                label.textAlignment = .left
                return label
            }()
            
            let rightLabel: UILabel = {
                let label = UILabel()
                label.numberOfLines = 0
                label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
                label.font = UIFont.appPrimary()
                label.textColor = UIColor.appWhite()
                label.text = withInfo.1
                label.textAlignment = .right
                return label
            }()
            
            let stackView: UIStackView = {
                let stackView = UIStackView()
                stackView.axis = .horizontal
                stackView.spacing = 16
                stackView.distribution = .fill
                stackView.addArrangedSubview(leftLabel)
                stackView.addArrangedSubview(rightLabel)
                return stackView
            }()
            return stackView
        }
        
        let stackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.spacing = 4
            information.forEach({stackView.addArrangedSubview(createStackView($0))})
            return stackView
        }()
        
        addContent(title: NSLocalizedString("appScrollView_informationHeaderTitle", comment: ""), content: stackView)
    }
}
