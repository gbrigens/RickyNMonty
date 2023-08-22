//
//  APIClient.swift
//  RickyNMonty
//
//  Created by Gbrigens on 21/08/2023.
//
import Foundation

protocol APIClient {
    func fetch<T: Decodable>(_ endpoint: String, completion: @escaping (Result<T, Error>) -> Void)
    func fetchAllCharacters(completion: @escaping (Result<Character, Error>) -> Void)
    func fetchEpisode(withID id: Int, completion: @escaping (Result<Episode, Error>) -> Void)
    func fetchEpisodes(withIDs ids: [Int], completion: @escaping (Result<[Episode], Error>) -> Void)
}

class RickAndMortyAPI: APIClient {
    
    let client: URLSession
    let baseURL: URL
    
    init(client: URLSession) {
        self.client = client
        self.baseURL = URL(string: "https://rickandmortyapi.com/api")!
    }
    
    func fetch<T: Decodable>(_ endpoint: String, completion: @escaping (Result<T, Error>) -> Void) {
        let fullURL = baseURL.appendingPathComponent(endpoint)
        
        let task = client.dataTask(with: fullURL) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                let error = NSError(domain: "RickAndMortyAPI", code: 0, userInfo: [NSLocalizedDescriptionKey: "Received empty data from server."])
                completion(.failure(error))
                return
            }
            
            do {
                let model = try JSONDecoder().decode(T.self, from: data)
                completion(.success(model))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    func fetchAllCharacters(completion: @escaping (Result<Character, Error>) -> Void) {
        fetch("character", completion: completion)
    }
    
    func fetchEpisode(withID id: Int, completion: @escaping (Result<Episode, Error>) -> Void) {
        fetch("episode/\(id)", completion: completion)
    }
    
    func fetchEpisodes(withIDs ids: [Int], completion: @escaping (Result<[Episode], Error>) -> Void) {
        let idList = ids.map(String.init).joined(separator: ",")
        fetch("episode/\(idList)", completion: completion)
    }
}
