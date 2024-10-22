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

private struct WidthKey: EnvironmentKey {
    static let defaultValue: CGFloat = 0
}

extension EnvironmentValues {

    var width: CGFloat {
        get { self[WidthKey.self] }
        set { self[WidthKey.self] = newValue }
    }
}

struct SliderControl<Option: Equatable>: View {
    private let options: [Option]
    private let track: AnySliderTrack
    private let tick: AnySliderTick?
    private let handle: AnySliderHandle
    private let tickDisplayGuide: TickDisplayGuide
    private let animated: Bool

    private let step: CGFloat
    @Binding private var selectedItem: Option
    @State private var handleOffset: CGFloat = 0
    @State private var preselectedItem: Option?
    @Environment(\.width) private var width
    private var onItemPreselected: ((Option) -> Void)?

    private var selectedIndex: Int {
        options.firstIndex(of: selectedItem) ?? 0
    }

    /// Creates discrete slider with given track and handle.
    ///
    /// - Note: Use the initializer if you want only to have a track and handle in your discrete slider.
    /// - Parameters:
    ///   - options: Options that is used as a data source for the slider.
    ///   - track: Customized slider's track.
    ///   - tick: Customized slider's tick.
    ///   - handle: Customized slider's handle.
    ///   - selectedItem: Binding to the property that will store the selected item.
    public init<Track: SliderTrack, Tick: SliderTick, Handle: SliderHandle>(
        options: [Option],
        track: Track = DefaultSliderTrack(),
        tick: Tick? = DefaultSliderTick(),
        handle: Handle = DefaultSliderHandle(),
        tickDisplayGuide: TickDisplayGuide = .alwaysPresent,
        animated: Bool = true,
        selectedItem: Binding<Option>,
        onItemPreselected: ((Option) -> Void)? = nil
    ) {
        self.track  = .init(track: track)
        self.handle = .init(handle: handle)
        if let tick {
            self.tick = .init(tick: tick)
        } else {
            self.tick = nil
        }
        self.options = options
        self.tickDisplayGuide = tickDisplayGuide
        self.animated = animated
        self._selectedItem = selectedItem

        if options.count > 1 {
            step = 1.0 / CGFloat(options.count - 1)
        } else {
            step = 0
        }

        self.onItemPreselected = onItemPreselected
    }

    public var body: some View {
        ZStack(alignment: .init(horizontal: .leading, vertical: .center)) {
            track.makeTrack()
                .frame(width: width)

            track.makeFillTrack()
                .frame(width: handleOffset + handle.width / 2)

            if let tick, step != 0 {
                create(tick: tick, with: width)
            }

            handle.makeBody()
                .offset(x: handleOffset)
                #if os(macOS) || os(iOS)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            dragChanged(on: value.location.x, width: width)
                        }
                        .onEnded { value in
                            dragEnded(on: value.location.x, width: width)
                        }
                )
                #endif
        }
        .onAppear {
            updateHandleOffset(width: width, animated: false)
        }
        .onChange(of: selectedItem) { _ in
            updateHandleOffset(width: width, animated: animated)
        }
        .onChange(of: width) { newValue in
            updateHandleOffset(width: newValue, animated: false)
        }
    }

    private func updateHandleOffset(width: CGFloat, animated: Bool) {
        if animated {
            withAnimation(.easeInOut(duration: 0.35)) {
                handleOffset = (width - handle.width) * CGFloat(selectedIndex) * step
            }
        } else {
            handleOffset = (width - handle.width) * CGFloat(selectedIndex) * step
        }
    }

    private func create(tick: AnySliderTick, with width: CGFloat) -> some View {
        ForEach(0 ..< options.count, id: \.self) { element in
            tick.makeBody()
                .offset(x: CGFloat(element) * step * (width - tick.width))
                .onTapGesture {
                    setSelectedItem(options[element], animated: false)
                }
                .hide(tickDisplayGuide, index: element)
        }
    }

    private func dragChanged(on location: CGFloat, width: CGFloat) {
        let lineWidth = width - handle.width

        if step != 0 {
            let percentage = max(0, min(location / lineWidth, 1))
            let page = round(percentage / step)
            let option = options[Int(page)]
            if option != preselectedItem {
                preselectedItem = option
                onItemPreselected?(option)
            }
        }

        handleOffset = max(min(lineWidth, location), 0)
    }

    private func dragEnded(on location: CGFloat, width: CGFloat) {
        if step == 0, let item = options.first {
            setSelectedItem(item, animated: animated)
            return
        }

        let lineWidth = width - handle.width

        let percentage = max(0, min(location / lineWidth, 1))
        let page = round(percentage / step)

        setSelectedItem(options[Int(page)], animated: animated)
    }

    private func setSelectedItem(_ item: Option, animated: Bool) {
        if item != selectedItem {
            selectedItem = item
        } else {
            // since the `selectedItem` is not changed,
            // so we need to manually update handle offset.
            updateHandleOffset(width: width, animated: animated)
        }
    }
}

extension View {

    @ViewBuilder fileprivate func hide(_ guide: TickDisplayGuide, index: Int) -> some View {
        switch guide {
        case .alwaysPresent:
            self
        case .ondemandPresent(let devideBy):
            hide(index % devideBy != 0)
        }
    }

    @ViewBuilder fileprivate func hide(_ isHidden: Bool) -> some View {
        if isHidden {
            hidden()
        } else {
            self
        }
    }
}
