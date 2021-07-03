//
//  LocationCellViewModel.swift
//  Uber
//
//  Created by macbook-pro on 22/05/2020.
//

import MapKit
import LinkPresentation

class LocationCellViewModel {
    let cell : LocationCell
    let mapItem: MKMapItem
    
    init(cell: LocationCell, mapItem: MKMapItem) {
        self.cell = cell
        self.mapItem = mapItem
    }
    
    
    func configueViewModel() {
        if let url = mapItem.url {
            //fetch(url, imageView: cell.itemImageView)
        }
        cell.locationName.text = mapItem.name 
        cell.locationAddress.text = mapItem.placemark.title
    }
    func fetch(_ url:URL, imageView:UIImageView) {
        let metaDataProvider = LPMetadataProvider()
        metaDataProvider.startFetchingMetadata(for: url) { (metaData, error) in
            if let metaData = metaData {
                if let imageProvider = metaData.imageProvider {
                    imageProvider.loadObject(ofClass: UIImage.self) { image, error in
                        if let error = error {
                            print(error.localizedDescription)
                            return
                        }
                        DispatchQueue.main.async {
                            imageView.image = image as? UIImage
                        }
                    }
                } else if let iconProvider = metaData.iconProvider {
                    iconProvider.loadObject(ofClass: UIImage.self) { image, error in
                        if let error = error {
                            print(error.localizedDescription)
                            return
                        }
                        DispatchQueue.main.async {
                            imageView.image = image as? UIImage
                        }
                    }
                    
                }
            }
        }
    }
}

