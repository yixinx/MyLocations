//
//  LocationsViewController.swift
//  MyLocations
//
//  Created by Yixin Xue on 3/19/17.
//  Copyright © 2017 Yixin Xue. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class LocationsViewController: UITableViewController{
    var managedObjectContext: NSManagedObjectContext!
    var locations = [Location]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fetchRequest = NSFetchRequest<Location>()
        
        let entity = Location.entity()
        fetchRequest.entity = entity
        let sortDescriptor = NSSortDescriptor(key:"date", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do{
            locations = try managedObjectContext.fetch(fetchRequest)
        }catch{
        }
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell
        
        let location = locations[indexPath.row]
        cell.configure(for: location)
        
        return cell
    }
}
