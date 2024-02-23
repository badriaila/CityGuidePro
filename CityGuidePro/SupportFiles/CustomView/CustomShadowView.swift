//
//  CustomShadowView.swift
//  mwallet-ios
//
//  Updated by AJ
//  Copyright © 2023 SoftwareGroup. All rights reserved.
//

import UIKit

class CustomShadowView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    private func setupView() {
//        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 0.5
        layer.cornerRadius = 24
        layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowOpacity = 2.0
        layer.shadowRadius = 5.0
        layer.masksToBounds = false
    }
}
