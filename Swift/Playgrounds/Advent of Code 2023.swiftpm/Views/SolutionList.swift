import SwiftUI

struct SolutionList: View {
    @State var selectedSolution: AoCSolution?
    var body: some View {
        List(AoCSolution.solutions, id: \.day) { solution in
            NavigationLink {
                InputList(selectedSolution: solution)
            } label: {
                SolutionRow(solution: solution)
            }
        }
        .navigationTitle("Solutions")
    }
}

struct SolutionList_Previews: PreviewProvider {
    static var previews: some View {
        SolutionList()
    }
}
