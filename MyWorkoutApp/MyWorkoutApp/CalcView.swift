//
//  CalcView.swift
//  MyWorkoutApp
//
//  Created by David Santos on 4/23/25.
//


import SwiftUI

struct CalcView: View {
    @State private var selectedTool = 0
    let tools = ["RPE Calc", "Plate Calc"]

    var body: some View {
        NavigationView {
            VStack {
                Picker("Select Tool", selection: $selectedTool) {
                    ForEach(0..<tools.count) { index in
                        Text(tools[index]).tag(index)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                if selectedTool == 0 {
                    RPECalculatorView()
                } else {
                    PlateCalculatorView()
                }
            }
            .navigationTitle("Calculator")
            .background(Color.black.edgesIgnoringSafeArea(.all))
        }
        .preferredColorScheme(.dark)
    }
}
