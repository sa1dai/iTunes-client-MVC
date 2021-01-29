//
//  DetailViewController.swift
//  iTunes Client
//
//  Created by Admin on 02.02.2021.
//

import UIKit

class DetailViewController: UIViewController {

  @IBOutlet private weak var tableView: UITableView!
  
  @IBOutlet weak var collectionNameLabel: UILabel!
  @IBOutlet weak var artistNameLabel: UILabel!
  @IBOutlet weak var artworkImage: UIImageView!
  @IBOutlet weak var collectionPriceLabel: UILabel!
  @IBOutlet weak var trackCountLabel: UILabel!
  @IBOutlet weak var releaseDateLabel: UILabel!
  @IBOutlet weak var primaryGenreNameLabel: UILabel!
  
  var collection: Collection!
  var tracks: [Track] = []
  let tracksQueryService = TracksQueryService()

  override func viewDidLoad() {
    super.viewDidLoad()

    collectionNameLabel.text = collection.collectionName
    artistNameLabel.text = collection.artistName
    collectionPriceLabel.text = collection.collectionPriceText
    trackCountLabel.text = "Songs: \(collection.trackCount)"
    releaseDateLabel.text = "Released: \(collection.releaseDateText)"
    primaryGenreNameLabel.text = collection.primaryGenreName
    let artworkUrl = URL(string: collection.artworkUrl100)
    DispatchQueue.global().async {
      guard let data = try? Data(contentsOf: artworkUrl!) else { return }
      DispatchQueue.main.async {
        self.artworkImage.image = UIImage(data: data)
      }
    }
    
    tracksQueryService.getTracks(collectionId: collection.collectionId) { tracks, errorMessage in
      UIApplication.shared.isNetworkActivityIndicatorVisible = false
      if let tracks = tracks {
        self.tracks = tracks
        self.tableView.reloadData()
      }
      if !errorMessage.isEmpty { print("Search error: " + errorMessage) }
    }
  }

}

extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    return tracks.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "TrackViewCell", for: indexPath) as! TrackViewCell
    let track = tracks[indexPath.row]
    cell.trackNameLabel.text = track.trackName
    cell.trackNumberLabel.text = String(track.trackNumber)
    cell.trackTimeLabel.text = track.trackTimeText
    cell.trackPriceLabel.text = track.trackPriceText
    return cell
  }
  
}
