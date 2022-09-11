//
//  ResultCell.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 08/04/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class BaseCell: UITableViewCell {
    
    class var identifier: String {
        return "BaseCell"
    }
    
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
    
//    fileprivate lazy var disclosureButton: UIButton = {
//        let button = UIButton()
//        button.backgroundColor = UIColor.clear
//        button.alpha = 1
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.imageView?.contentMode = .scaleAspectFit
//        button.setImage(#imageLiteral(resourceName: "Glyphs_DisclosureButton").withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: [])
//        button.tintColor = .appWhite()
//        return button
//    }()
    
    fileprivate var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.appWhite()
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = CGFloat.cornerRadius()
        return view
    }()
    
    fileprivate var containerViewBottomConstraint: NSLayoutConstraint?
    
    var _textColor: UIColor? {
        didSet {
            titleLabel.textColor = _textColor
            secondaryLabel.textColor = _textColor
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
        _textColor = UIColor.appPrimaryColour()
        contentView.addSubview(containerView)
        containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: trailingConstant).isActive = true
        containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: leadingConstant).isActive = true
        containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        containerViewBottomConstraint = containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        containerViewBottomConstraint?.isActive = true
    }
}

private class HightlightableButton: UIButton {
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? UIColor.appThird(): UIColor.clear
        }
    }
}

class UnknownSpeciesCellButton: BaseCell {
    
    override class var identifier: String {
        return "UnknownSpeciesCellButton"
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        containerView.backgroundColor = highlighted ? UIColor.appThird(): UIColor.appWhite()
    }
    
    override func setupView(leadingConstant: CGFloat = 8, trailingConstant: CGFloat = -8) {
        roundedImageView.isMasked = false
        containerView.backgroundColor = UIColor.appWhite()
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
        textStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16).isActive = true
        textStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16).isActive = true
        textStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8).isActive = true
        
        super.setupView()
        
        configure()
    }
    
    private func configure() {
        titleLabel.text = NSLocalizedString("action_selectUnknownSpecie", comment: "")
        secondaryLabel.isHidden = true
        roundedImageView.configureImage(image: #imageLiteral(resourceName: "Icons_Utils_Missing").withRenderingMode(.alwaysTemplate))
    }
}

class UnknownSpecieCell: BaseCell {
    
    override class var identifier: String {
        return "UnknownSpecieCell"
    }
    
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
    
    var deselectButtonPressed: (() -> Void)?
    
    override func setupView(leadingConstant: CGFloat, trailingConstant: CGFloat) {
        roundedImageView.isMasked = false
        containerView.backgroundColor = UIColor.appWhite()
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
    
    override class var identifier: String {
        return "ContainedResultCell"
    }
    
    private var toxicityView: ToxicityViewHolder = {
        let view = ToxicityViewHolder()
        view.translatesAutoresizingMaskIntoConstraints = false
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
        
        tintColor = UIColor.appWhite()
        
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
    
        containerView.addSubview(toxicityView)
        toxicityView.topAnchor.constraint(equalTo: textStackView.bottomAnchor, constant: 8).isActive = true
        toxicityView.leadingAnchor.constraint(equalTo: textStackView.leadingAnchor).isActive = true
        toxicityView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -24).isActive = true
        toxicityView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
    }
    
    func configureCell(mushroom: Mushroom) {
        if mushroom.isGenus {
            var titleText = NSLocalizedString("containedResultCell_genus", comment: "")
            titleText.append(mushroom.localizedName ?? mushroom.fullName)
            titleLabel.text = titleText
            secondaryLabel.text = mushroom.localizedName != nil ? mushroom.fullName: nil
            secondaryLabel.attributedText = mushroom.localizedName != nil ? mushroom.fullName.italized(font: secondaryLabel.font): nil
            roundedImageView.configureImage(image: #imageLiteral(resourceName: "Icons_Utils_Genus").withRenderingMode(.alwaysTemplate))
            roundedImageView.tintColor = UIColor.appPrimaryColour()
        } else {
            titleLabel.text = mushroom.localizedName ?? mushroom.fullName
             secondaryLabel.text = mushroom.localizedName != nil ? mushroom.fullName: nil
            secondaryLabel.attributedText = mushroom.localizedName != nil ? mushroom.fullName.italized(font: secondaryLabel.font): nil
            roundedImageView.configureImage(url: mushroom.images?.first?.url)
        }
        
        toxicityView.configure(isPoisonous: mushroom.attributes?.isPoisonous ?? false)
        
        toxicityView.superview?.sizeToFit()
//        titleLabel.sizeToFit()
//        secondaryLabel.sizeToFit()
    }
    
    override func prepareForReuse() {
        decimalValueLabel.isHidden = true
//        toxicityView.isHidden = true
        super.prepareForReuse()
    }
    
    func configureCell(mushroom: Mushroom, confidence: Double) {
        configureCell(mushroom: mushroom)
//        decimalValueLabel.isHidden = false
//        decimalValueLabel.text =  "Ligner visuelt: \((confidence * 100).rounded(toPlaces: 2))%"
    }
}

class SelectedSpecieCell: ContainedResultCell {
    
    override class var identifier: String {
        return "SelectedSpecieCell"
    }
    
    private var questionLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.appWhite()
        label.font = UIFont.appPrimaryHightlighed()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("selectedSpeciesCell_question", comment: "")
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
    
    private var confidences = UserObservation.DeterminationConfidence.allCases
    private var isGenus: Bool = false
    var confidenceSelected: ((UserObservation.DeterminationConfidence) -> Void)?
    
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
    
    func configureCell(mushroom: Mushroom, confidence: UserObservation.DeterminationConfidence) {
        isGenus = mushroom.isGenus
        picker.reloadAllComponents()
        picker.selectRow(confidences.firstIndex(of: confidence) ?? 0, inComponent: 0, animated: false)
        super.configureCell(mushroom: mushroom)
    }

    private func getLabelForConfidence(confidence: UserObservation.DeterminationConfidence, isGenus: Bool) -> String {
        switch confidence {
        case .certain:
            return isGenus ? NSLocalizedString("selectedSpeciesCell_confident_genus", comment: ""): NSLocalizedString("selectedSpeciesCell_confident_species", comment: "")
        case .possible:
            return isGenus ? NSLocalizedString("selectedSpeciesCell_possible_genus", comment: ""): NSLocalizedString("selectedSpeciesCell_possible_species", comment: "")
        case .likely:
            return isGenus ? NSLocalizedString("selectedSpeciesCell_likely_genus", comment: ""): NSLocalizedString("selectedSpeciesCell_likely_species", comment: "")
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
