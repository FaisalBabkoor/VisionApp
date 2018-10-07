//
//  RoundedShadowImageView.swift
//  VisionApp
//
//  Created by Faisal Babkoor on 9/25/18.
//  Copyright © 2018 Faisal Babkoor. All rights reserved.
//

import UIKit
@IBDesignable

class RoundedShadowImageView: UIImageView {

   
    override func prepareForInterfaceBuilder() {
        setupView()
    }
    fileprivate func setupView() {
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowRadius = 15
        self.layer.shadowOpacity = 0.75
        self.layer.cornerRadius = 15
    }
    
    override func awakeFromNib() {
        setupView()
        super.awakeFromNib()
    }
    
}

