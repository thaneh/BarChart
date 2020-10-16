//
//  ContentView.swift
//  BarChart
//
//  Created by Thane Heninger on 10/13/20.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var values = Figures.shared
    @State private var width = CGFloat(205)
    @State private var height = CGFloat(160)
    @State private var vertical = true
    
    var body: some View {
        VStack {
            BarChart(vertical: vertical)
                .frame(width: width, height: height)
            
            Button("Random Size") {
                width = CGFloat.random(in: 150...400)
                height = CGFloat.random(in: 180...250)
            }
            .padding()
            
            Toggle("Vertical", isOn: $vertical)
                .padding()
            
            VStack {
                Text("width")
                    .padding(.bottom, -10)
                Slider(value: $width, in: 100...400)
            }
            
            VStack {
                Text("height")
                    .padding(.bottom, -10)
                Slider(value: $height, in: 100...350)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
