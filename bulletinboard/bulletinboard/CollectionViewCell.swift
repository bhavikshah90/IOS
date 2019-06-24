//
//  CollectionViewCell.swift
//  bulletinboard
//
//  Created by bhavik on 14/12/18.
//  Copyright © 2018 bhavik. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
   lazy var textView: UITextView = {
        let tv = UITextView()
            tv.translatesAutoresizingMaskIntoConstraints = false
            tv.text="SOme sample"
            tv.font = UIFont.systemFont(ofSize: 15.0)
        return tv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(textView)
        textView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        textView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        textView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
      //  backgroundColor = UIColor.red
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
