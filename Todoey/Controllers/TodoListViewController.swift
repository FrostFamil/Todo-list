//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    //core data version
    //var itemArray = [Item]()
    
    //realm version
    var itemArray: Results<Item>?
    let realm = try! Realm()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var selectedCategory: Category? {
        didSet{
            loadItems()
        }
    }
    
    //file path and creating our own plist
//    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//                                  .first?.appendingPathComponent("Items.plist")
    
    // core data
    //let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //acces users default database
    //let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //loading database from phone database
//        if let items = defaults.array(forKey: "TodoListArray") as? [Item] {
//            itemArray = items
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let colorHex = selectedCategory?.cellColor {
            
            title = selectedCategory!.name
            
            guard let navBar = navigationController?.navigationBar else {fatalError("Navigation error")}
            navBar.backgroundColor = UIColor(hexString: colorHex)
            
            navBar.tintColor = ContrastColorOf(UIColor(hexString: colorHex)!, returnFlat: true)
            
            navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(UIColor(hexString: colorHex)!, returnFlat: true)]
            
            //searchBar.barTintColor = UIColor(hexString: colorHex)
        }
    }
    
    //needed functions for showing data in tableview
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray?.count ?? 1;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = itemArray?[indexPath.row] {
            cell.textLabel?.text = item.title;
            
            if let color = UIColor(hexString: selectedCategory!.cellColor)?.darken(byPercentage: (CGFloat(indexPath.row) / CGFloat(itemArray!.count))) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
                
            //adds and remove checkmark if certain row selected by user
            cell.accessoryType = item.done ? .checkmark : .none
        }else {
            cell.textLabel?.text = "No Items Added";
        }
        
        return cell;
    }
    
    //checks the row clicked by user
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //update the property in db core data
        //itemArray[indexPath.row].setValue("Completed", forKey: "title")
        
        //update data in realm
        if let item = itemArray?[indexPath.row] {
            do{
                try realm.write {
                    item.done = !item.done
                    
                    //delete clicked item
                    //realm.delete(item)
                }
            }catch{
                print(error)
            }
        }
        
        
        
        tableView.reloadData()
        
        //remove the property in db
        //context.delete(itemArray[indexPath.row])
        //itemArray.remove(at: indexPath.row)
        
        //changes the done property of cell
        //itemArray[indexPath.row].done = !itemArray[indexPath.row].done;

        //saveItems()
        
        //deselect row after selecting it
        tableView.deselectRow(at: indexPath, animated: true);
    }
    
    //Adding new items to list
    @IBAction func AddButtonPress(_ sender: UIBarButtonItem) {
        
        var newText = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        //add button clicked
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            //plist version
            //let newItem = ItemOld()
            
            //core data version
            //let newItem = Item(context: self.context)
            //newItem.parentCategory = self.selectedCategory
            //self.itemArray.append(newItem)
            
            //realm version
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = newText.text!
                        newItem.dateCreated = Date()
                        //newItem.done = false
                        currentCategory.items.append(newItem)
                    }
                }catch{
                    print(error)
                }
            }
            
            self.tableView.reloadData()
            
            //adds data to default database
            //self.defaults.set(self.itemArray, forKey: "TodoListArray");
            
            //creating custom plist
            //self.saveItems()
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
    
//    func saveItems() {
//        //let encoder = PropertyListEncoder()
//        do {
//            //let data = try encoder.encode(itemArray)
//            //try data.write(to: dataFilePath!)
//            try context.save()
//        }catch {
//            print("Error encoding item array")
//        }
//
//        //reload list inside array
//        tableView.reloadData()
//    }
    
    //core data version
//    func loadItems(request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
//        //plist
////        if let data = try? Data(contentsOf: dataFilePath!) {
////            let decoder = PropertyListDecoder()
////            do {
////                itemArray = try decoder.decode([Item].self, from: data)
////            }catch {
////                print(error)
////            }
////        }
//
//        //Core data
//        //let request: NSFetchRequest<Item> = Item.fetchRequest()
//
//        //getting items only which have parentCategory
//        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
//
//        if let additionalPredicate = predicate {
//            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
//        }else{
//            request.predicate = categoryPredicate
//        }
//
//        do {
//            itemArray = try context.fetch(request)
//        }catch {
//            print("Error in fetching data")
//        }
//        tableView.reloadData()
//    }
       
    //realm version
    func loadItems() {
        itemArray = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
    }
    
    override func updateModel(indexPath: IndexPath) {
        if let item = itemArray?[indexPath.row] {
            do{
                try self.realm.write {
                    self.realm.delete(item)
                }
            }catch{
                print(error)
            }
        }
    }
}
    
    

//MARK: - Search bar methods
extension TodoListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //core data
//        let newRequest: NSFetchRequest<Item> = Item.fetchRequest()
//
//        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
//
//        //sort getting data
//        newRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
//
//        loadItems(request: newRequest, predicate: predicate)
        
        //realm version
        itemArray = itemArray?.filter("title CONTAINS[cd] %@", searchBar.text).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
    }

    //when search bar is empty
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()

            //makes search goes back when keyboard dissmissed
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

