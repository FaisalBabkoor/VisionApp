//
//  RoundedShadowView.swift
//  VisionApp
//
//  Created by Faisal Babkoor on 9/24/18.
//  Copyright © 2018 Faisal Babkoor. All rights reserved.
//

import UIKit
@IBDesignable
class RoundedShadowView: UIView {

    override func prepareForInterfaceBuilder() {
        setupView()
    }
    fileprivate func setupView() {
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowRadius = 15
        self.layer.shadowOpacity = 0.75
        self.layer.cornerRadius = self.frame.height / 2
    }
    
    override func awakeFromNib() {
        setupView()
        super.awakeFromNib()
    }

}

