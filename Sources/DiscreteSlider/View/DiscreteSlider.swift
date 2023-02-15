//
//  MIT License
//
//  Copyright (c) 2021 Tamerlan Satualdypov
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

public enum TickDisplayGuide: Codable, Equatable, Sendable {
    case alwaysPresent
    case ondemandPresent(devideBy: Int = 2)
}

public struct DiscreteSlider<Option: Equatable>: View {

    @State private var handleOffset: CGFloat = 0
    @State private var size: CGSize = .zero
    @Binding private var selectedItem: Option
    private var selectedIndex: Int {
        options.firstIndex(of: selectedItem) ?? 0
    }

    private let track: AnySliderTrack
    private let tick: AnySliderTick?
    private let handle: AnySliderHandle
    private let label: AnySliderLabel<Option>?
    private let tickDisplayGuide: TickDisplayGuide

    private let options: [Option]

    private var step: CGFloat = 0

    private var sliderHeight: CGFloat {
        max(handle.height, track.height, tick?.height ?? 0)
    }

    /// Creates discrete slider with given track, tick and handle.
    ///
    /// - Note: Use the initializer to fully customize your discrete slider.
    ///
    /// - Parameters:
    ///   - options: Options that is used as a data source for the slider.
    ///   - track: Customized slider's track.
    ///   - tick: Customized slider's tick.
    ///   - handle: Customized slider's handle.
    ///   - label: Customized slider's label.
    ///   - selectedItem: Binding to the property that will store the selected item.
    public init<Track: SliderTrack, Tick: SliderTick, Handle: SliderHandle, Label: SliderLabel>(
        options: [Option],
        track: Track,
        tick: Tick,
        handle: Handle,
        label: Label,
        tickDisplayGuide: TickDisplayGuide = .alwaysPresent,
        selectedItem: Binding<Option>
    ) where Label.Option == Option {
        self.track = .init(track: track)
        self.tick = .init(tick: tick)
        self.handle = .init(handle: handle)
        self.label = AnySliderLabel<Option>(label: label)
        self.tickDisplayGuide = tickDisplayGuide
        self.options = options
        self._selectedItem = selectedItem

        if options.count > 1 {
            self.step = 1.0 / CGFloat(options.count - 1)
        }
    }

    /// Creates discrete slider with given track and handle.
    ///
    /// - Note: Use the initializer if you want only to have a track and handle in your discrete slider.
    /// - Parameters:
    ///   - options: Options that is used as a data source for the slider.
    ///   - track: Customized slider's track.
    ///   - handle: Customized slider's handle.
    ///   - selectedItem: Binding to the property that will store the selected item.
    public init<Track: SliderTrack, Tick: SliderTick, Handle: SliderHandle>(
        options: [Option],
        track: Track = DefaultSliderTrack(),
        tick: Tick = DefaultSliderTick(),
        handle: Handle = DefaultSliderHandle(),
        tickDisplayGuide: TickDisplayGuide = .alwaysPresent,
        selectedItem: Binding<Option>
    ) {
        self.track  = .init(track: track)
        self.handle = .init(handle: handle)
        self.tick = .init(tick: tick)
        self.label = nil
        self.options = options
        self.tickDisplayGuide = tickDisplayGuide
        self._selectedItem = selectedItem

        if options.count > 1 {
            self.step = 1.0 / CGFloat(options.count - 1)
        }
    }

    /// Creates discrete slider with default configuration.
    ///
    /// - Note: Use this initializer if you want to use default style of the discrete slider.
    /// - Parameters:
    ///   - options: Options that is used as a data source for the slider.
    ///   - selectedItem: Binding to the property that will store the selected item.
    public init(options: [Option], selectedItem: Binding<Option>) {
        self.init(
            options: options,
            track: DefaultSliderTrack(),
            tick: DefaultSliderTick(),
            handle: DefaultSliderHandle(),
            label: DefaultSliderLabel<Option>(),
            tickDisplayGuide: .alwaysPresent,
            selectedItem: selectedItem
        )
    }

    public var body: some View {
        VStack(alignment: .center, spacing: 4) {
            makeSlider()
            makeLabel()
        }
        .onChange(of: size) { newValue in
            handleOffset = (newValue.width - handle.width) * CGFloat(selectedIndex) * step
        }
    }

    private func makeSlider() -> some View {
        GeometryReader { geometry in
            size = geometry.size
            return ZStack(alignment: .init(horizontal: .leading, vertical: .center)) {
                track.makeTrack()
                    .frame(width: geometry.size.width)

                track.makeFillTrack()
                    .frame(width: handleOffset + handle.width / 2)

                if let tick, step != 0 {
                    create(tick: tick, with: geometry.size.width)
                }

                handle.makeBody()
                    .offset(x: handleOffset)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                dragChanged(on: value.location.x, width: geometry.size.width)
                            }
                            .onEnded { value in
                                dragEnded(on: value.location.x, width: geometry.size.width)
                            }
                    )

            }
            .onAppear {
                handleOffset = (geometry.size.width - handle.width) * CGFloat(selectedIndex) * step
            }
        }
        .frame(height: sliderHeight)
    }

    @ViewBuilder
    private func makeLabel() -> some View {
        if let label, options.count > 2 {
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

    private func create(tick: AnySliderTick, with width: CGFloat) -> some View {
        ForEach(0 ..< options.count, id: \.self) { element in
            tick.makeBody()
                .offset(x: CGFloat(element) * step * (width - tick.width))
                .onTapGesture {
                    let lineWidth = width - handle.width
                    selectedItem = options[element]
                    withAnimation(.easeInOut(duration: 0.35)) { handleOffset = lineWidth * CGFloat(element) * step }
                }
                .hide(tickDisplayGuide, index: element)
        }
    }

    private func dragChanged(on location: CGFloat, width: CGFloat, updatesSelection: Bool = false) {
        let lineWidth = width - handle.width
        handleOffset = max(min(lineWidth, location), 0)

        if step != 0, updatesSelection {
            let percentage = max(0, min(location / lineWidth, 1))
            let page = round(percentage / step)
            selectedItem = options[Int(page)]
        }
    }

    private func dragEnded(on location: CGFloat, width: CGFloat) {
        if step == 0, let item = options.first {
            selectedItem = item

            return withAnimation(.easeInOut(duration: 0.35)) {
                handleOffset = 0
            }
        }

        let lineWidth = width - handle.width

        let percentage = max(0, min(location / lineWidth, 1))
        let page = round(percentage / step)

        selectedItem = options[Int(page)]

        withAnimation(.easeInOut(duration: 0.35)) { handleOffset = lineWidth * page * self.step }
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
