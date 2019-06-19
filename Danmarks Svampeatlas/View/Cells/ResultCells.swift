//
//  ResultCell.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 08/04/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class BaseCell: UITableViewCell {
    fileprivate lazy var roundedImageView: RoundedImageView = {
        let view = RoundedImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    fileprivate lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appPrimaryHightlighed()
        label.textColor = UIColor.appWhite()
        return label
    }()
    
    fileprivate lazy var secondaryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appPrimary()
        label.textColor = UIColor.appWhite()
        return label
    }()
    
    fileprivate lazy var textStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(secondaryLabel)
        return stackView
    }()
    
    fileprivate lazy var disclosureButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.clear
        button.alpha = 1
        button.translatesAutoresizingMaskIntoConstraints = false
        button.imageView?.contentMode = .scaleAspectFit
        button.setImage(#imageLiteral(resourceName: "DisclosureButton").withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: [])
        return button
    }()
    
    fileprivate var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.appWhite()
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        return view
    }()
    
    fileprivate var containerViewBottomConstraint: NSLayoutConstraint?
    
    override var tintColor: UIColor! {
        didSet {
            titleLabel.textColor = tintColor
            secondaryLabel.textColor = tintColor
            disclosureButton.tintColor = tintColor
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    fileprivate func setupView(leadingConstant: CGFloat = 8, trailingConstant: CGFloat = -8) {
        backgroundColor = UIColor.clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: trailingConstant).isActive = true
        containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: leadingConstant).isActive = true
        containerView.topAnchor.constraint(equalTo: topAnchor, constant: 4).isActive = true
        containerViewBottomConstraint = containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4)
        containerViewBottomConstraint?.isActive = true
    }
}

class UnknownSpecieCell: BaseCell {
    
    override func setupView(leadingConstant: CGFloat, trailingConstant: CGFloat) {
        roundedImageView.isMasked = false
        containerView.backgroundColor = UIColor.appWhite()
        tintColor = UIColor.appPrimaryColour()
        roundedImageView.tintColor = UIColor.appPrimaryColour()
        roundedImageView.layer.shadowOpacity = 0.0
        selectionStyle = .none
        
        containerView.addSubview(roundedImageView)
        roundedImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10).isActive = true
        roundedImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        roundedImageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        roundedImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        secondaryLabel.numberOfLines = 0
        secondaryLabel.adjustsFontSizeToFitWidth = true
        textStackView.distribution = .fillProportionally
        containerView.addSubview(textStackView)
        textStackView.leadingAnchor.constraint(equalTo: roundedImageView.trailingAnchor, constant: 10).isActive = true
        textStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 4).isActive = true
        textStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -4).isActive = true
        textStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8).isActive = true
        
        super.setupView(leadingConstant: leadingConstant, trailingConstant: trailingConstant)
        configureCell()
    }
    

    private func configureCell() {
        
        titleLabel.text = "Ubestemt svampeart"
        secondaryLabel.text = "Når du uploader uden en artsindentifikering, vil fælleskabet prøve at hjælpe dig."
        roundedImageView.isMasked = false
        roundedImageView.configureImage(image: #imageLiteral(resourceName: "Icons_Missing").withRenderingMode(.alwaysTemplate))
    }
}

class ContainedResultCell: BaseCell {
    
    override func setupView(leadingConstant: CGFloat, trailingConstant: CGFloat) {
        tintColor = UIColor.appPrimaryColour()
        
        containerView.addSubview(roundedImageView)
        roundedImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        roundedImageView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        roundedImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
    
        containerView.addSubview(textStackView)
        textStackView.leadingAnchor.constraint(equalTo: roundedImageView.trailingAnchor, constant: 8).isActive = true
        textStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8).isActive = true
        textStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 4).isActive = true
        textStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -4).isActive = true

        super.setupView(leadingConstant: leadingConstant, trailingConstant: trailingConstant)
    }
    
    func configureCell(mushroom: Mushroom) {
        titleLabel.text = mushroom.danishName ?? mushroom.fullName
        secondaryLabel.attributedText = mushroom.danishName != nil ? mushroom.fullName.italized(font: secondaryLabel.font): nil
        roundedImageView.configureImage(url: mushroom.images?.first?.url)
    }
}

class SelectedSpecieCell: ContainedResultCell {
    
    private enum Items: String, CaseIterable {
        case Determined = "Det er helt sikkert den her art"
        case Unsure = "Det er sandsynligvis denne art"
        case Guessing = "Det er muligvis denne art"
    }
    
    private var questionLabel: UILabel = {
       let label = UILabel()
        label.textColor = UIColor.appWhite()
        label.font = UIFont.appPrimaryHightlighed()
        label.translatesAutoresizingMaskIntoConstraints = false
//        label.heightAnchor.constraint(equalToConstant: 20).isActive = true
        label.text = "Hvor sikker er du?"
        label.textAlignment = .center
        return label
    }()
    
    private lazy var picker: UIPickerView = {
        let view = UIPickerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        view.dataSource = self
        view.delegate = self
        return view
    }()
    
    override func setupView(leadingConstant: CGFloat, trailingConstant: CGFloat) {
        super.setupView(leadingConstant: leadingConstant, trailingConstant: trailingConstant)
        containerViewBottomConstraint?.isActive = false
        containerViewBottomConstraint = nil
        containerView.heightAnchor.constraint(equalToConstant: 75).isActive = true
        
        let stackView: UIStackView = {
           let view = UIStackView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.axis = .vertical
            view.distribution = .fillProportionally
            view.addArrangedSubview(questionLabel)
            view.addArrangedSubview(picker)
            return view
        }()
        
        contentView.addSubview(stackView)
        stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
        stackView.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 32).isActive = true
        stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16).isActive = true
    }
    
    func fade() {
        picker.alpha = 0
        questionLabel.alpha = 0
        
        UIView.animate(withDuration: 0.2, delay: 2.0, options: UIView.AnimationOptions.curveLinear, animations: {
            self.picker.alpha = 1.0
            self.questionLabel.alpha = 1
        }, completion: nil)
    }
}

extension SelectedSpecieCell: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Items.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let label = UILabel()
        label.font = UIFont.appPrimary()
        label.textColor = UIColor.appWhite()
        label.text = Items.allCases[row].rawValue
        label.textAlignment = .center
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: Items.allCases[row].rawValue, attributes: [NSAttributedString.Key.font: UIFont.appPrimary(customSize: 8), NSAttributedString.Key.foregroundColor: UIColor.appWhite()])
    }
}
