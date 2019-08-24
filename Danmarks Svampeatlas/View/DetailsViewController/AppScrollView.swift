//
//  AppScrollView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 29/05/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit
import MapKit
class AppScrollView: UIScrollView {
    
    lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = UIStackView.Distribution.fill
        stackView.spacing = 24
        return stackView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        view.addSubview(contentStackView)
        contentStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8).isActive = true
        contentStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8).isActive = true
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
    
    deinit {
        print("AppScrollView deinited")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    private func setupView() {
        addSubview(contentView)
        contentView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        contentView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
    }
    
    func addContent(title: String, content: UIView) -> UIStackView {
        let stackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.spacing = 2
            
            let dividerLabel: UILabel = {
                let label = UILabel()
                label.font = UIFont.appDivider()
                label.textColor = UIColor.appWhite()
                label.text = title
                return label
            }()
            
            stackView.addArrangedSubview(dividerLabel)
    if content is UIScrollView {
    
    }
            stackView.addArrangedSubview(content)
            return stackView
    }()
        contentStackView.addArrangedSubview(stackView)
        return stackView
        
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
                        view.image = #imageLiteral(resourceName: "Profile")
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
                    
                    let iconView: UIImageView = {
                        let view = UIImageView()
                        view.translatesAutoresizingMaskIntoConstraints = false
                        view.image = #imageLiteral(resourceName: "Profile")
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

    
    func configureText(title: String, text: String?) {
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
            let attributedString = NSMutableAttributedString(string: text, attributes: [NSAttributedString.Key.paragraphStyle:paragraphStyle])
            label.attributedText = attributedString
            return label
        }()
        
        _ = addContent(title: title, content: textLabel)
    }
    
    func configureInformation(information: [(String, String)]) {
        guard information.count != 0 else {return}
        
        func createStackView(_ withInfo: (String, String)) -> UIStackView {
            let leftLabel: UILabel = {
                let label = UILabel()
                label.font = UIFont.appPrimary()
                label.textColor = UIColor.appWhite()
                label.text = withInfo.0
                label.textAlignment = .left
                return label
            }()
            
            let rightLabel: UILabel = {
                let label = UILabel()
                label.font = UIFont.appPrimary()
                label.textColor = UIColor.appWhite()
                label.text = withInfo.1
                label.textAlignment = .right
                label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
                return label
            }()
            
            let stackView: UIStackView = {
                let stackView = UIStackView()
                stackView.axis = .horizontal
                stackView.distribution = .fillProportionally
                stackView.addArrangedSubview(leftLabel)
                stackView.addArrangedSubview(rightLabel)
                return stackView
            }()
            return stackView
        }
        
        let stackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.spacing = 2
            
            let dividerLabel: UILabel = {
                let label = UILabel()
                label.font = UIFont.appDivider()
                label.textColor = UIColor.appWhite()
                label.text = "Information"
                return label
            }()
            
            stackView.addArrangedSubview(dividerLabel)
            _ = information.map({stackView.addArrangedSubview(createStackView($0))})
            return stackView
        }()
        
        contentStackView.addArrangedSubview(stackView)
    }
}
