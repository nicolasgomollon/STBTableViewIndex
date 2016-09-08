# STBTableViewIndex

STBTableViewIndex (STB is short for “Section Title Bar”) is a section index bar that only becomes visible when used (as seen in Ecoute), and works with UITableView and UICollectionView. STBTableViewIndex is written completely in Swift (adapted from Objective-C, original code by: [kreeger/BDKCollectionIndexView](https://github.com/kreeger/BDKCollectionIndexView)).

<img alt="Sample Screenshot" width="320" height="568" src="http://f.cl.ly/items/39080e3g1S0U2N120n3s/SampleScreenshot.png" />


## Usage

Here’s an example usage:

```swift
// Instantiate.
var indexView = STBTableViewIndex()

// Set titles.
indexView.titles = ["A", "B", "C", "D", "E"]

// Set delegate.
indexView.delegate = self

// Add subview.
navigationController?.view.addSubview(indexView)

// Enable automatic index bar hiding (hides when not in use).
indexView.autoHides = true

// Flash index bar (useful in methods such as viewWillAppear, to give the user a hint).
indexView.flashIndex()
```

Implement the delegate methods:

```swift
func tableViewIndexChanged(index: Int, title: String) {
	let indexPath = IndexPath(row: 0, section: index)
	tableView.scrollToRow(at: indexPath, at: .top, animated: false)
}

func tableViewIndexTopLayoutGuideLength() -> CGFloat {
	return topLayoutGuide.length
}

func tableViewIndexBottomLayoutGuideLength() -> CGFloat {
	return bottomLayoutGuide.length
}
```

See the IndexTest demo project included in this repository for a working example of the project, including the code above.


## Requirements

Since STBTableViewIndex is written in Swift, it requires Xcode 6 or above and works on iOS 7 and above.


## License

STBTableViewIndex is released under the MIT License.
