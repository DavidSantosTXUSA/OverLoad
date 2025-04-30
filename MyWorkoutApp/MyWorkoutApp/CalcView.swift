//
//  CalcView.swift
//  MyWorkoutApp
//
//  Created by David Santos on 4/23/25.
//


import SwiftUI

struct CalcView: View {
    @State private var selectedTool = 0
    let tools = ["Plate Calc","RPE Calc"]

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
                    PlateCalculatorView()
                } else {
                    RPECalculatorView()
                }
            }
            .navigationTitle("Calculator")
            .background(Color.black.edgesIgnoringSafeArea(.all))
        }
        .preferredColorScheme(.dark)
    }
}
