//
//  CharacterViewController.swift
//  RickyNMonty
//
//  Created by Gbrigens on 21/08/2023.
//

import UIKit
import SwiftUI

class CharacterCell: UICollectionViewCell {
    static let identifier = "CharacterCell"
    
    let characterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = Constants.cornerRadius
        return imageView
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .cellbg
        contentView.layer.cornerRadius = Constants.cornerRadius
        
        contentView.addSubview(characterImageView)
        contentView.addSubview(nameLabel)
        
        characterImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            characterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.spacingSmall),
            characterImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.spacingSmall),
            characterImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.spacingSmall),
            
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            nameLabel.topAnchor.constraint(equalTo: characterImageView.bottomAnchor, constant: Constants.spacing),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.spacing),
            
            nameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        characterImageView.image = nil
    }
}

class CharacterViewController: UIViewController, CharacterViewProtocol {
    
    private var characters: [CharacterResult] = []
    var collectionView: UICollectionView!
    var presenter: CharacterPresenterProtocol!
    var activityIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .appbg
        setupCollectionView()
        
        setupActivityIndicator()
        activityIndicator.startAnimating()
        
        presenter = CharacterPresenter(view: self, api: RickAndMortyAPI(client: URLSession.shared))
        presenter.fetchCharacters()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = "Characters"
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        layout.sectionInset = UIEdgeInsets(top: 0, left: Constants.spacing, bottom: 0, right: Constants.spacing)
        layout.minimumLineSpacing = Constants.spacing
        layout.minimumInteritemSpacing = Constants.spacing
        
        let availableWidth = view.frame.size.width - (2 * Constants.spacing) - Constants.spacing
        layout.itemSize = CGSize(width: availableWidth / 2, height: Constants.imageSize)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .appbg
        collectionView.register(CharacterCell.self, forCellWithReuseIdentifier: CharacterCell.identifier)
        
        view.addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    
    func setupActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .gray
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    
    func showCharacters(_ characters: [CharacterResult]) {
        DispatchQueue.main.async {
            self.characters = characters
            self.collectionView.reloadData()
            
            self.activityIndicator.stopAnimating()
        }
    }
    
    func showError(_ error: Error) {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
}

extension CharacterViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return characters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CharacterCell.identifier, for: indexPath) as! CharacterCell
        let character = characters[indexPath.item]
        
        cell.nameLabel.text = character.name
        
        cell.characterImageView.image = nil

        if let url = URL(string: character.image) {
            presenter.fetchImage(from: url) { [weak cell] image in
                DispatchQueue.main.async {
                    cell?.characterImageView.image = image
                }
            }
        }

        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCharacter = characters[indexPath.item]
        let viewModel = CharacterViewModel()
        let api = RickAndMortyAPI(client: URLSession.shared)
        
        let presenter = CharacterDetailPresenter(api: api, character: selectedCharacter)
        
        let detailView = CharacterDetailView(character: selectedCharacter, viewModel: viewModel, presenter: presenter)
        
        presenter.view = detailView
        
        let detailVC = UIHostingController(rootView: detailView)
        
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    
}
