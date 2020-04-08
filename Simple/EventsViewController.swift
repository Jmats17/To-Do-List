//
//  EventsViewController.swift
//  Simple
//
//  Created by Justin Matsnev on 3/4/20.
//  Copyright © 2020 Justin Matsnev. All rights reserved.
//

import UIKit
import CoreData

class EventsViewController: UIViewController {
    
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var newEventTextView: UITextView!
    @IBOutlet weak var tableView: UITableView!
    
    var items: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dateLbl.text = getFormattedDate(format: "E, d MMM yyyy")
        
        configureTextView_UI()
        
        self.newEventTextView.addDoneButton(title: "Add Item", target: self, selector: #selector(tapDone(sender:)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
        DataManager.loadItems { (didLoad, items, err) in
            if let err = err {
                print(err.localizedDescription)
                return
            }
            
            if didLoad {
                guard let items = items else {return}
                self.items = items
                self.tableView.reloadData()
            }
        }
    }
    
    func configureTextView_UI() {
        self.newEventTextView.textColor = .lightGray
        self.newEventTextView.text = "Add New Item Here..."
    }
    
    func getFormattedDate(format: String) -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
    
}

extension EventsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 78
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let deleteAction = UIContextualAction(style: .normal, title:  "Delete", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            DataManager.deleteItem(item: self.items[indexPath.row]) { (didDelete) in
                if didDelete {
                    self.items.remove(at: indexPath.row)
                    self.tableView.reloadData()
                }
            }
            success(true)
        })
        deleteAction.backgroundColor = .red
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventsCell", for: indexPath) as! EventCell
        let item = items[indexPath.row]
        
        cell.loadCellData(item: item.value(forKey: "todoItem") as! String,
                          timeStamp: item.value(forKey: "timeStamp") as! String)

        return cell
    }
}

extension EventsViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
        textView.textColor = UIColor(red: 33/255, green: 33/255, blue: 33/255, alpha: 1.0)
    }
    
    @objc func tapDone(sender: Any) {
        if newEventTextView.text != "" {
            let timeStamp = getFormattedDate(format: "MM-dd-yyyy h:mm a")
            
            DataManager.save(item: newEventTextView.text, date: timeStamp) { (didSave, item, err) in
                
                if let err = err {
                    print(err.localizedDescription)
                    return
                }
                
                if didSave {
                    guard let item = item else {return}
                    self.items.append(item)
                    self.tableView.reloadData()
                }
            }
            
        }
        configureTextView_UI()
        self.view.endEditing(true)
    }
}

extension UITextView {

    func addDoneButton(title: String, target: Any, selector: Selector) {

        let toolBar = UIToolbar(frame: CGRect(x: 0.0,
                                              y: 0.0,
                                              width: UIScreen.main.bounds.size.width,
                                              height: 44.0))//1
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)//2
        let barButton = UIBarButtonItem(title: title, style: .plain, target: target, action: selector)//3
        toolBar.setItems([flexible, barButton], animated: false)//4
        self.inputAccessoryView = toolBar//5
    }
}

class EventCell: UITableViewCell {
    
    @IBOutlet weak var todoLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    
    func loadCellData(item: String, timeStamp: String) {
        self.todoLbl.text = item
        self.dateLbl.text = timeStamp
    }
}
