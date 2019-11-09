//
//  InformationView.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 08/10/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class InformationView: UIView {
    
    private let stackView: UIStackView = {
              let stackView = UIStackView()
               stackView.axis = .vertical
               stackView.spacing = 4
               stackView.translatesAutoresizingMaskIntoConstraints = false
               return stackView
           }()
           
           
           
    
    enum Style {
        case light
        case dark
    }
    
    let style: Style
    
    init(style: Style) {
        self.style = style
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = UIColor.clear
        addSubview(stackView)
        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
    }
    
    func reset() {
        stackView.arrangedSubviews.forEach({$0.removeFromSuperview()})
    }
    
    func addInformation(information: [(String, String)]) {
           guard information.count != 0 else {return}
           
           func createStackView(_ withInfo: (String, String)) -> UIView {
               
            let contentView: UIView = {
                      let view = UIView()
                       view.backgroundColor = UIColor.clear
                view.translatesAutoresizingMaskIntoConstraints = false
                
                       let leftLabel: UILabel = {
                           let label = UILabel()
                           label.numberOfLines = 0
                           label.font = UIFont.appPrimary()
                        label.textColor = style == Style.light ? UIColor.appWhite(): UIColor.appPrimaryColour()
                           label.text = withInfo.0
                        label.translatesAutoresizingMaskIntoConstraints = false
                        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
                        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
                        label.setContentHuggingPriority(.required, for: .vertical)
                           label.textAlignment = .left
                        label.sizeToFit()
                           return label
                       }()
                
                    let rightLabel: UILabel = {
                                      let label = UILabel()
                                      label.numberOfLines = 1
                                   label.setContentCompressionResistancePriority(.required, for: .horizontal)
                        label.translatesAutoresizingMaskIntoConstraints = false
                                   label.setContentHuggingPriority(.defaultLow, for: .horizontal)
                                      label.font = UIFont.appPrimary()
                                      label.textColor = style == Style.light ? UIColor.appWhite(): UIColor.appPrimaryColour()
                                      label.text = withInfo.1
                                   label.sizeToFit()
                                      label.textAlignment = .right
                                      return label
                                  }()
                
                view.addSubview(leftLabel)
                leftLabel.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
                leftLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
                leftLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
                
                view.addSubview(rightLabel)
                rightLabel.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
                rightLabel.leadingAnchor.constraint(equalTo: leftLabel.trailingAnchor, constant: 16).isActive = true
                rightLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
                rightLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
                return view
                   }()
            
            return contentView
           }
        
         information.forEach({stackView.addArrangedSubview(createStackView($0))})
       
       }
}
