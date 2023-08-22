//
//  Protocols.swift
//  RickyNMonty
//
//  Created by Gbrigens on 21/08/2023.
//

import Foundation
import UIKit

protocol CharacterViewProtocol: AnyObject {
    func showCharacters(_ characters: [CharacterResult])
    func showError(_ error: Error)
}

protocol CharacterPresenterProtocol {
    func fetchCharacters()
    func fetchImage(from url: URL, completion: @escaping (UIImage?) -> Void)
}

protocol CharacterDetailPresenterProtocol {
    func fetchEpisodes()
    var character: CharacterResult { get }
}

protocol CharacterDetailViewProtocol {
    func displayEpisodes(_ episodes: [Episode])
    func displayError(_ error: Error)
}

