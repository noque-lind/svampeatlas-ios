//
//  LoaderCell.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 08/10/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class LoaderCell: UITableViewCell {
    
    static let identifier = "LoaderCell"
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.whiteLarge)
        spinner.startAnimating()
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupView() {
        backgroundColor = UIColor.clear
        selectionStyle = .none
        contentView.addSubview(spinner)
        spinner.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        spinner.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
    }
}
