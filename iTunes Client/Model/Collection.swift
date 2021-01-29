//
//  Collection.swift
//  iTunes Client
//
//  Created by Admin on 01.02.2021.
//

import Foundation.NSURL

struct Collection: Decodable {
  let collectionId: Int
  let artistName: String
  let collectionName: String
  let collectionPrice: Float
  let collectionExplicitness: String
  let currency: String
  let artworkUrl60: String
  let artworkUrl100: String
  let trackCount: Int
  let releaseDate: String
  let primaryGenreName: String
  
  var collectionPriceText: String {
    return "\(collectionPrice) \(currency)"
  }
  
  var releaseDateText: String {
    let isoDateFormatter = ISO8601DateFormatter()
    let date = isoDateFormatter.date(from: releaseDate)!
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .none
    dateFormatter.locale = Locale.current
    // for example, return "Jan 30, 2014"
    return dateFormatter.string(from: date)
  }
}

struct CollectionListResults: Decodable {
  let results: [Collection]
}
