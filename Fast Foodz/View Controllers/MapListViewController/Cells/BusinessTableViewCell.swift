//
//  BusinessTableViewCell.swift
//  Fast Foodz
//
//  Created by Kwan Cheng on 4/23/20.
//

import UIKit

class BusinessTableViewCell: UITableViewCell {
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var chevronImage: UIImageView!
    @IBOutlet weak var separatorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        categoryImage.tintColor = UIColor.powderBlue
        titleLabel.textColor = UIColor.deepIndigo
        infoLabel.textColor = UIColor.lilacGrey
        chevronImage.tintColor = UIColor.deepIndigo
        separatorView.backgroundColor = UIColor.londonSky
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = nil
        infoLabel.text = nil
        categoryImage.image = nil
    }
        
    func populateCell(business: Business) {
        let catImage: UIImage? = {
            for category in business.categories {
                guard let alias = category.alias,
                    let image = UIImage(named: alias)
                    else { continue }
                return image
            }
            return nil
        }()
        
        categoryImage.image = catImage
        titleLabel.text = business.name
                
        let infoText = styledInfoText(business)
        infoLabel.attributedText = infoText
    }
    
    fileprivate func styledInfoText(_ business: Business) -> NSAttributedString {
        // assemble the string
        var infoTextComponents = [String]()
        
        if let priceSymbol = business.price {
            var psarr = priceSymbol.map({$0})
            let charsToAdd = 4 - psarr.count
            for _ in 1 ... charsToAdd {
                psarr.append(psarr[0])
            }
            infoTextComponents.append(String(psarr))
        }

        let distanceMiles: Double? = {
            guard let dist = business.distance.value else { return nil }
            return Measurement(value: dist, unit: UnitLength.meters)
                .converted(to: UnitLength.miles).value
        }()
        
        if let distanceMiles = distanceMiles {
            if !infoTextComponents.isEmpty {
                infoTextComponents.append("•")
            }
            
            infoTextComponents.append("\(String(format:"%.2f", distanceMiles)) miles")
        }
        
        let infoTextStr = infoTextComponents.joined(separator: " ")
        let infoTextAttrib = NSMutableAttributedString(string: infoTextStr)
        if let priceStr = business.price {
            let range = (infoTextStr as NSString).range(of: priceStr)
            infoTextAttrib.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.pickleGreen, range: range)
        }
                
        return infoTextAttrib
    }
}
