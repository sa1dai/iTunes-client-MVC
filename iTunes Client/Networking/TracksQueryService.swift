//
//  TracksQueryService.swift
//  iTunes Client
//
//  Created by Admin on 03.02.2021.
//

import Foundation

class TracksQueryService {

  typealias QueryResult = ([Track]?, String) -> ()
  var tracks: [Track] = []
  var errorMessage = ""

  lazy var defaultSession: URLSession = {
    let config = URLSessionConfiguration.default
    config.waitsForConnectivity = true
    return URLSession(configuration: config)
  }()
  var dataTask: URLSessionDataTask?
  let decoder = JSONDecoder()

  func getTracks(collectionId: Int, completion: @escaping QueryResult) {
    dataTask?.cancel()

    guard var urlComponents = URLComponents(string: "https://itunes.apple.com/lookup")
      else { return }
    urlComponents.query = "id=\(collectionId)&entity=song"
    guard let url = urlComponents.url else { return }

    dataTask = defaultSession.dataTask(with: url) { data, response, error in
      defer { self.dataTask = nil }
      if let error = error {
        self.errorMessage += "DataTask error: " + error.localizedDescription + "\n"
      } else if let data = data,
        let response = response as? HTTPURLResponse,
        response.statusCode == 200 {
        self.updateResult(data)
        OperationQueue.main.addOperation {
          completion(self.tracks, self.errorMessage)
        }
      }
    }
    dataTask?.resume()
  }

  // MARK: - Helper methods
  fileprivate func updateResult(_ data: Data) {
    tracks.removeAll()
    do {
      let trackListResults = try decoder.decode(TrackListResults.self, from: data)
      tracks = trackListResults.results.tracks
    } catch let decodeError as NSError {
      errorMessage += "Decoder error: \(decodeError.localizedDescription)"
      return
    }
  }

}
