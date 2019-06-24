//
//  NotificationsTableView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 31/10/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit
import ELKit

class CommentsTableView: GenericTableView<Comment> {

    public private(set) var allowComments: Bool
    var sendCommentHandler: ((_ comment: String) -> ())?
    
    
    init(allowComments: Bool, automaticallyAdjustHeight: Bool) {
        self.allowComments = allowComments
        super.init(automaticallyAdjustHeight: automaticallyAdjustHeight)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func setupView() {
        tableView.separatorStyle = .singleLine
        register(CommentCell.self, forCellReuseIdentifier: "commentCell")
        register(AddCommentCell.self, forCellReuseIdentifier: "addCommentCell")
        super.setupView()
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if allowComments {
            return tableViewState.itemsCount() + 1
        } else {
            return tableViewState.itemsCount()
        }
    }
   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let item = tableViewState.value(row: indexPath.row) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! CommentCell
            cell.configureCell(comment: item)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "addCommentCell", for: indexPath) as! AddCommentCell
            cell.configureCell(descriptionText: "Skriv en kommentar", placeholder: nil, content: nil, delegate: self)
            cell.sendButtonTappedHandler = sendCommentHandler
            return cell
        }
        }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    }

extension CommentsTableView: ELTextViewDelegate {
    func shouldChangeHeight() {
        UIView.setAnimationsEnabled(false)
        self.tableView.beginUpdates()
        ELKeyboardHelper.instance.reFocus()
        self.tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
    }
    
    func didUpdateTextEntry(title: String, _ text: String) {
        return
    }
}

