//
//  ViewController.swift
//  iTunes Client
//
//  Created by Admin on 29.01.2021.
//

import UIKit

class SearchViewController: UIViewController {

  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet private weak var collectionView: UICollectionView!
  
  var searchResults: [Collection] = []
  let searchQueryService = SearchQueryService()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let width = view.frame.size.width
    let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
    layout.itemSize = CGSize(width: width, height: 60)
  }
  
  override func viewWillAppear(_ animated: Bool){
    super.viewWillAppear(animated)
   
    self.navigationController?.isNavigationBarHidden = true
  }
  
  override func viewWillDisappear(_ animated: Bool){
    super.viewWillDisappear(animated)
    
    self.navigationController?.isNavigationBarHidden = false
  }

}

extension SearchViewController: UISearchBarDelegate {
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    dismissKeyboard()
    if !searchBar.text!.isEmpty {
      UIApplication.shared.isNetworkActivityIndicatorVisible = true
      searchQueryService.getSearchResults(searchTerm: searchBar.text!) { results, errorMessage in
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        if let results = results {
          self.searchResults = results.sorted { $0.collectionName.lowercased() < $1.collectionName.lowercased() }
          self.collectionView.reloadData()
        }
        if !errorMessage.isEmpty { print("Search error: " + errorMessage) }
      }
    }
  }
  
  @objc func dismissKeyboard() {
    searchBar.resignFirstResponder()
  }
  
}

extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
    return searchResults.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
    let collection = searchResults[indexPath.row]
    cell.artistNameLabel.text = collection.artistName
    cell.collectionNameLabel.text = collection.collectionName
    cell.collectionPriceLabel.text = collection.collectionPriceText
    let artworkUrl = URL(string: collection.artworkUrl60)
    DispatchQueue.global().async {
      guard let data = try? Data(contentsOf: artworkUrl!) else { return }
      DispatchQueue.main.async {
        cell.artworkImage.image = UIImage(data: data)
      }
    }
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
    performSegue(withIdentifier: "DetailSegue", sender: indexPath)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
  
    if segue.identifier == "DetailSegue" {
      if let dest = segue.destination as? DetailViewController, let index = sender as? IndexPath {
        dest.collection = searchResults[index.row]
      }
    }
  
  }
}
