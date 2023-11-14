//
//  SolutionRow.swift
//  AoC 2023
//
//  Created by Simon Biickert on 2023-04-27.
//

import SwiftUI

struct SolutionRow: View {
	var solution: AoCSolution
	var body: some View {
		HStack {
			Text(String(solution.day))
			Text(solution.name)
			Spacer()
		}
	}
}

struct SolutionRow_Previews: PreviewProvider {
	static var previews: some View {
		Group {
			SolutionRow(solution: AoCSolution.solutions[0])
			//SolutionRow(solution: AoCSolution.solutions[1])
		}
		.previewLayout(.fixed(width: 300, height: 70))
	}
}
