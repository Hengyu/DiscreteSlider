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

public struct DiscreteSlider<Option>: View {

    @State private var handleOffset: CGFloat = 0.0

    @Binding private var selectedItem: Option
    @State private var selectedIndex: Int = 0

    private let track: AnySliderTrack
    private let tick: AnySliderTick?
    private let handle: AnySliderHandle
    private let label: AnySliderLabel<Option>?

    private let options: [Option]

    private var step: CGFloat = 0.0

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
        selectedItem: Binding<Option>
    ) where Label.Option == Option {
        self.track = .init(track: track)
        self.tick = .init(tick: tick)
        self.handle = .init(handle: handle)
        self.label = AnySliderLabel<Option>(label: label)
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
    public init<Track: SliderTrack, Handle: SliderHandle>(
        options: [Option],
        track: Track,
        handle: Handle,
        selectedItem: Binding<Option>
    ) {
        self.track  = .init(track: track)
        self.handle = .init(handle: handle)
        self.tick = nil
        self.label = nil
        self.options = options
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
            selectedItem: selectedItem
        )
    }

    public var body: some View {
        VStack(alignment: .center, spacing: 4) {
            GeometryReader { geometry in
                ZStack(alignment: .init(horizontal: .leading, vertical: .center)) {
                    track.makeTrack()
                        .frame(width: geometry.size.width)

                    track.makeFillTrack()
                        .frame(width: handleOffset + handle.width / 2)

                    if let tick, step != 0.0 {
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
                .onChange(of: geometry.size.width) { newValue in
                    handleOffset = (newValue - handle.width) * CGFloat(selectedIndex) * step
                }
            }
            .frame(height: sliderHeight)

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
    }

    private func create(tick: AnySliderTick, with width: CGFloat) -> some View {
        ForEach(0 ..< options.count, id: \.self) { element in
            tick.makeBody()
                .offset(x: CGFloat(element) * step * (width - tick.width))
                .onTapGesture {
                    let lineWidth = width - handle.width
                    selectedItem = options[element]
                    selectedIndex = element
                    withAnimation(.easeInOut(duration: 0.35)) { handleOffset = lineWidth * CGFloat(element) * step }
                }
        }
    }

    private func dragChanged(on location: CGFloat, width: CGFloat) {
        let lineWidth = width - handle.width
        let percentage = max(0, min(location / lineWidth, 1.0))

        if step != 0.0 {
            let page = round(percentage / step)
            selectedItem = options[Int(page)]
            selectedIndex = Int(page)
        }

        handleOffset = lineWidth * percentage
    }

    private func dragEnded(on location: CGFloat, width: CGFloat) {
        if step == 0.0, let item = options.first {
            selectedItem = item
            selectedIndex = 0

            return withAnimation(.easeInOut(duration: 0.35)) {
                handleOffset = 0.0
            }
        }

        let lineWidth = width - handle.width

        let percentage = max(0, min(location / lineWidth, 1.0))
        let page = round(percentage / step)

        selectedItem = options[Int(page)]
        selectedIndex = Int(page)

        withAnimation(.easeInOut(duration: 0.35)) { handleOffset = lineWidth * page * self.step }
    }
}
