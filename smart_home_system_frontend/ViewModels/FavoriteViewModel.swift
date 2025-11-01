//
//  FavoriteViewModel.swift
//  smart_home_system_frontend
//
//  Created by Emmanuel Bastidas on 10/29/25.
//

import Foundation

@Observable class FavoriteViewModel{
    var screenState = ScreenState.loading
    var favorites: [IotDevice] = []
    var deviceViewModels: [DeviceDisplayViewModelStrategy] = []
    
    func GetFavorites() async throws {//-> [IotDevice]{
        guard let url = URL(string: "http://127.0.0.1:8080/favorites") else{
            screenState = .errorLoading
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse else{
            screenState = .errorLoading
            throw URLError(.badServerResponse)
        }
        
        if httpResponse.statusCode == 500{
            screenState = .errorLoading
            throw URLError(.badServerResponse)
        }
        
        let results = try JSONDecoder().decode([IotDevice].self, from: data)
        screenState = .loadedSuccefully
        favorites = results
        print(favorites)
    }
}
