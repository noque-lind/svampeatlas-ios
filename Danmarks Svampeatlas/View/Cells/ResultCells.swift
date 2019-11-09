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
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    fileprivate lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.appPrimaryHightlighed()
        label.textColor = UIColor.appWhite()
        label.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        label.setContentHuggingPriority(.required, for: .vertical)
        label.numberOfLines = 0
        return label
    }()
    
    fileprivate lazy var secondaryLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.appPrimary()
        label.textColor = UIColor.appWhite()
        label.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        label.setContentHuggingPriority(.required, for: .vertical)
        label.numberOfLines = 0
        return label
    }()
    
    fileprivate lazy var textStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = UIStackView.Distribution.fill
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
        button.setImage(#imageLiteral(resourceName: "Glyphs_DisclosureButton").withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: [])
        return button
    }()
    
    fileprivate var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.appWhite()
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = CGFloat.cornerRadius()
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
        containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        containerViewBottomConstraint = containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        containerViewBottomConstraint?.isActive = true
    }
}

fileprivate class HightlightableButton: UIButton {
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? UIColor.appThird(): UIColor.clear
        }
    }
}

class UnknownSpeciesCellButton: BaseCell {
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        containerView.backgroundColor = highlighted ? UIColor.appThird(): UIColor.appWhite()
    }
    
    override func setupView(leadingConstant: CGFloat = 8, trailingConstant: CGFloat = -8) {
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
        textStackView.distribution = .fill
        containerView.addSubview(textStackView)
        textStackView.leadingAnchor.constraint(equalTo: roundedImageView.trailingAnchor, constant: 10).isActive = true
        textStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 4).isActive = true
        textStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -4).isActive = true
        textStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8).isActive = true
        
        super.setupView()
        
        configure()
    }
    
    private func configure() {
        titleLabel.text = "Ubestemt svamp"
        secondaryLabel.text = "Klik her for at indlægge en ubestemt svamp - fælleskabet vil prøve at hjælpe med bestemmelsen"
        roundedImageView.isMasked = false
        roundedImageView.configureImage(image: #imageLiteral(resourceName: "Icons_Utils_Missing").withRenderingMode(.alwaysTemplate))
    }
}

class UnknownSpecieCell: BaseCell {
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Fortryd", for: [])
        button.addTarget(self, action: #selector(cancelButtonPressed), for: .touchUpInside)
        button.setTitleColor(UIColor.appPrimaryColour(), for: .highlighted)
        button.titleLabel?.font = UIFont.appPrimary()
        button.setTitleColor(UIColor.appThird(), for: [])
        return button
    }()
    
    var deselectButtonPressed: (() -> ())?
    
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
        
        //        secondaryLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        secondaryLabel.numberOfLines = 0
        textStackView.distribution = .fill
        //        textStackView.setContentCompressionResistancePriority(.required, for: .vertical)
        
        containerView.addSubview(cancelButton)
        cancelButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        cancelButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -4).isActive = true
        
        containerView.addSubview(textStackView)
        textStackView.leadingAnchor.constraint(equalTo: roundedImageView.trailingAnchor, constant: 10).isActive = true
        textStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 4).isActive = true
        textStackView.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -8).isActive = true
        textStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8).isActive = true
        
        super.setupView(leadingConstant: leadingConstant, trailingConstant: trailingConstant)
        configureCell()
    }
    
    @objc private func cancelButtonPressed() {
        deselectButtonPressed?()
    }
    
    private func configureCell() {
        titleLabel.text = "Ukendt svamp"
        secondaryLabel.text = "Du indlægger dit fund som en ubestemt svamp. Hold øje med dit fund her i appen, så kan det være at fællesskabet kan identificere arten for dig."
        roundedImageView.isMasked = false
        roundedImageView.configureImage(image: #imageLiteral(resourceName: "Icons_Utils_Missing").withRenderingMode(.alwaysTemplate))
    }
}

class ContainedResultCell: BaseCell {
    
    private var toxicityView: ToxicityView = {
        let view = ToxicityView()
        return view
    }()
    
    private var decimalValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.appPrimary(customSize: 12)
        label.textAlignment = .left
        label.isHidden = true
        label.textColor = UIColor.appPrimaryColour()
        return label
    }()
    
    override func setupView(leadingConstant: CGFloat, trailingConstant: CGFloat) {
        super.setupView(leadingConstant: leadingConstant, trailingConstant: trailingConstant)
        
        tintColor = UIColor.appPrimaryColour()
        
        containerView.addSubview(roundedImageView)
        roundedImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        roundedImageView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        roundedImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        roundedImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        let textStackView: UIStackView = {
            let stackView = UIStackView()
            stackView.spacing = 4
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.axis = .vertical
            stackView.addArrangedSubview(titleLabel)
            stackView.addArrangedSubview(secondaryLabel)
            return stackView
        }()
        
        
        containerView.addSubview(textStackView)
        textStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24).isActive = true
        textStackView.leadingAnchor.constraint(equalTo: roundedImageView.trailingAnchor, constant: 8).isActive = true
        textStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8).isActive = true
        
        
        let informationStackView: UIStackView = {
            let stackView = UIStackView()
           stackView.spacing = 4
            stackView.alignment = .center
            stackView.setContentHuggingPriority(.required, for: .vertical)
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.axis = .horizontal
            stackView.addArrangedSubview(toxicityView)
            stackView.addArrangedSubview(decimalValueLabel)
            stackView.addArrangedSubview(UIStackView())
            return stackView
        }()
        
        containerView.addSubview(informationStackView)
        informationStackView.topAnchor.constraint(equalTo: textStackView.bottomAnchor, constant: 8).isActive = true
        informationStackView.leadingAnchor.constraint(equalTo: textStackView.leadingAnchor).isActive = true
        informationStackView.trailingAnchor.constraint(equalTo: textStackView.trailingAnchor).isActive = true
        informationStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -24).isActive = true
        
    }
    
    func configureCell(mushroom: Mushroom) {
        if mushroom.isGenus {
            var titleText = "Slægt: "
            titleText.append(mushroom.danishName ?? mushroom.fullName)
            titleLabel.text = titleText
            secondaryLabel.attributedText = mushroom.danishName != nil ? mushroom.fullName.italized(font: secondaryLabel.font): nil
            roundedImageView.configureImage(image: #imageLiteral(resourceName: "Icons_Utils_Genus").withRenderingMode(.alwaysTemplate))
            roundedImageView.tintColor = UIColor.appPrimaryColour()
        } else {
            titleLabel.text = mushroom.danishName ?? mushroom.fullName
            secondaryLabel.attributedText = mushroom.danishName != nil ? mushroom.fullName.italized(font: secondaryLabel.font): nil
            roundedImageView.configureImage(url: mushroom.images?.first?.url)
        }
        
        toxicityView.configure(mushroom.attributes?.eatability)
        titleLabel.sizeToFit()
        secondaryLabel.sizeToFit()
    }
    
    override func prepareForReuse() {
        decimalValueLabel.isHidden = true
        toxicityView.isHidden = true
        super.prepareForReuse()
    }
    
    func configureCell(mushroom: Mushroom, confidence: Double) {
        configureCell(mushroom: mushroom)
        decimalValueLabel.isHidden = false
        decimalValueLabel.text =  "Ligner visuelt: \((confidence * 100).rounded(toPlaces: 2))%"
    }
}

class SelectedSpecieCell: ContainedResultCell {
    
    private var questionLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.appWhite()
        label.font = UIFont.appPrimaryHightlighed()
        label.translatesAutoresizingMaskIntoConstraints = false
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
    
    private var confidences = NewObservation.DeterminationConfidence.allCases
    private var isGenus: Bool = false
    var confidenceSelected: ((NewObservation.DeterminationConfidence) -> ())?
    
    override func setupView(leadingConstant: CGFloat, trailingConstant: CGFloat) {
        super.setupView(leadingConstant: leadingConstant, trailingConstant: trailingConstant)
        containerViewBottomConstraint?.isActive = false
        containerViewBottomConstraint = nil
        containerView.setContentHuggingPriority(.required, for: .vertical)
        
        let stackView: UIStackView = {
            let view = UIStackView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.axis = .vertical
            view.spacing = 4
            view.addArrangedSubview(questionLabel)
            view.addArrangedSubview(picker)
            return view
        }()
        
        contentView.addSubview(stackView)
        stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
        stackView.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 16).isActive = true
        stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
    }
    
    func configureCell(mushroom: Mushroom, confidence: NewObservation.DeterminationConfidence) {
        isGenus = mushroom.isGenus
        picker.reloadAllComponents()
        picker.selectRow(confidences.index(of: confidence) ?? 0, inComponent: 0, animated: false)
        super.configureCell(mushroom: mushroom)
    }
    

    private func getLabelForConfidence(confidence: NewObservation.DeterminationConfidence, isGenus: Bool) -> String {
        switch confidence {
        case .confident:
            return isGenus ? "Det er helt sikkert den her slægt": "Det er helt sikkert den her art"
        case .possible:
            return isGenus ? "Det er muligvis denne slægt": "Det er muligvis denne art"
        case .likely:
            return isGenus ? "Det er sandsynligvis denne slægt": "Det er sandsynligvis denne art"
        }
    }
}

extension SelectedSpecieCell: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return confidences.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let label = UILabel()
        label.font = UIFont.appPrimary()
        label.textColor = UIColor.appWhite()
        label.text = getLabelForConfidence(confidence: confidences[row], isGenus: isGenus)
        label.textAlignment = .center
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        confidenceSelected?(confidences[row])
    }
}
