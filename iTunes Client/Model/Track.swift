//
//  Track.swift
//  iTunes Client
//
//  Created by Admin on 03.02.2021.
//

import Foundation.NSURL

struct Track: Decodable {
  let trackName: String
  let trackPrice: Float
  let trackNumber: Int
  let currency: String
  let trackTimeMillis: Int
  
  var trackPriceText: String {
    return "\(trackPrice) \(currency)"
  }
  
  var trackTimeText: String {
    let milliseconds: Int = trackTimeMillis
    let minutes: Int = milliseconds / (60 * 1000)
    let remaningSeconds = (milliseconds - minutes * 60 * 1000) / 1000
    let remaningSecondsText = String(format:"%02d", remaningSeconds)
    return "\(minutes):\(remaningSecondsText)"
  }
}

struct TrackListResults: Decodable {
  let results: TrackList
}

struct TrackList: Decodable {
  let tracks: [Track]
}

extension TrackList {
  init(from decoder: Decoder) throws {
    var container = try decoder.unkeyedContainer()
    
    // The first one is a Collection, skip
    _ = try container.decode(Collection.self)

    // The rest are Track
    var tracks = [Track]()

    while !container.isAtEnd {
        let track = try container.decode(Track.self)
        tracks.append(track)
    }

    self.tracks = tracks
  }
}
