//
//  BarChart.swift
//  BarChart
//
//  Created by Thane Heninger on 10/13/20.
//

import SwiftUI

struct AnimatedBar: View {
    var vertical = true
    let length: CGFloat
    let barIndex: Int
    let animationTime: TimeInterval
    @State private var interimLength = CGFloat(0)
    
    var color: Color {
        let hue2U = 360.0 / 14.0 * Double(barIndex)
        let color = Color(hue: hue2U/255, saturation: 0.66,
                          brightness: 0.66, opacity: 1.0)
        return color
    }
    
    func finalLength(inSize size: CGFloat) -> CGFloat {
        size * length / 100
    }
    
    var body: some View {
        GeometryReader { geo in
            if vertical {
                Rectangle()
                    .fill(color)
                    .offset(y: geo.size.height - interimLength)
                    .frame(height: interimLength)
                    .onAppear {
                        withAnimation {
                            interimLength = finalLength(inSize: geo.size.height)
                        }
                    }
                    .onChange(of: geo.size.height) { _ in
                        interimLength = finalLength(inSize: geo.size.height)
                    }
            } else {
                Rectangle()
                    .fill(color)
                    .frame(width: interimLength)
                    .onAppear {
                        withAnimation {
                            interimLength = finalLength(inSize: geo.size.width)
                        }
                    }
                    .onChange(of: geo.size.width) { _ in
                        interimLength = finalLength(inSize: geo.size.width)
                    }
            }
        }
    }
}

struct BarView: View {
    var vertical = true
    let length: CGFloat
    let barIndex: Int
    let animationTime: TimeInterval
    @State private var labelOpacity = 0.0
    let textSize = CGFloat(30)
    
    var body: some View {
        GeometryReader { geo in
            if vertical {
                VStack {
                    AnimatedBar(vertical: vertical, length: length,
                                barIndex: barIndex, animationTime: animationTime)
                        .frame(width: geo.size.width, height: geo.size.height - textSize)
                    Text(String(Int(length)))
                        .padding(.top, -5)
                        .frame(height: textSize)
                        .opacity(labelOpacity)
                }
            } else {
                HStack {
                    Text(String(Int(length)))
                        .frame(width: textSize)
                        .opacity(labelOpacity)
                    AnimatedBar(vertical: vertical, length: length,
                                barIndex: barIndex, animationTime: animationTime)
                        .frame(width: geo.size.width - textSize, height: geo.size.height)
                }
            }
        }
        .onAppear {
            withAnimation(.linear(duration: animationTime)) {
                labelOpacity = 1
            }
        }
    }
}

struct BarChart: View {
    @ObservedObject private var values = Figures.shared
    var vertical = true
    @State private var visibleBars = 0
    let timer = Timer.publish(every: 0.6, on: .main,
                              in: .common).autoconnect()
    let sideSpacing = CGFloat(10)
    let betweenSpacing = CGFloat(5)
    
    func barWidth(forSize size: CGFloat) -> CGFloat {
        let count = CGFloat(values.numbers.count)
        let barSpace = size - 2 * sideSpacing - (count - 1) * betweenSpacing
        return barSpace / count
    }
    
    func barPosition(forSize size: CGFloat, index: Int) -> CGFloat {
        let barWidth = self.barWidth(forSize: size)
        let barAndSpace = barWidth + betweenSpacing
        let position = sideSpacing + CGFloat(index) * barAndSpace + barWidth / 2
        return position
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Rectangle()
                    .stroke(Color.black)

                ForEach(0 ..< visibleBars, id: \.self) { index in
                    if vertical {
                        BarView(vertical: vertical,
                                length: CGFloat(values.numbers[index]),
                                barIndex: index, animationTime: 0.6)
                            .frame(width: barWidth(forSize: geo.size.width), height: geo.size.height)
                            .position(x: barPosition(forSize: geo.size.width, index: index),
                                      y: geo.size.height / 2)
                    } else {
                        BarView(vertical: vertical,
                                length: CGFloat(values.numbers[index]),
                                barIndex: index, animationTime: 0.6)
                            .frame(width: geo.size.width, height: barWidth(forSize: geo.size.height))
                            .position(x: geo.size.width / 2,
                                      y: barPosition(forSize: geo.size.height, index: index))
                    }
                }
                .font(Fonts.avenirNextCondensedMedium(size: 20))
                .onTapGesture {
                    values.randomize()
                    visibleBars = 0
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .onReceive(timer) { _ in
            if visibleBars < values.numbers.count {
                visibleBars += 1
            }
        }
    }
}

struct BarChart_Previews: PreviewProvider {
    static var previews: some View {
        BarChart()
            .previewLayout(.fixed(width: 205, height: 160))
    }
}
