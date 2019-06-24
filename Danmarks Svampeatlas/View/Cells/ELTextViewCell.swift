//
//  ELTextViewCell.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 22/12/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class TextViewCell: UITableViewCell {
    
    lazy var textView: ELTextView = {
       let view = ELTextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.appSecondaryColour()
        view.textColor = UIColor.appWhite()
        view.font = UIFont.appPrimary()
        view.titleTextColor = UIColor.appWhite()
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    
    private func setupView() {
        separatorInset = UIEdgeInsets(top: 0.0, left: 0, bottom: 0.0, right: 0.0)
        selectionStyle = .none
        backgroundColor = UIColor.clear
        contentView.addSubview(textView)
        textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8).isActive = true
        textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8).isActive = true
        textView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
    }
    
    func configureCell(titleText: String, placeholder: String, content: String?, delegate: ELTextViewDelegate?) {
        textView.titleText = titleText
        textView.placeholder = placeholder
        textView.text = content
        textView.delegate = delegate
    }
}

class AddCommentCell: UITableViewCell {
    private lazy var textView: ELTextView = {
        let view = ELTextView(defaultHeight: 90)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.appSecondaryColour()
        view.textColor = UIColor.appWhite()
        view.shouldHandleKeyboard = false
        view.font = UIFont.appPrimaryHightlighed()
        view.titleTextColor = UIColor.appWhite()
        return view
    }()
    
    private lazy var sendButton: UIButton = {
       let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.appGreen()
        button.setImage(#imageLiteral(resourceName: "DisclosureButton"), for: [])
        button.widthAnchor.constraint(equalToConstant: 40).isActive = true
        button.layer.shadowOpacity = textView.shadowOpacity
        button.layer.shadowOffset = textView.shadowOffset
        button.layer.shadowRadius = textView.shadowRadius
        button.addTarget(self, action: #selector(buttonpressed), for: .touchUpInside)
        return button
    }()
    
    var sendButtonTappedHandler: ((String) -> ())?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    @objc private func buttonpressed() {
        guard let enteredText = textView.text, enteredText != "" else {return}
        sendButtonTappedHandler?(enteredText)
        textView.text = nil
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    private func setupView() {
        isUserInteractionEnabled = true
        separatorInset = UIEdgeInsets(top: 0.0, left: 0, bottom: 0.0, right: 0.0)
        selectionStyle = .none
        backgroundColor = UIColor.clear
        contentView.addSubview(textView)
        contentView.addSubview(sendButton)
        textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        textView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
        textView.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8).isActive = true
        sendButton.topAnchor.constraint(equalTo: textView.textView.topAnchor).isActive = true
        sendButton.bottomAnchor.constraint(equalTo: textView.textView.bottomAnchor).isActive = true
        sendButton.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    func configureCell(descriptionText: String, placeholder: String?, content: String?, delegate: ELTextViewDelegate?) {
        textView.titleText = descriptionText
        textView.placeholder = placeholder
        textView.text = content
        textView.delegate = delegate
    }
    
    func enteredText() -> String? {
        return textView.text
    }
}
