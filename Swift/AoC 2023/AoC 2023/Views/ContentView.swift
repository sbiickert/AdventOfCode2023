//
//  ContentView.swift
//  AoC 2023
//
//  Created by Simon Biickert on 2023-04-26.
//

import SwiftUI

struct ContentView: View {
	@State private var columnVisibility = NavigationSplitViewVisibility.all

    var body: some View {
		NavigationSplitView(columnVisibility: $columnVisibility) {
			SolutionList()
		} content: {
			EmptyView()
		} detail: {
			EmptyView()
		}
		.navigationSplitViewStyle(.balanced)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
