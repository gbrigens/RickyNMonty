//
//  CharacterDetailViewController.swift
//  RickyNMonty
//
//  Created by Gbrigens on 21/08/2023.
//
import SwiftUI

struct CharacterDetailView: View, CharacterDetailViewProtocol {
    var character: CharacterResult
    @ObservedObject var viewModel: CharacterViewModel
    var presenter: CharacterDetailPresenterProtocol
    
    @State private var showAlert = false
    @State private var errorMessage = ""
    
    init(character: CharacterResult, viewModel: CharacterViewModel, presenter: CharacterDetailPresenterProtocol) {
        self.character = character
        self.viewModel = viewModel
        self.presenter = presenter
        (self.presenter as? CharacterDetailPresenter)?.view = self
    }
    
    var body: some View {
        ZStack {
            Color.appbg
                .ignoresSafeArea()
            ScrollView {
                header
                info
                origin
                episode
            }
            .scrollIndicators(.hidden)
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Error"),
                message: Text(errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private var header: some View {
        VStack(spacing: Constants.spacing) {
            AsyncImage(url: URL(string: presenter.character.image)) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: Constants.imageSize, height: Constants.imageSize)
                    .cornerRadius(Constants.cornerRadius)
            } placeholder: {
                ProgressView()
            }
            
            VStack(spacing: Constants.spacingSmall) {
                Text(presenter.character.name)
                    .font(.title)
                    .fontWeight(.bold)
                Text(presenter.character.status)
                    .foregroundStyle(.green)
                    .font(.title2)
            }
        }
    }
    
    private func infoCell(label: String, content: String) -> some View {
        HStack {
            Text(label)
                .font(.headline)
            Spacer()
            Text(content)
                .font(.headline)
                .fontWeight(.medium)
        }
    }
    
    private var info: some View {
        section(title: "Info") {
            VStack(spacing: Constants.spacingSmall) {
                infoCell(label: "Species:", content: presenter.character.species)
                infoCell(label: "Type:", content: presenter.character.type)
                infoCell(label: "Gender:", content: presenter.character.gender)
            }
        }
    }
    
    private var origin: some View {
        section(title: "Origin") {
            HStack {
                Image("Planet")
                    .resizable()
                    .frame(width: Constants.iconSize, height: Constants.iconSize)
                    .padding(Constants.iconPadding)
                    .background(.iconbg)
                    .cornerRadius(Constants.iconCornerRadius)
                
                VStack(alignment: .leading, spacing: Constants.spacingSmall) {
                    Text(presenter.character.origin.name)
                        .font(.headline)
                        .fontWeight(.bold)
                    Text(presenter.character.location.name)
                        .foregroundStyle(.green)
                }
                Spacer()
            }
            .padding([.top, .leading, .bottom], Constants.spacingSmall)
        }
    }
    
    private var episode: some View {
        section(title: "Episode") {
            ForEach(viewModel.episodes) { episode in
                EpisodeCell(episode: episode)
            }
        }
        .onAppear {
            presenter.fetchEpisodes()
        }
    }
    
    private func section<Content: View>(title: String, content: @escaping () -> Content) -> some View {
        VStack {
            Text(title)
                .fontWeight(.bold)
                .font(.title)
                .frame(maxWidth: .infinity, alignment: .leading)
            content()
                .padding(Constants.contentPadding)
                .background(.cellbg)
                .cornerRadius(Constants.cornerRadius)
        }
    }
    
    func displayEpisodes(_ episodes: [Episode]) {
        viewModel.episodes = episodes
    }
    
    func displayError(_ error: Error) {
        errorMessage = error.localizedDescription
        showAlert = true
    }
}

struct EpisodeCell: View {
    var episode: Episode
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.spacing) {
            Text(episode.name)
                .fontWeight(.bold)
                .font(.headline)
            HStack(spacing: Constants.spacingSmall) {
                Text(episode.episode)
                    .font(.subheadline)
                    .foregroundStyle(.green)
                Spacer()
                Text(episode.airDate)
                    .font(.subheadline)
                    .foregroundStyle(.gray)
            }
        }
        .padding(Constants.contentPadding)
        .background(.cellbg)
        .cornerRadius(Constants.cornerRadius)
    }
}
