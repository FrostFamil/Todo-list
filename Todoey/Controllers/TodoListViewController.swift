//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {
    
    var itemArray = [Item]()
    
    //acces users default database
    let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let newItem = Item()
        newItem.title = "Find Mike"
        itemArray.append(newItem)
        
        //loading database from phone database
//        if let items = defaults.array(forKey: "TodoListArray") as? [String] {
//            itemArray = items
//        }
    }
    
    //needed functions for showing data in tableview
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        let item = itemArray[indexPath.row]
        cell.textLabel?.text = item.title;
    
        
        //adds and remove checkmark if certain row selected by user
        if item.done == true {
            cell.accessoryType = .checkmark
        }else {
            cell.accessoryType = .none
        }
        
        return cell;
    }
    
    //checks the row clicked by user
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //changes the done property of cell
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done;

        tableView.reloadData();
        
        //deselect row after selecting it
        tableView.deselectRow(at: indexPath, animated: true);
    }
    
    //Adding new items to list
    @IBAction func AddButtonPress(_ sender: UIBarButtonItem) {
        
        var newText = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        //add button clicked
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            let newItem = Item()
            newItem.title = newText.text!
            self.itemArray.append(newItem)
            
            //adds data to default database
            self.defaults.set(self.itemArray, forKey: "TodoListArray");
            
            //reload list inside array
            self.tableView.reloadData()
        }
        
        //adds text field to alert
        alert.addTextField { (alertText) in
            alertText.placeholder = "Create new item"
            newText = alertText
        }
        
        //shows alert
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    


}

