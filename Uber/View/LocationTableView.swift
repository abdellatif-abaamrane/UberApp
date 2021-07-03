//
//  LocationTableView.swift
//  Uber
//
//  Created by macbook-pro on 21/05/2020.
//

import UIKit
import MapKit

protocol LocationTableViewDelegate: AnyObject {
    func didChooseLocation(mapItem: MKMapItem)
}

class LocationTableView: UITableView {

    var mapItems = [MKMapItem]() {
        didSet {
            reloadData()
        }
    }
    weak var locationDelegate : LocationTableViewDelegate?
    init() {
        super.init(frame: .zero, style: .insetGrouped)
        delegate = self
        dataSource = self
        register(LocationCell.self, forCellReuseIdentifier: "location")
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .blackUber
        contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        rowHeight = UITableView.automaticDimension
        estimatedRowHeight = UITableView.automaticDimension

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
}
extension LocationTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let mapItem = mapItems[indexPath.row]
            locationDelegate?.didChooseLocation(mapItem: mapItem)
        } 
    }
}
extension LocationTableView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? 2 : mapItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "location", for: indexPath) as! LocationCell
        if indexPath.section == 1 {
            let item = mapItems[indexPath.row]
            cell.mapItem = item
        } else {
            cell.itemImageView.isHidden = true
            cell.locationName.text = "Location Name"
            cell.locationAddress.text = "Location Address"

        }
        return cell
    }
    
    
}
extension LocationTableView: MainViewControllerDelegate {
    func displayItems(items: [MKMapItem]) {
        self.mapItems = items
    }
    
    
}
