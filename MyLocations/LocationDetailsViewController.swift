//
//  LocationDetailsViewController.swift
//  MyLocations
//
//  Created by Yixin Xue on 2/28/17.
//  Copyright © 2017 Yixin Xue. All rights reserved.
//

import UIKit

class LocationDetailsViewController: UITableViewController{

    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBAction func done(){
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancel(){
        dismiss(animated: true, completion: nil)
    }




}
