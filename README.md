# SwiftColorPicker
A color picking controller built in Swift 4

Minimum OS Target -> iOS 9.0

I couldn't find any color picker made for swift which fulfilled my requirement of being able to pick a color visually as well as using the hex code, so I made one myself.

<img src="https://github.com/rishabhkohli/SwiftColorPicker/blob/master/SwiftColorPicker.png?raw=true" height="600">

## Installation

Carthage -
Add this to your cartfile.
<code>github "rishabhkohli/SwiftColorPicker"</code>

## Usage
1. Initialize, set delegate, set presentation style and present. ColorPickerController takes two arguments - id and currentColor. If you don't provide any arguments, the default arguments of id=0 and currentColor=UIColor.white will be taken.
```swift
let colorPickerController = ColorPickerController(id: 0, currentColor: UIColor.blue)
colorPickerController.delegate = self
colorPickerController.modalPresentationStyle = .formSheet
present(colorPickerController, animated: true, completion: nil)
```


2. To get callback, adopt the delegate ColorPickerViewControllerDelegate in your class and add this function. It returns the same id that you initialized the ColorPickerController with. This way you can have multiple color pickers in the same class and get seperate callbacks from each of them.
```swift
func colorSelected(id: Int, color: UIColor) {
		switch id {
		case 0:
			print(color.toHexString())
			break
		default:
			break
		}
	}
```


Credits - 

Color Map - https://stackoverflow.com/a/34142316/6886672 <br>
UIColor Extension - https://github.com/yeahdongcn/UIColor-Hex-Swift
