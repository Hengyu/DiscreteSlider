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

public struct ProminentSliderHandle: SliderHandle {

    public let width: CGFloat
    public let height: CGFloat

    @Environment(\.colorScheme) private var colorScheme

    public init(width: CGFloat = 24, height: CGFloat = 24) {
        self.width = width
        self.height = height
    }

    public func makeBody() -> some View {
        ZStack {
            Circle()
                .frame(width: width, height: height)
                .foregroundColor(.accentColor)

            Circle()
                .frame(width: width - 4, height: height - 4)
                #if os(macOS) || os(iOS)
                .foregroundColor(colorScheme == .light ? .white : .black)
                #else
                .foregroundStyle(.regularMaterial)
                #endif
        }
    }
}
