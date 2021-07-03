//
//  LocationInputViewModel.swift
//  Uber
//
//  Created by macbook-pro on 22/05/2020.
//

import Foundation


class LocationInputViewModel {
    let user: User
    let inputView: LocationInputView
    init(inputView: LocationInputView, user: User) {
        self.inputView = inputView
        self.user = user
    }
    
    func configueUI() {
        inputView.fillNameLabel.text = user.fullname
    }
    
    
}
