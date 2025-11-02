# DiscreteSlider

![](https://img.shields.io/badge/iOS-14.0%2B-green)
![](https://img.shields.io/badge/macCatalyst-14.0%2B-green)
![](https://img.shields.io/badge/macOS-11.0%2B-green)
![](https://img.shields.io/badge/Swift-5-orange?logo=Swift&logoColor=white)
![](https://img.shields.io/github/last-commit/hengyu/DiscreteSlider)

**DiscreteSlider** – slider which allows user to choose value only from predefined set of data. Slider may receive any types of options, you may pass set of integers or strings, or any other type. Written using `SwiftUI`.

## Table of contents

* [Requirements](#requirements)
* [Installation](#installation)
* [Usage](#usage)
    * [Quick start](#quick-start)
    * [Customization](#customization)
* [Acknowledgements](#acknowledgements)
* [License](#license)

## Requirements

- SwiftUI
- iOS 14.0+, macCatalyst 14.0+, macOS 11.0+, visionOS 1.0+

## Installation

**DiscreteSlider** could be installed via [Swift Package Manager](https://www.swift.org/package-manager/). Open Xcode and go to **File** -> **Add Packages...**, search `https://github.com/hengyu/DiscreteSlider.git`, and add the package as one of your project's dependency.

## Usage

**DiscreteSlider** is highly customizable, you could use it with it's default appearance or create your own.

### Quick start

To create a slider simply instantiate `DiscreteSlider` class:

```swift
DiscreteSlider(
    options: [20, 40, 60, 80, 100], // Options that is used as a data source for the slider.
    selectedItem: $mySelectedItem   // Binding to the property that will store the selected item.
)
```

This action will create a slider with default appearance.

### Customization

Customization of a slider is not a big deal. **DiscreteSlider** provides three protocols that is used to represent the components of a slider: `SliderTrackType`, `SliderTickType`, `SliderHandleType` and `SliderLabelType`. By implementing each of the protocol you will be able to build your custom slider.

Some examples of what you can achieve by customizing slider: 

![](Resources/Images/Examples.png)

## Acknowledgements

**DiscreteSlider** is originated from the [STDiscreteSlider](https://github.com/onl1ner/STDiscreteSlider) created by [onl1ner](https://github.com/onl1ner). We have made several updates based on the original work. And we want to express our heartful appreciation to the creator and contributers of **STDiscreteSlider**.

## License

**DiscreteSlider** is under the terms and conditions of the [MIT license](LICENSE).
