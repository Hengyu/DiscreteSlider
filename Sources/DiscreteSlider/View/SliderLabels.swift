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
    private let edgeSpacing: CGFloat
    @Environment(\.width) private var width
    @State private var height: CGFloat = 0

    /// Creates label for the slider.
    ///
    /// - Parameters:
    ///   - options: Options that is used as a data source for the slider.
    ///   - label: Customized slider's label.
    public init<Label: SliderLabelType>(
        options: [Option],
        label: Label,
        edgeSpacing: CGFloat
    ) where Label.Option == Option {
        
        self.label = AnySliderLabel<Option>(label: label)
        self.options = options
        self.edgeSpacing = edgeSpacing
    }

    public var body: some View {
        if options.count >= 2 {
            ZStack {
                Group {
                    ForEach(0 ..< options.count, id: \.self) {
                        label.body(options[$0])
                            .position(x: centerX(for: $0), y: height / 2)
                    }
                }

                GeometryReader { proxy in
                    label.body(options.first!)
                        .foregroundColor(.clear)
                    .onAppear {
                        height = proxy.size.height
                    }
                }
            }
            .fixedSize(horizontal: false, vertical: true)
        } else if let option = options.first {
            label.body(option)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    private func centerX(for index: Int) -> CGFloat {
        (width - 2 * edgeSpacing) / CGFloat(options.count - 1) * CGFloat(index) + edgeSpacing
    }
}
