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
    
    var body: some View {
        VStack {
            BarChart()
                .frame(width: width, height: height)
            
            Button("Random Size") {
                width = CGFloat.random(in: 150...400)
                height = CGFloat.random(in: 180...250)
            }
            .padding()
            
            Slider(value: $height, in: 100...350) {
                Text("Size \(height)")
            }
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
