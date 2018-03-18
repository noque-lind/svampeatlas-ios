//
//  ViewController.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 17/02/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var tableView: MushroomTableView!
    @IBOutlet weak var categoryView: CategoryView!
    
    var mushrooms = [Mushroom]()
    private var hasBeenSetup = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        categoryView.delegate = self

        self.navigationController?.navigationBar.tintColor = UIColor.appWhite()
        self.navigationController?.navigationBar.barTintColor = UIColor.appPrimaryColour()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.appWhite(), NSAttributedStringKey.font: UIFont.appTitle()]
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        view.backgroundColor = UIColor.appPrimaryColour()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !hasBeenSetup {
        categoryView.firstSelect()
            hasBeenSetup = true
        }
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
}




extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mushrooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "mushroomCell2", for: indexPath) as? MushroomCell else {
            // Show error to user
            return UITableViewCell()
        }
        cell.configureCell(withMushroom: mushrooms[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let detailsVC = self.storyboard?.instantiateViewController(withIdentifier: "detailsVC") as? DetailsViewController else {return}
        detailsVC.mushroom = mushrooms[indexPath.row]
        let safeAre = UIEdgeInsets(top: view.safeAreaLayoutGuide.layoutFrame.origin.y, left: 0, bottom: 0, right: 0)
        self.navigationController!.pushViewController(detailsVC, animated: true)
        self.additionalSafeAreaInsets = safeAre
    }
}

extension ViewController: CategoryViewDelegate {
    func newCategorySelected(category: Category) {
        tableView.categoryType = category
        mushrooms.removeAll()
        tableView.reloadData()
        switch category {
        case .offline:
            getOfflineMushrooms()
        default:
            getDanishMushrooms()
        }
    }
}

extension ViewController {
    private func getOfflineMushrooms() {
        
    }
    
    private func getFavoritesMushrooms() {
                tableView.reloadData()
    }
    
    private func getDanishMushrooms() {
        tableView.showLoader()
        DataService.instance.getMushrooms { (mushrooms) in
            DispatchQueue.main.async {
                self.mushrooms = mushrooms
                self.tableView.reloadData()
            }
        }
    }
}
