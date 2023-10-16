//
//  ContentView.swift
//  RecipeApp
//
//  Created by Oncu Can on 16.10.2023.
//

import SwiftUI

enum SortDirection {
    case asc
    case desc
}

struct ContentView: View {
    
    @State private var search: String = ""
    @State private var filteredRecipes: [Recipe] = []
    @StateObject private var networkModel = NetworkModel()
    @State private var sortDirection: SortDirection = .asc
    
    private func performSearch(keyword: String) {
        filteredRecipes = networkModel.recipes.filter { recipe in recipe.title.contains(keyword)}}
    
    private var recipes: [Recipe] {
        filteredRecipes.isEmpty ? networkModel.recipes: filteredRecipes
    }
    
    var sortDirectiontext: String {
        sortDirection == .asc ? "Sort Descending": "Sort Ascending"
    }
    
    private func performSort(sortDirection: SortDirection) {
        
        var sortedRecipes = recipes
        
        switch sortDirection {
        case .asc:
            sortedRecipes.sort { lhs, rhs in
                lhs.title < rhs.title
            }
        case .desc:
            sortedRecipes.sort { lhs, rhs in
                lhs.title > rhs.title
            }
        }
        if filteredRecipes.isEmpty {
            networkModel.recipes = sortedRecipes
        } else {
            filteredRecipes = sortedRecipes
        }
        
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Button(sortDirectiontext) {
                    sortDirection = sortDirection == .asc ? .desc: .asc
                }
                List(recipes) { recipe in
                    HStack {
                        AsyncImage(url: recipe.featuredImage) { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: 100, maxHeight: 100)
                        } placeholder: {
                            Text("Loading...")
                        }
                        Text(recipe.title)
                    }
                    
                } 
                .searchable(text: $search)
                .onChange(of: search, perform: performSearch)
                .onChange(of: sortDirection, perform: performSort)
                .task {
                    do {
                        try await networkModel.fetchRecipes()
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ContentView()
    }
}
