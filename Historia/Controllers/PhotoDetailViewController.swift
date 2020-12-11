//
//  PhotoDetailViewController.swift
//  Historia
//
//  Created by Ethan Printz on 12/3/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation
import UIKit
import ARKit

class PhotoDetailViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet var descriptionText: UITextView!
    @IBOutlet var sourceLabel: UILabel!
    @IBOutlet var dateSubLabel: UILabel!
    @IBOutlet var sourceSubLabel: UILabel!
    
    var name: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Get picture info from array with name
        let pictureIndex = descriptions.firstIndex(where: { (description) -> Bool in description.name == name})!
        let pictureDate = descriptions[pictureIndex].date
        let pictureDescription = descriptions[pictureIndex].description
        let pictureSource = descriptions[pictureIndex].source
        
        if name != nil {
            imageView.image = UIImage(named: name!)
            dateLabel.text = pictureDate
            dateLabel.font = newYorkFont
            sourceLabel.text = pictureSource
            sourceLabel.font = newYorkFont
            descriptionText.text = pictureDescription
            descriptionText.font = newYorkFontSmall
            dateSubLabel.font = newYorkFontSmall
            sourceSubLabel.font =  newYorkFontSmall
        }
    }
}
