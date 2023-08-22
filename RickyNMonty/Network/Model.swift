//
//  Model.swift
//  RickyNMonty
//
//  Created by Gbrigens on 21/08/2023.
//

import Foundation

struct Character: Codable {
    let info: Info
    let results: [CharacterResult]
}

struct Info: Codable {
    let count, pages: Int
    let next: String?
    let prev: String?
}

struct CharacterResult: Codable, Hashable {
    let id: Int
    let name, status, species, type: String
    let gender: String
    let origin, location: Location
    let image: String
    let episode: [String]
}

struct Location: Codable, Hashable {
    let name: String
    let url: String
}

struct Episode: Codable, Identifiable {
    let id: Int
    let name: String
    let airDate: String
    let episode: String
    let characters: [String]
    let url: URL
    let created: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, episode, characters, url, created
        case airDate = "air_date"
    }
}


