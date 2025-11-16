import SwiftUI

struct CalcView: View {
    @StateObject private var viewModel = CalcViewModel()
    @State private var selectedTool = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Compact segmented control for Plate/RPE
                Picker("Select Tool", selection: $selectedTool) {
                    Text("Plate Calc").tag(0)
                    Text("RPE Calc").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 12)
                
                // Content based on selection
                if selectedTool == 0 {
                    PlateCalcSection(viewModel: viewModel)
                } else {
                    RPECalcSection(viewModel: viewModel)
                }
            }
            .navigationTitle("Calculator")
            .navigationBarTitleDisplayMode(.inline) // Compact title
            .font(.system(size: 20, weight: .bold, design: .rounded))
            .background(Color.black.edgesIgnoringSafeArea(.all))
        }
        .preferredColorScheme(.dark)
    }
}
