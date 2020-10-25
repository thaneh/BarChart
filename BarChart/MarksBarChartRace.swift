//
//  MarksBarChartRace.swift
//  BarChart
//
//  Created by Thane Heninger on 10/25/20.
//  Copied from Mark Lucking's article: https://medium.com/better-programming/a-bar-chart-race-using-swiftui-2-0-ef84dc68b678
//

import SwiftUI
import Combine

let newPosition = PassthroughSubject<(String,Int),Never>()
let changeFigure = PassthroughSubject<(String,Int),Never>()

final class MarksFigures: ObservableObject {
    static var shared = MarksFigures()
    @Published var bars = [BarData]()
    
    var activityTimer: Timer?
    
    init() {
        bars.append(BarData(text: "Apples", numbers: 90, position: 0))
        bars.append(BarData(text: "Bananas", numbers: 50, position: bars.count))
        bars.append(BarData(text: "Blueberry", numbers: 80, position: bars.count))
        bars.append(BarData(text: "Figs", numbers: 40, position: bars.count))
        bars.append(BarData(text: "Papaya", numbers: 30, position: bars.count))
        bars.append(BarData(text: "Pears", numbers: 10, position: bars.count))
        bars.append(BarData(text: "Pineapples", numbers: 70, position: bars.count))
        bars.append(BarData(text: "Plums", numbers: 20, position: bars.count))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 8) { [weak self] in
            self?.activityTimer = Timer.scheduledTimer(withTimeInterval: 1.2, repeats: true) { _ in
                self?.doActivity()
            }
        }
    }
    
    func doActivity() {
        addRandomIncrements()
        sendValues()
        
        newOrder()
        sendNewPositions()
    }
    
    func sendNewPositions() {
        bars.forEach {
            newPosition.send(($0.text, $0.position))
        }
    }
    
    func sendValues() {
        bars.forEach {
            changeFigure.send(($0.text, $0.numbers))
        }
    }
    
    func newOrder() {
        var newBar = bars
        newBar.sort { $0.numbers > $1.numbers }
        for index in 0..<bars.count {
            if let i = bars.firstIndex(where: { $0.text == newBar[index].text }) {
                bars[i].position = index
                if bars[i].numbers > 100 {
                    bars[i].numbers = Int.random(in: 10...30)
                }
            }
        }
    }
    
    // Not used
    func newValue(element: String, figure: Int) {
        if let i = bars.firstIndex(where: { $0.text == element }) {
            bars[i].numbers = figure
            changeFigure.send((bars[i].text,figure))
        }
    }
    
    func addRandomIncrements() {
        bars = bars.map { $0.incremented(by: Int.random(in: 1...10)) }
    }
}

struct BarData {
    let text: String
    var numbers: Int
    var position: Int
    var color = Color.clear
    
    init(text: String, numbers: Int, position: Int) {
        self.text = text
        self.numbers = numbers
        self.position = position
    }
    
    func incremented(by amount: Int) -> BarData {
        var element = BarData(text: text, numbers: numbers + amount,
                              position: position)
        element.color = color
        return element
    }
}

struct SwiftUIViewB: View {
    @ObservedObject var values = MarksFigures.shared
    let colors: [Color] = [.red,.orange,.yellow,.blue,.green,.pink,.purple]
    @State private var visibleBars = 1
    
    let nextBar = Timer.publish(every: 0.8, on: .main,
                                in: .common).autoconnect()
    
    var body: some View {
        
        ZStack(alignment: .leading) {
            ForEach(0...visibleBars - 1, id: \.self) { value in
                BarRow(barText: values.bars[value].text,
                       barHeight: CGFloat(values.bars[value].numbers),
                       position: value)
            }
            .onReceive(nextBar) { _ in
                visibleBars += 1
                if visibleBars == values.bars.count {
                    nextBar.upstream.connect().cancel()
                }
            }
            .font(Fonts.avenirNextCondensedMedium(size: 20))
        }
        .padding()
        .frame(width: 236, height: 256, alignment: .leading)
        .border(Color.black)
    }
}

struct BarRow: View {
    let barWidth = 24
    let barText: String
    @State private var redraw = false
    @State var barHeight: CGFloat
    @State private var growMore = CGFloat(0)
    @State private var showMore = 0.0
    @State private var fader = Double(1)
    let position: Int
    @State private var offset = CGFloat(0)
    @State private var fresh = true
    @State private var freshColor = Color.clear
    
    var body: some View {
        HStack {
            Text(barText)
                .frame(width: 80, alignment: .topTrailing)
                .onAppear {
                    if fresh {
                        offset = CGFloat(position * barWidth)
                        freshColor = doColor(shade: barHeight)
                    }
                }
            Rectangle()
                .fill(freshColor)
                .frame(width: growMore, height: 20)
            Rectangle()
                .frame(width: 110 - growMore, height: 1)
                .opacity(0)
            Text(String(Int(barHeight)))
                .font(Fonts.avenirNextCondensedMedium(size: 16))
                .frame(width: 24, alignment: .topTrailing)
                .background(Color.yellow)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.linear(duration: 0.5)) {
                            growMore = barHeight
                            showMore = 1
                        }
                    }
                }.opacity(showMore)
                .onReceive(changeFigure) { name, value in
                    guard barText == name else { return }
                    fresh = false
                    barHeight = CGFloat(value)
                    redraw.toggle()
                }
                .onReceive(newPosition) { name, position in
                    guard barText == name else { return }
                    withAnimation(.linear(duration: 0.8)) {
                        offset = CGFloat(position * barWidth)
                    }
                }
        }.opacity(fader)
        .id(redraw)
        .offset(y: offset - 84)
    }
    
    func doColor(shade: CGFloat) -> Color {
        let hue2U:Double = Double((shade / 90 * 360))
        let color = Color.init(hue: hue2U/360, saturation: 0.66, brightness: 0.66, opacity: 1.0)
        return color
    }
}

struct MarksBarChartRace: View {
    var body: some View {
        SwiftUIViewB()
    }
}

struct MarksBarChartRace_Previews: PreviewProvider {
    static var previews: some View {
        MarksBarChartRace()
            .previewLayout(.sizeThatFits)
    }
}
