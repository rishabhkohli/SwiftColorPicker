
import UIKit

public protocol ColorPickerViewControllerDelegate {
	func colorSelected(id: Int, color: UIColor)
}

public class ColorPickerController: UIViewController, ColorPickerViewDelegate, UITextFieldDelegate {
	
	@IBOutlet weak var navBar: UINavigationBar!
	
	@IBOutlet weak var colorPickerView: ColorPickerView!
	
	@IBOutlet weak var oldColorView: UIView!
	@IBOutlet weak var newColorView: UIView!
	
	@IBOutlet weak var oldColorHex: UITextField!
	@IBOutlet weak var newColorHex: UITextField!
	
	var oldColor: UIColor!
	var newColor: UIColor!
	
	public var delegate: ColorPickerViewControllerDelegate?
	
	var id: Int!
	
	var firstTime = true
	
	public convenience init() {
		self.init(id: 0, currentColor: UIColor.white)
	}
	
	public init(id: Int, currentColor: UIColor) {
		super.init(nibName : "ColorPickerController", bundle : Bundle(for: ColorPickerController.self))
		self.id = id
		oldColor = currentColor
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    override public func viewDidLoad() {
		super.viewDidLoad()
		
		let navItems = UINavigationItem(title: "Pick Color")
		navItems.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissSelf))
		navItems.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
		navBar.items = [navItems]
		
		colorPickerView.delegate = self
		
		newColor = oldColor
		
		oldColorView.layer.borderColor = UIColor.black.cgColor
		oldColorView.layer.borderWidth = 1
		
		newColorView.layer.borderColor = UIColor.black.cgColor
		newColorView.layer.borderWidth = 1
		
		oldColorView.backgroundColor = oldColor
		newColorView.backgroundColor = newColor
		
		oldColorHex.text = oldColor.toHexString()
		oldColorHex.isEnabled = false
		
		newColorHex.text = newColor.toHexString()
		newColorHex.delegate = self
		colorPickerView.update(forColor: newColor)
    }
	
	public override func viewDidLayoutSubviews() {
		if (firstTime) {
			navBar.frame.size.height = navBar.frame.height + self.topLayoutGuide.length
			navBar.heightAnchor.constraint(equalToConstant: navBar.frame.height).isActive = true
			firstTime = false
		}
	}
	
	@objc func dismissSelf() {
		self.dismiss(animated: true, completion: nil)
	}
	
	@objc func save() {
		delegate?.colorSelected(id: id, color: newColor)
		dismissSelf()
	}
	
	func ColorPickerTouched(sender: ColorPickerView, color: UIColor, point: CGPoint, state: UIGestureRecognizerState) {
		newColor = color
		newColorView.backgroundColor = color
		newColorHex.text = newColor.toHexString()
		newColorHex.resignFirstResponder()
	}
	
	public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		let currentCharacterCount = textField.text?.characters.count ?? 0
		if (range.length + range.location > currentCharacterCount){
			return false
		}
		let newLength = currentCharacterCount + string.characters.count - range.length
		if (newLength <= 6) {
			let aSet = NSCharacterSet(charactersIn:"0123456789abcdefABCDEF").inverted
			let compSepByCharInSet = string.components(separatedBy: aSet)
			let hexFiltered = compSepByCharInSet.joined(separator: "")
			if string == hexFiltered {
				newColor = UIColor("#" + textField.text! + string)
				colorPickerView.update(forColor: newColor)
				newColorView.backgroundColor = newColor
				return true
			} else { return false }
		} else { return false }
	}
	
	public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
}
