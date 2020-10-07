//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Famil Samadli on 10/5/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import CoreData
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    //initialize Realm
    let realm = try! Realm()
    
    //core data version
    //var categoryArray = [Category]()
    
    //realm version
    var categoryArray: Results<Category>?
    
    // core data
    //let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation error")}
        navBar.backgroundColor = UIColor(hexString: "1D9BF6")
    }

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var newText = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        //add button clicked
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            
            //plist version
            //let newItem = ItemOld()
            
            //core data version
            //let newCategory = Category(context: self.context)
            
            //realm version
            let newCategory = Category()
            
            newCategory.name = newText.text!
            newCategory.cellColor = UIColor.randomFlat().hexValue()
            //self.categoryArray.append(newCategory)
            
            self.saveCategories(category: newCategory)
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
    
    //needed functions for showing data in tableview
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray?.count ?? 1;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let category = categoryArray?[indexPath.row] {
            cell.textLabel?.text = category.name ?? "No Categories Added Yet";
            
            cell.backgroundColor = UIColor(hexString: category.cellColor ?? "#1D9BF6")
            cell.textLabel?.textColor = ContrastColorOf(UIColor(hexString: category.cellColor)!, returnFlat: true)
        }
        
        return cell;
    }
    
    func saveCategories(category: Category) {
        do {
            //coredata version
            //try context.save()
            
            //realm version
            try realm.write {
                realm.add(category)
            }
        }catch {
            print("Error encoding item array")
        }
        tableView.reloadData()
    }
    
    //core data version
//    func loadCategories(request: NSFetchRequest<Category> = Category.fetchRequest()) {
//        do {
//            categoryArray = try context.fetch(request)
//        }catch {
//            print("Error in fetching data")
//        }
//        tableView.reloadData()
//    }
    
    //realm version
    func loadCategories() {
        
        categoryArray = realm.objects(Category.self)
        
        tableView.reloadData()
    }
    
    //swipe and delete
    override func updateModel(indexPath: IndexPath) {
        if let deletedCategory = self.categoryArray?[indexPath.row] {
            do{
                try self.realm.write {
                    self.realm.delete(deletedCategory)
                }
            }catch{
                print(error)
            }
        }
    }
    
    //cell clicked
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self);
        //deselect row after selecting it
        tableView.deselectRow(at: indexPath, animated: true);
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray?[indexPath.row]
        }
    }

}
