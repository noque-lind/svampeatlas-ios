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
    static let height: CGFloat = 200
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.whiteLarge)
        spinner.startAnimating()
        spinner.hidesWhenStopped = false
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.widthAnchor.constraint(equalToConstant: 50).isActive = true
        spinner.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return spinner
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        spinner.alpha = 0
    }

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
    
    func show() {
        UIView.animate(withDuration: 0.2) {
            self.spinner.alpha = 1
        }
        
        spinner.startAnimating()
    }
}
