//
//  CharacterDetailPresenter.swift
//  RickyNMonty
//
//  Created by Gbrigens on 21/08/2023.
//

import SwiftUI
import Combine

class CharacterViewModel: ObservableObject {
    @Published var episodes: [Episode] = []
    @Published var error: Error? = nil
}

class CharacterDetailPresenter: CharacterDetailPresenterProtocol {
    
    var view: CharacterDetailViewProtocol?
    let api: RickAndMortyAPI
    let character: CharacterResult
    
    init(view: CharacterDetailViewProtocol? = nil, api: RickAndMortyAPI, character: CharacterResult) {
        self.view = view
        self.api = api
        self.character = character
    }
    
    func fetchEpisodes() {
        let ids = extractEpisodeIds(from: character.episode)
        
        // Use the batch fetching mechanism
        api.fetchEpisodes(withIDs: ids) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let episodes):
                    // Since the episodes might not be in the order of the IDs, sort them
                    let sortedEpisodes = episodes.sorted { $0.id < $1.id }
                    self?.view?.displayEpisodes(sortedEpisodes)
                case .failure(let error):
                    self?.view?.displayError(error)
                }
            }
        }
    }
    
    private func extractEpisodeIds(from urls: [String]) -> [Int] {
        return urls.compactMap { url in
            guard let lastComponent = URL(string: url)?.lastPathComponent else { return nil }
            return Int(lastComponent)
        }
    }
    
}
