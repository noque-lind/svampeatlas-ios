//
//  NotesVC.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 12/03/2021.
//  Copyright © 2021 NaturhistoriskMuseum. All rights reserved.
//

import ELKit
import Foundation
import UIKit

class NotesVC: UIViewController {
    
    enum Item {
        case note(_ note: CDNote)
    }
    
    class CellProvider: NSObject, ELTableViewCellProvider {
        
        typealias CellItem = Item
        
        var deleteNote = ELEvent<(Item: CDNote, indexPath: IndexPath)>()
        var uploadNote = ELEvent<(Item: CDNote, indexPath: IndexPath)>()
        
        func cellForItem(_ item: NotesVC.Item, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
            switch item {
            case .note(let note):
                return tableView.dequeueReusableCell(withIdentifier: NoteCell.identifier, for: indexPath).then({
                    ($0 as? NoteCell)?.configure(note: note)
                    ($0 as? NoteCell)?.uploadPressed = { [weak self] in
                        self?.uploadNote.post(value: (note, indexPath))
                    }
                })
            }
        }
        
        func heightForItem(_ item: NotesVC.Item, tableView: UITableView, indexPath: IndexPath) -> CGFloat {
            UITableView.automaticDimension
        }
        
        func registerCells(tableView: UITableView) {
            tableView.register(NoteCell.self, forCellReuseIdentifier: NoteCell.identifier)
        }
        
        func canSwipeItem(_ item: NotesVC.Item, tableView: UITableView, indexPath: IndexPath) -> Bool {
            return true
        }
            
        func actionForItem(_ item: NotesVC.Item, _ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            switch item {
            case .note(let note):
                let action = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, completion in
                    self?.deleteNote.post(value: (note, indexPath))
                    completion(true)
                }
                action.backgroundColor = .appRed()
                if #available(iOS 13.0, *) {
                    action.image =  UIImage(systemName: "trash")
                } else {
                    action.image = #imageLiteral(resourceName: "Glyphs_Cancel")
                }
                return UISwipeActionsConfiguration(actions: [action])
            }
        }
    }
    
    private var gradientView: GradientView = {
        let view = GradientView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var tableView = ELTableView<Item, CellProvider>.build(provider: CellProvider().then({
        $0.deleteNote.handleEvent { [unowned vm] (item, indexPath) in
            vm.deleteNote(note: item, indexPath: indexPath)
        }
        
        $0.uploadNote.handleEvent { [unowned vm] (item, indexPath) in
            vm.uploadNote(note: item, indexPath: indexPath)
        }
    })).then({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.separatorStyle = .singleLine
        
        $0.didSelectItem.handleEvent { [unowned self] (item, _) in
            switch item {
            case .note(let note): self.navigationController?.pushViewController(AddObservationVC(type: .editNote(node: note), session: self.session), animated: true)
            }
        }
    })
    
    private lazy var vm = NotebookViewModel(session: session)
    private let session: Session
    
    init(session: Session) {
        self.session = session
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("MushroomVC Deinit")
        Database.instance.reset()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.appConfiguration(translucent: false)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
        super.viewWillAppear(animated)
    }
    
    private func setupView() {
        title = NSLocalizedString("Notebook", comment: "")
        navigationItem.setLeftBarButton(UIBarButtonItem(image: #imageLiteral(resourceName: "Icons_MenuIcons_MenuButton"), style: .plain, target: eLRevealViewController(), action: #selector(eLRevealViewController()?.toggleSideMenu)), animated: false)
        navigationItem.rightBarButtonItem?.width = 100
        navigationItem.setRightBarButton(.init(customView: ActionButton().then({
            $0.addTarget(self, action: #selector(newNote), for: .touchUpInside)
            $0.configure(text: NSLocalizedString("New note", comment: ""), icon: UIImage.init(systemName: "plus"))
        })), animated: false)
            
        view.backgroundColor = UIColor.appPrimaryColour()
    
        view.do({
        $0.addSubview(gradientView)
        $0.addSubview(tableView)
        })
        
        gradientView.do({
        ELSnap.snapView($0, toSuperview: view, ignoreSafeAreaInsets: true)
        })
        
        tableView.do({
            $0.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        $0.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        $0.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        $0.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        })
       
    }
    
    private func setupViewModel() {
        vm.notes.observe { [weak tableView] state in
            switch state {
            case .items(item: let items): tableView?.setSections(sections: [.init(title: nil, state: .items(items: items.map({Item.note(($0))})))])
            case .loading: tableView?.setSections(sections: [.init(title: nil, state: .loading)])
            case .error(error: let error, handler: let handler):
                tableView?.setSections(sections: [.init(title: nil, state: .error(error: error, handler: handler))])
            default: print("Nothing")
            }
        }
        
        vm.deleteNote.handleEvent { [unowned tableView] indexPath in
            DispatchQueue.main.async {
                tableView.performUpdates { updater in
                    updater.removeItem(indexPath: indexPath, animation: .left)
                }
            }
        }
        
        vm.show.handleEvent { [weak self] notif in
                notif.show(animationType: .fromBottom, queuePosition: .back, onViewController: self)
        }
        
        vm.loading.observe { [unowned self] loading in
            loading ? Spinner.start(onView: self.view): Spinner.stop()
        }
        
        vm.present.handleEvent { [weak self] vc in
            self?.present(vc, animated: true, completion: nil)
        }
    }
    
    @objc private func newNote() {
        navigationController?.pushViewController(AddObservationVC(type: .newNote, session: session), animated: true)
    }
}
