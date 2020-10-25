//
//  MarksBarChartRace.swift
//  BarChart
//
//  Created by Thane Heninger on 10/25/20.
//  Copied from Mark Lucking's article: https://medium.com/better-programming/a-bar-chart-race-using-swiftui-2-0-ef84dc68b678
//

import SwiftUI
import Combine

enum sortDirection {
  case accending, decending
}

var sortColumns = PassthroughSubject<sortDirection,Never>()
var newPosition = PassthroughSubject<(String,Int),Never>()
var changeFigure = PassthroughSubject<(String,Int),Never>()

final class MarksFigures: ObservableObject {
  static var shared = MarksFigures()
  @Published var bars = [MarksBarChart]()
  init() {
    bars.append(MarksBarChart(text: "Apples",numbers: 90, position: 0, color: Color.clear))
    bars.append(MarksBarChart(text: "Bananas",numbers: 50, position: bars.count, color: Color.clear))
    bars.append(MarksBarChart(text: "Blueberry",numbers: 80, position: bars.count, color: Color.clear))
    bars.append(MarksBarChart(text: "Figs",numbers: 40, position: bars.count, color: Color.clear))
    bars.append(MarksBarChart(text: "Papaya",numbers: 30, position: bars.count, color: Color.clear))
    bars.append(MarksBarChart(text: "Pears",numbers: 10, position: bars.count, color: Color.clear))
    bars.append(MarksBarChart(text: "Pineapples",numbers: 70, position: bars.count, color: Color.clear))
    bars.append(MarksBarChart(text: "Plums",numbers: 20, position: bars.count, color: Color.clear))
  }
  
  func reOrder() {
    bars.sort { $0.numbers > $1.numbers }
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
  
  func newValue(element: String, figure: Int) {
    if let i = bars.firstIndex(where: { $0.text == element }) {
      bars[i].numbers = figure
      changeFigure.send((bars[i].text,figure))
    }
  }
  
  func doMath(element: String, figure: Int) {
    if let i = bars.firstIndex(where: { $0.text == element }) {
      bars[i].numbers = bars[i].numbers + Int.random(in: 1...figure)
      changeFigure.send((bars[i].text,bars[i].numbers))
    }
  }

}

struct MarksBarChart {
  var text: String
  var numbers: Int
  var position: Int
  var color: Color
}

let timerTimer = Timer.publish(every: 1.2, on: .main,
                               in: .common).autoconnect()

struct SwiftUIViewB: View {
  @ObservedObject var values = MarksFigures.shared
  @State var colors:[Color] = [.red,.orange,.yellow,.blue,.green,.pink,.purple]
  @State var barHeight:CGFloat = 0
  @State var jump:Double = 0
  @State var gate:String
  @State var redraw = false
  @State var feed = false
  
  let nextBar = Timer.publish(every: 0.8, on: .main,
                              in: .common).autoconnect()
  
  
  var body: some View {
    
    ZStack(alignment: .leading) {
      ForEach((0...Int(jump)), id: \.self) { value in
        drawBar(barText: values.bars[Int(value)].text, barHeight: CGFloat(values.bars[Int(value)].numbers), jump: jump)
      }
      .onReceive(sortColumns, perform: { (direction) in
        values.reOrder()
        jump = 0
        redraw.toggle()
      })
      .onReceive(nextBar, perform: { (_) in
        if Int(jump) < values.bars.count - 1 {
          jump += 1
        }
      })
      .onAppear(perform: {
        DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
          feed = true
        }
      })
      .font(Fonts.avenirNextCondensedMedium(size: 20))
    }
    .padding()
    .id(redraw)
    .frame(width: 236, height: 256, alignment: .leading)
    .border(Color.black)
    .onReceive(timerTimer, perform: { ( time ) in
      if feed {
        for reorder in 0..<values.bars.count {
          values.doMath(element: values.bars[reorder].text, figure: 10)
        }
        values.newOrder()
        for reorder in 0..<values.bars.count {
          newPosition.send((values.bars[reorder].text, values.bars[reorder].position))
        }
      }
    })
  }
}

struct drawBar:View {
  @State var barText: String
  @State var redraw = false
  @State var barHeight: CGFloat
  @State var growMore: CGFloat = 0
  @State var showMore: Double = 0
  @State var fader: Double = 1
  @State var hide: Bool = false
  @State var forever: Bool = false
  @State var jump:Double
  @State var colorSet = false
  @State var colorValue = Color.red
  @State var offset:CGFloat = 0
  @State var fresh = true
  @State var freshColor = Color.clear
  var body: some View {
    HStack {
      Text(barText)
        .frame(width: 80, alignment: Alignment.topTrailing)
        .onAppear {
          if fresh {
            offset = CGFloat(jump * 24)
            freshColor = doColor(shade: barHeight)
          }
        }
      Rectangle()
        .fill(colorSet ? colorValue: freshColor)
        .frame(width: growMore, height: 20)
      Rectangle()
        .frame(width: 110 - growMore, height: 1, alignment: .leading)
        .opacity(0)
      Text(String(Int(barHeight)))
        .font(Fonts.avenirNextCondensedMedium(size: 16))
        .frame(width: 24, alignment: Alignment.topTrailing)
        .background(Color.yellow)
        .onAppear {
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.linear(duration: 0.5)) {
              growMore = barHeight
              showMore = 1
            }
          }
        }.opacity(showMore)
        .onReceive(changeFigure) { (combinedName) in
          let (ColumnName, columnVame) = combinedName
          if barText == ColumnName {
            fader = 0
            fresh = false
            barHeight = CGFloat(columnVame)
            redraw.toggle()
            fader = 1
          }
        }
        .onReceive(newPosition) { ( combinedName ) in
          let (ColumnName, columnNo) = combinedName
          if barText == ColumnName {
            withAnimation(.linear(duration: 0.8)) {
              offset = CGFloat(Double(columnNo) * 24)
            }
          }
        }
    }.opacity(fader)
    .id(redraw)
    .offset(x: 0, y: offset)
    .offset(x: 0, y: -84)
  }
  
  func doColor(shade: CGFloat) -> Color {
    let hue2U:Double = Double((shade / 90 * 360))
    let color = Color.init(hue: hue2U/360, saturation: 0.66, brightness: 0.66, opacity: 1.0)
    return color
  }
  
}

struct MarksBarChartRace: View {
    var body: some View {
        SwiftUIViewB(gate: "")
    }
}

struct MarksBarChartRace_Previews: PreviewProvider {
    static var previews: some View {
        MarksBarChartRace()
    }
}
