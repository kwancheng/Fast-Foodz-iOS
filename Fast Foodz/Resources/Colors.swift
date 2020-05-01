//
//  Colors.swift
//  Fast Foodz
//

import UIKit

extension UIColor {
    static let competitionPurple = UIColor(hexString: "6d00ff")
    static let londonSky = UIColor(hexString: "eef0f1")
    static let deepIndigo = UIColor(hexString: "270450")
    static let bluCepheus = UIColor(hexString: "00d2ff")
    static let mexicoBlue = UIColor(hexString: "13a8f1")
    static let osloBlue = UIColor(hexString: "2e7aff")
    static let rubystoneRed = UIColor(hexString: "c31eba")
    static let superPink = UIColor(hexString: "ff4281")
    static let lilacGrey = UIColor(hexString: "7e7687")
    static let powderBlue = UIColor(hexString: "b5c7de")
    static let viola = UIColor(hexString: "9213d5")
    static let pickleGreen = UIColor(hexString: "28c760")
    static let gradientColors: [UIColor] = [.bluCepheus, .mexicoBlue, .osloBlue, .competitionPurple, .viola, .rubystoneRed, .superPink]
    
    convenience init(hexString: String) {
        let a, r, g, b: UInt64
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        
        Scanner(string: hex).scanHexInt64(&int)
        
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
