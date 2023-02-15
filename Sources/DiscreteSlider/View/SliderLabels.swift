//
//  MIT License
//
//  Copyright (c) 2023 hengyu
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import SwiftUI

struct SliderLabels<Option: Equatable>: View {
    private let label: AnySliderLabel<Option>
    private let options: [Option]

    /// Creates label for the slider.
    ///
    /// - Parameters:
    ///   - options: Options that is used as a data source for the slider.
    ///   - label: Customized slider's label.
    public init<Label: SliderLabel>(
        options: [Option],
        label: Label
    ) where Label.Option == Option {
        self.label = AnySliderLabel<Option>(label: label)
        self.options = options
    }

    public var body: some View {
        if options.count > 2 {
            HStack {
                ForEach(0 ..< options.count, id: \.self) {
                    label.makeBody(options[$0])
                    if $0 != options.count - 1 {
                        Spacer(minLength: 0)
                    }
                }
            }
        }
    }
}
