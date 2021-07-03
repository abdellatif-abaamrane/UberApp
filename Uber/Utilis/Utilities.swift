//
//  Utilities.swift
//  Twitter
//
//  Created by macbook-pro on 13/05/2020.
//

import UIKit



class Utilities {
    static func attributedButton(_ firstPart: String,_ secondPart: String) -> UIButton {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: firstPart, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)])
        attributedTitle.append(NSMutableAttributedString(string: secondPart, attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16)]))
        button.setAttributedTitle(attributedTitle, for: .normal)
        return button
    }

    static func makeLayout(type: LayoutType) -> UICollectionViewLayout {
        switch type {
        case .flow:
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width , height: 100)
            layout.minimumLineSpacing = 10
            layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
            return layout
        case .Compositional:
            var configuration = UICollectionLayoutListConfiguration(appearance: .sidebarPlain)
            configuration.showsSeparators = false
            let layout = UICollectionViewCompositionalLayout.list(using: configuration)
            return layout
        }
    }
    enum LayoutType {
        case flow, Compositional
    }
    
   
    
    
}
