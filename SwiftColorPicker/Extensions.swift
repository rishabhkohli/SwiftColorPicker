import UIKit

extension UIColor {
	public func toHexString() -> String {
		var r:CGFloat = 0
		var g:CGFloat = 0
		var b:CGFloat = 0
		var a:CGFloat = 0
		
		getRed(&r, green: &g, blue: &b, alpha: &a)
		
		if (r<0 || g<0 || b<0 || r>1 || g>1 || b>1) { return String ("Error") }
		let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
		
		return String(format:"%06x", rgb)
	}
	
	/**
	The shorthand three-digit hexadecimal representation of color.
	#RGB defines to the color #RRGGBB.
	
	- parameter hex3: Three-digit hexadecimal value.
	- parameter alpha: 0.0 - 1.0. The default is 1.0.
	*/
	public convenience init(hex3: UInt16, alpha: CGFloat = 1) {
		let divisor = CGFloat(15)
		let red     = CGFloat((hex3 & 0xF00) >> 8) / divisor
		let green   = CGFloat((hex3 & 0x0F0) >> 4) / divisor
		let blue    = CGFloat( hex3 & 0x00F      ) / divisor
		self.init(red: red, green: green, blue: blue, alpha: alpha)
	}
	
	/**
	The six-digit hexadecimal representation of color of the form #RRGGBB.
	
	- parameter hex6: Six-digit hexadecimal value.
	*/
	public convenience init(hex6: UInt32, alpha: CGFloat = 1) {
		let divisor = CGFloat(255)
		let red     = CGFloat((hex6 & 0xFF0000) >> 16) / divisor
		let green   = CGFloat((hex6 & 0x00FF00) >>  8) / divisor
		let blue    = CGFloat( hex6 & 0x0000FF       ) / divisor
		self.init(red: red, green: green, blue: blue, alpha: alpha)
	}
	
	/**
	The rgba string representation of color with alpha of the form #RRGGBBAA/#RRGGBB, throws error.
	
	- parameter rgba: String value.
	*/
	public convenience init(rgba_throws rgba: String) throws {
		guard rgba.hasPrefix("#") else {
			throw UIColorInputError.missingHashMarkAsPrefix
		}
		
		//let hexString: String = rgba.substring(from: rgba.characters.index(rgba.startIndex, offsetBy: 1))
		let hexString: String = String(rgba[rgba.index(rgba.startIndex, offsetBy: 1)])
		var hexValue:  UInt32 = 0
		
		guard Scanner(string: hexString).scanHexInt32(&hexValue) else {
			throw UIColorInputError.unableToScanHexValue
		}
		
		switch (hexString.characters.count) {
		case 3:
			self.init(hex3: UInt16(hexValue))
		case 6:
			self.init(hex6: hexValue)
		default:
			throw UIColorInputError.mismatchedHexStringLength
		}
	}
	
	/**
	The rgba string representation of color with alpha of the form #RRGGBBAA/#RRGGBB, fails to default color.
	
	- parameter rgba: String value.
	*/
	public convenience init(_ rgba: String, defaultColor: UIColor = UIColor.clear) {
		guard let color = try? UIColor(rgba_throws: rgba) else {
			self.init(cgColor: defaultColor.cgColor)
			return
		}
		self.init(cgColor: color.cgColor)
	}
}

public enum UIColorInputError : Error {
	case missingHashMarkAsPrefix,
	unableToScanHexValue,
	mismatchedHexStringLength
}
