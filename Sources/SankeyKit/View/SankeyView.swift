//
//  SankeyView.swift
//  SankeyKit
//
//  Created by Christoph Pageler on 25.02.25.
//

import SwiftUI


#if canImport(UIKit)

import UIKit

public struct SankeyView: UIViewRepresentable {
    public typealias UIViewType = UISankeyView

    public var sankey: Sankey
    public var settings: SankeySettings

    public func makeUIView(context: Context) -> UIViewType {
        let view = UISankeyView(
            sankey: sankey,
            settings: settings
        )
        return view
    }

    public func updateUIView(_ uiView: UIViewType, context: Context) {
        uiView.sankey = sankey
        uiView.settings = settings
    }
}

#endif

#if canImport(AppKit)

public struct SankeyView: NSViewRepresentable {
    public typealias NSViewType = NSSankeyView

    public var sankey: Sankey
    public var settings: SankeySettings

    public func makeNSView(context: Context) -> NSSankeyView {
        let view = NSSankeyView(
            sankey: sankey,
            settings: settings
        )
        return view
    }

    public func updateNSView(_ nsView: NSSankeyView, context: Context) {
        nsView.sankey = sankey
        nsView.settings = settings
    }
}

#endif

// MARK: - Preview

private struct PreviewSlider: View {
    @Binding var value: Double
    var range: ClosedRange<Double>
    var step: Double
    var title: String

    var body: some View {
        LabeledContent {
            Slider(value: $value, in: range, step: step)
        } label: {
            VStack(alignment: .leading) {
                Text(title)
                Text("\(value)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 100, alignment: .leading)
        }
    }
}

private enum PreviewSankey: CaseIterable, Identifiable {
    case startSimple
    case financialResults
    case jobSearch
    case journey
    case rankedElection
    case budget

    var id: String { title }

    var title: String {
        switch self {
        case .startSimple:
            return "Start Simple"
        case .financialResults:
            return "Financial Results"
        case .jobSearch:
            return "Job Search"
        case .journey:
            return "Journey"
        case .rankedElection:
            return "Ranked Election"
        case .budget:
            return "Budget"
        }
    }

    var sankey: Sankey {
        switch self {
        case .startSimple:
            return SankeyMaticString.Example.startSimple
        case .financialResults:
            return SankeyMaticString.Example.financialResults
        case .jobSearch:
            return SankeyMaticString.Example.jobSearch
        case .journey:
            return SankeyMaticString.Example.journey
        case .rankedElection:
            return SankeyMaticString.Example.rankedElection
        case .budget:
            return SankeyMaticString.Example.budget
        }
    }
}

#Preview {
    @Previewable @State var sankey: PreviewSankey = .startSimple
    @Previewable @State var axis: SankeyAxis = .horizontal
    @Previewable @State var aspectRatio: Double = 2
    @Previewable @State var insets: Double = 10
    @Previewable @State var nodeThickness: Double = 30
    @Previewable @State var nodeScale: Double = 1
    @Previewable @State var nodeSpacing: Double = 0
    @Previewable @State var flowOpacity: Double = 0.45
    @Previewable @State var flowCurviness: Double = 0.5

    Form {
        Section {
            SankeyView(
                sankey: sankey.sankey,
                settings: .init(
                    axis: axis,
                    insets: .init(top: insets, leading: insets, bottom: insets, trailing: insets),
                    nodeThickness: nodeThickness,
                    nodeScale: nodeScale,
                    nodeSpacing: nodeSpacing,
                    nodeColors: SankeyMaticTheme.categories,
                    flowOpacity: flowOpacity,
                    flowCurviness: flowCurviness
                )
            )
            .aspectRatio(aspectRatio, contentMode: .fit)
            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listStyle(.plain)
            #if os(macOS)
            .frame(minHeight: 300)
            #endif
        }
        Section {
            Picker("Sankey", selection: $sankey) {
                ForEach(PreviewSankey.allCases) { previewSankey in
                    Text(previewSankey.title).tag(previewSankey)
                }
            }
            Picker("Axis", selection: $axis) {
                Text("Horizontal").tag(SankeyAxis.horizontal)
                Text("Vertical").tag(SankeyAxis.vertical)
            }
            PreviewSlider(value: $aspectRatio, range: 1...2, step: 0.001, title: "Aspect Ratio")
            PreviewSlider(value: $insets, range: 0...50, step: 1, title: "Insets")
            PreviewSlider(value: $nodeThickness, range: 0...50, step: 1, title: "Node Thickness")
            PreviewSlider(value: $nodeScale, range: 0...1, step: 0.01, title: "Node Scale")
            PreviewSlider(value: $nodeSpacing, range: 0...1, step: 0.01, title: "Node Spacing")
            PreviewSlider(value: $flowOpacity, range: 0...1, step: 0.01, title: "Flow Opacity")
            PreviewSlider(value: $flowCurviness, range: 0...1, step: 0.01, title: "Flow Curviness")
        }
    }
    #if os(macOS)
    .frame(maxWidth: 500)
    .padding()
    #endif
}
