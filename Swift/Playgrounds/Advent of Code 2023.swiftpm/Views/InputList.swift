import SwiftUI

struct InputList: View {
    var selectedSolution: AoCSolution
    var body: some View {
        List(AoCInput.inputsFor(solution: selectedSolution), id: \.id) { input in
            InputRow(input: input)
        }
        .navigationTitle("Inputs")
    }
}

struct InputList_Previews: PreviewProvider {
    static var previews: some View {
        InputList(selectedSolution: AoCSolution.solutions[0])
    }
}
