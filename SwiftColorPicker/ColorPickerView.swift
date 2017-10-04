import UIKit

internal protocol ColorPickerViewDelegate : NSObjectProtocol {
	func ColorPickerTouched(sender:ColorPickerView, color:UIColor, point:CGPoint, state:UIGestureRecognizerState)
}

@IBDesignable
class ColorPickerView : UIView {
	
	weak internal var delegate: ColorPickerViewDelegate?
	let saturationExponentTop:Float = 2.0
	let saturationExponentBottom:Float = 1.3
	
	let marker : UIView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 8))
	
	@IBInspectable var elementSize: CGFloat = 1.0 {
		didSet {
			setNeedsDisplay()
		}
	}
	
	private func initialize() {
		self.clipsToBounds = false
		let touchGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.touchedColor(gestureRecognizer:)))
		touchGesture.minimumPressDuration = 0
		touchGesture.allowableMovement = CGFloat.greatestFiniteMagnitude
		self.addGestureRecognizer(touchGesture)
		
		marker.layer.borderColor = UIColor.white.cgColor
		marker.layer.borderWidth = 1
		marker.clipsToBounds = true
		marker.layer.cornerRadius = min(marker.frame.size.height, marker.frame.size.width) / 2.0
		
		let innerMarker = UIView(frame: CGRect(x: 1, y: 1, width: 6, height: 6))
		innerMarker.layer.borderColor = UIColor.black.cgColor
		innerMarker.layer.borderWidth = 1
		innerMarker.clipsToBounds = true
		innerMarker.layer.cornerRadius = min(marker.frame.size.height, marker.frame.size.width) / 2.0
		
		marker.addSubview(innerMarker)
		self.addSubview(marker)
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		initialize()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		initialize()
	}
	
	override func draw(_ rect: CGRect) {
		let context = UIGraphicsGetCurrentContext()
		
		for y in stride(from: (0 as CGFloat), to: rect.height, by: elementSize) {
			
			var saturation = y < rect.height / 2.0 ? CGFloat(2 * y) / rect.height : 2.0 * CGFloat(rect.height - y) / rect.height
			saturation = CGFloat(powf(Float(saturation), y < rect.height / 2.0 ? saturationExponentTop : saturationExponentBottom))
			let brightness = y < rect.height / 2.0 ? CGFloat(1.0) : 2.0 * CGFloat(rect.height - y) / rect.height
			
			for x in stride(from: (0 as CGFloat), to: rect.width, by: elementSize) {
				let hue = x / rect.width
				let color = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
				context!.setFillColor(color.cgColor)
				context!.fill(CGRect(x:x, y:y, width:elementSize,height:elementSize))
			}
		}
	}
	
	func getColorAtPoint(point:CGPoint) -> UIColor {
			let roundedPoint = CGPoint(x:elementSize * CGFloat(Int(point.x / elementSize)),
			                           y:elementSize * CGFloat(Int(point.y / elementSize)))
			var saturation = roundedPoint.y < self.bounds.height / 2.0 ? CGFloat(2 * roundedPoint.y) / self.bounds.height
				: 2.0 * CGFloat(self.bounds.height - roundedPoint.y) / self.bounds.height
			saturation = CGFloat(powf(Float(saturation), roundedPoint.y < self.bounds.height / 2.0 ? saturationExponentTop : saturationExponentBottom))
			let brightness = roundedPoint.y < self.bounds.height / 2.0 ? CGFloat(1.0) : 2.0 * CGFloat(self.bounds.height - roundedPoint.y) / self.bounds.height
			let hue = roundedPoint.x / self.bounds.width
			return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
	}
	
	func getPointForColor(color:UIColor) -> CGPoint {
		var hue:CGFloat=0;
		var saturation:CGFloat=0;
		var brightness:CGFloat=0;
		color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: nil);
		
		var yPos:CGFloat = 0
		let halfHeight = (self.bounds.height / 2)
		
		if (brightness >= 0.99) {
			let percentageY = powf(Float(saturation), 1.0 / saturationExponentTop)
			yPos = CGFloat(percentageY) * halfHeight
		} else {
			//use brightness to get Y
			yPos = halfHeight + halfHeight * (1.0 - brightness)
		}
		
		let xPos = hue * self.bounds.width
		
		return CGPoint(x: xPos, y: yPos)
	}
	
	@objc func touchedColor(gestureRecognizer: UILongPressGestureRecognizer){
		let point = gestureRecognizer.location(in: self)
		
		var sanitizedPoint = point
		if (sanitizedPoint.x < self.bounds.origin.x) {
			sanitizedPoint = CGPoint(x:self.bounds.origin.x, y:sanitizedPoint.y)
		}
		if (sanitizedPoint.y < self.bounds.origin.y) {
			sanitizedPoint = CGPoint(x:sanitizedPoint.x, y:self.bounds.origin.y)
		}
		if (sanitizedPoint.x > self.bounds.width) {
			sanitizedPoint = CGPoint(x:self.bounds.width, y:sanitizedPoint.y)
		}
		if (sanitizedPoint.y > self.bounds.height) {
			sanitizedPoint = CGPoint(x:sanitizedPoint.x, y:self.bounds.height)
		}
		
		let color = getColorAtPoint(point: sanitizedPoint)
		
		marker.frame.origin = CGPoint(x:sanitizedPoint.x - 4, y: sanitizedPoint.y - 4)
		
		self.delegate?.ColorPickerTouched(sender: self, color: color, point: point, state:gestureRecognizer.state)
	}
	
	func update(forColor:UIColor) {
		let point = getPointForColor(color: forColor)
		marker.frame.origin = CGPoint(x:point.x - 4, y: point.y - 4)
	}
}
