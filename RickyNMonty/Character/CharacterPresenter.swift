//
//  CharacterPresenter.swift
//  RickyNMonty
//
//  Created by Gbrigens on 21/08/2023.
//
import Foundation
import UIKit

class CharacterPresenter: CharacterPresenterProtocol {
    
    weak var view: CharacterViewProtocol?
    private let api: RickAndMortyAPI
    private var imageCache = NSCache<NSURL, UIImage>()
    
    init(view: CharacterViewProtocol, api: RickAndMortyAPI) {
        self.view = view
        self.api = api
    }
    
    func fetchCharacters() {
        api.fetchAllCharacters { [weak self] (result) in
            switch result {
            case .success(let characterData):
                self?.view?.showCharacters(characterData.results)
            case .failure(let error):
                self?.view?.showError(error)
            }
        }
    }
    
    func fetchImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        if let cachedImage = imageCache.object(forKey: url as NSURL) {
            completion(cachedImage)
            return
        }
        
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                self.imageCache.setObject(image, forKey: url as NSURL)
                completion(image)
            } else {
                completion(nil)
            }
        }
    }
}


