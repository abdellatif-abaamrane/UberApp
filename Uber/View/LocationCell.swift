//
//  LocationCell.swift
//  Uber
//
//  Created by macbook-pro on 22/05/2020.
//

import UIKit
import LinkPresentation
import MapKit


class LocationCell: UITableViewCell {
    
    var mapItem : MKMapItem? {
        didSet {
            configue()
        }
    }

    lazy var itemImageView : UIImageView = {
        let imageView = UIImageView(image: UIImage(color: .blackUber, size: 50))
        imageView.layer.cornerRadius = 50/2
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    let locationName : UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .blackUber
        return label
    }()
    let locationAddress : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .darkGray
        return label
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configueUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configueUI() {

        let stackView = UIStackView(arrangedSubviews: [locationName, locationAddress])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fillProportionally
        stackView.spacing = 4
        
        let mainStackView = UIStackView(arrangedSubviews: [stackView])
        mainStackView.axis = .horizontal
        mainStackView.alignment = .center
        mainStackView.distribution = .fillProportionally
        mainStackView.spacing = 8
        
        addSubview(mainStackView)
        itemImageView.translatesAutoresizingMaskIntoConstraints = false
        locationName.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        locationAddress.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: topAnchor,constant: 12),
            mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor,constant: -12),
            mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor,constant: 12),
            mainStackView.trailingAnchor.constraint(equalTo: trailingAnchor,constant: -12),
            itemImageView.widthAnchor.constraint(equalToConstant: 50),
            itemImageView.heightAnchor.constraint(equalToConstant: 50),
            locationName.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            locationAddress.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            stackView.heightAnchor.constraint(equalTo: mainStackView.heightAnchor)
        ])
    }
    
    func configue() {
        guard let mapItem = mapItem else { return }
        let viewModel = LocationCellViewModel(cell: self, mapItem: mapItem)
        viewModel.configueViewModel()
    }
    
    
    
}
