//
//  QueryService.swift
//  iTunes Client
//
//  Created by Admin on 01.02.2021.
//

import Foundation

class SearchQueryService {

  typealias QueryResult = ([Collection]?, String) -> ()
  var collections: [Collection] = []
  var errorMessage = ""

  lazy var defaultSession: URLSession = {
    let config = URLSessionConfiguration.default
    config.waitsForConnectivity = true
    return URLSession(configuration: config)
  }()
  var dataTask: URLSessionDataTask?
  let decoder = JSONDecoder()

  func getSearchResults(searchTerm: String, completion: @escaping QueryResult) {
    dataTask?.cancel()

    guard var urlComponents = URLComponents(string: "https://itunes.apple.com/search")
      else { return }
    urlComponents.query = "media=music&entity=album&term=\(searchTerm)"
    guard let url = urlComponents.url else { return }

    dataTask = defaultSession.dataTask(with: url) { data, response, error in
      defer { self.dataTask = nil }
      if let error = error {
        self.errorMessage += "DataTask error: " + error.localizedDescription + "\n"
      } else if let data = data,
        let response = response as? HTTPURLResponse,
        response.statusCode == 200 {
        self.updateResults(data)
        OperationQueue.main.addOperation {
          completion(self.collections, self.errorMessage)
        }
      }
    }
    dataTask?.resume()
  }

  // MARK: - Helper methods
  fileprivate func updateResults(_ data: Data) {
    collections.removeAll()
    do {
      let collectionListResults = try decoder.decode(CollectionListResults.self, from: data)
      collections = collectionListResults.results
    } catch let decodeError as NSError {
      errorMessage += "Decoder error: \(decodeError.localizedDescription)"
      return
    }
  }

}
