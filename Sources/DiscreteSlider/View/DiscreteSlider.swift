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
    @Binding private var selectedItem: Option

    private let options: [Option]
    private let track: AnySliderTrack
    private let tick: AnySliderTick?
    private let handle: AnySliderHandle
    private let label: AnySliderLabel<Option>?
    private let tickDisplayGuide: TickDisplayGuide
    private let animated: Bool
    private var onItemPreselected: ((Option) -> Void)?

    private var sliderHeight: CGFloat {
        max(handle.height, track.height, tick?.height ?? 0)
    }

    /// Creates discrete slider with given track, tick, handle and label.
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
        animated: Bool = true,
        selectedItem: Binding<Option>,
        onItemPreselected: ((Option) -> Void)? = nil
    ) where Label.Option == Option {
        self.track = .init(track: track)
        self.tick = .init(tick: tick)
        self.handle = .init(handle: handle)
        self.label = AnySliderLabel<Option>(label: label)
        self.tickDisplayGuide = tickDisplayGuide
        self.animated = animated
        self.options = options
        self._selectedItem = selectedItem
        self.onItemPreselected = onItemPreselected
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
        self.label = nil
        self.options = options
        self.tickDisplayGuide = tickDisplayGuide
        self.animated = animated
        self._selectedItem = selectedItem
        self.onItemPreselected = onItemPreselected
    }

    public var body: some View {
        VStack(alignment: .center, spacing: 4) {
            contol
            labels
        }
    }

    @ViewBuilder private var contol: some View {
        GeometryReader { geometry in
            SliderControl(
                options: options,
                track: track,
                tick: tick,
                handle: handle,
                tickDisplayGuide: tickDisplayGuide,
                animated: animated,
                selectedItem: $selectedItem,
                onItemPreselected: onItemPreselected
            )
            .environment(\.width, geometry.size.width)
        }
        .frame(height: sliderHeight)
    }

    @ViewBuilder private var labels: some View {
        if let label {
            GeometryReader { proxy in
                SliderLabels(options: options, label: label, edgeSpacing: (tick?.width ?? 0) / 2)
                    .environment(\.width, proxy.size.width)
            }
        }
    }
}
