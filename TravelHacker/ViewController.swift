//
//  ViewController.swift
//  TravelHacker
//
//  Created by Emin Israfil on 2/24/24.
//

import UIKit
import MapKit
import Eureka
//import LocationRow

struct SearchModel {
    var query: String?
    var sources: Set<String>?
    var location: CLLocation?
    
    init(query: String? = nil, sources: Set<String>? = nil, location: CLLocation? = nil) {
        self.query = query
        self.sources = sources
        self.location = location
    }
}


struct SearchResult: Decodable {
    let imageURL: String
    let description: String
    let latitude: Double
    let longitude: Double
    
    // Custom keys to match the JSON response structure
    private enum CodingKeys: String, CodingKey {
        case imageURL = "imageURL"
        case description = "description"
        case latitude = "lat"
        case longitude = "long"
    }
    
    // Computed property to easily get a CLLocation from the latitude and longitude
    var location: CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
}

class ViewController: FormViewController, TinderViewControllerDelegate {

    var selectedSources: Set<String> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        form
        +++ Section("What are you looking for? 👀")
            <<< TextRow("Query"){ row in
                row.title = "query"
                row.placeholder = "tacos, polish food, cat cafe"
            }

        // Create a section for Sources with CheckRows
        let sourcesSection = Section("Search these sites 🔎")
        form +++ sourcesSection
        
        // Add a CheckRow for each source
        ["Reddit", "Yelp", "Google"].forEach { source in
            sourcesSection <<< CheckRow() { row in
                row.title = source
                row.value = false // Default to unchecked
            }.onChange { [weak self] row in
                guard let self = self, let value = row.value, let title = row.title else { return }
                
                // Update the selectedSources set based on the CheckRow's value
                if value {
                    self.selectedSources.insert(title)
                } else {
                    self.selectedSources.remove(title)
                }
                
                print("Selected sources: \(self.selectedSources)")
            }
        }
        
//        form
//        +++ Section("Location")
//            <<< LocationRow("Location"){
//                $0.title = "Select Location"
//                $0.value = CLLocation(latitude: -34.911242, longitude: -56.164532)
//                
//            }

        form
        +++ Section()
            <<< ButtonRow() { row in
                row.title = "Search 🚀"
                row.onCellSelection { [weak self] (cell, row) in
                    self?.performSearch()
                }
            }
    }
    
    func updateModel() -> SearchModel {
        let formValues = self.form.values()
        
        let searchModel = SearchModel(
            query: formValues["Query"] as? String,
            sources: selectedSources,
            location: formValues["Location"] as? CLLocation
        )
        
        return searchModel
    }
    
    func performSearch() {
        
        let searchResults = generateDummySearchResults()
        
        // Initialize TinderViewController with dummy data
        let tinderVC = TinderViewController(models: searchResults)
        
        // Set the delegate
        tinderVC.delegate = self
        
        // Present TinderViewController
        DispatchQueue.main.async {
            //self.navigationController?.pushViewController(tinderVC, animated: true)
            self.present(tinderVC, animated: true)
        }
        
        return;

        let searchModel = updateModel()
    

        if let request = createSearchRequest(from: searchModel) {
            // Execute the URLRequest with URLSession or any networking library you prefer
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    print("Invalid response or data")
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let searchResults = try decoder.decode([SearchResult].self, from: data)
                    
                    let tinderVC = TinderViewController(models: searchResults)
                    
                    // Set the delegate
                    tinderVC.delegate = self
                    
                    // Present TinderViewController
                    self.navigationController?.pushViewController(tinderVC, animated: true)
                } catch {
                    print("Error decoding JSON: \(error)")
                }
                
                // Handle the response data
                // For example, decode JSON and update UI accordingly
            }.resume()
        } else {
            print("Failed to create request")
        }
    }
    
    func createSearchRequest(from model: SearchModel) -> URLRequest? {
        var components = URLComponents(string: "https://yourapi.com/search")
        
        var queryItems = [URLQueryItem]()
        
        // Add query text if available
        if let query = model.query {
            queryItems.append(URLQueryItem(name: "query", value: query))
        }
        
        // Add sources as a comma-separated list if available
        if let sources = model.sources, !sources.isEmpty {
            let sourcesList = sources.joined(separator: ",")
            queryItems.append(URLQueryItem(name: "sources", value: sourcesList))
        }
        
        // Add location as latitude and longitude if available
        if let location = model.location {
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            queryItems.append(URLQueryItem(name: "latitude", value: latitude))
            queryItems.append(URLQueryItem(name: "longitude", value: longitude))
        }
        
        components?.queryItems = queryItems
        
        guard let url = components?.url else {
            print("Invalid URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        // Add any necessary headers here
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Here you might configure additional request headers, such as an API key
        // request.addValue("YourAPIKey", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    func generateDummySearchResults() -> [SearchResult] {
        let dummyData = [
            SearchResult(imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/c/cc/Burger_King_2020.svg/1920px-Burger_King_2020.svg.png", description: "A beautiful sunrise at the beach", latitude: 35.1762, longitude: 139.6103),
            SearchResult(imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/c/cc/Burger_King_2020.svg/1920px-Burger_King_2020.svg.png", description: "The Eiffel Tower on a cloudy day", latitude: 35.8762, longitude: 139.6533),
            SearchResult(imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/c/cc/Burger_King_2020.svg/1920px-Burger_King_2020.svg.png", description: "Cherry blossoms in full bloom", latitude: 35.6762, longitude: 139.6503)
        ]
        return dummyData
    }
    
    var selectedItems: [SearchResult] = []
}

extension  ViewController {
    func didUpdatePhotoStoryValidationState(photoStory: SearchResult, validationState: Bool) {
        updateSelectedItem(photoStory, isSelected: validationState)
    }
    
    func didUpdateImageValidation(photoStory: SearchResult, imageValidation: Bool) {
        updateSelectedItem(photoStory, isSelected: imageValidation)
    }
    
    // This method checks whether the photoStory should be added to or removed from the selectedItems array
    private func updateSelectedItem(_ photoStory: SearchResult, isSelected: Bool) {
        if isSelected {
            selectedItems.append(photoStory)
        } else {

        }
    }
    
    func didTapOnPhotoStory(photoStory: SearchResult) {
        
    }
    
    func tinderViewControllerDidFinish(_ vc: TinderViewController) {
        vc.dismiss(animated: true) {
            self.showResultsOnMap(self.selectedItems)
        }
    }
    
    func showResultsOnMap(_ results: [SearchResult]) {
        let mapViewController = TravelMapViewController()
        mapViewController.searchResults = results
        let navigationController = UINavigationController(rootViewController: mapViewController)
        present(navigationController, animated: true, completion: nil)
    }
}

