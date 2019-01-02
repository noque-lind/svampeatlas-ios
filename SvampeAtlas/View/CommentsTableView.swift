//
//  NotificationsTableView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 31/10/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class CommentsTableView: GenericTableView, UITableViewDelegate, UITableViewDataSource {
    
    private var comments = [Comment]()
    
    override func setupView() {
        tableView.register(CommentCell.self, forCellReuseIdentifier: "commentCell")
        tableView.delegate = self
        tableView.dataSource = self
        super.setupView()
    }
    
    func configure(comments: [Comment]) {
        self.comments = comments
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! CommentCell
        cell.configureCell(comment: comments[indexPath.row])
        return cell
    }
    }

