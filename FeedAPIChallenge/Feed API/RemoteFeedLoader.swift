//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
  private let url: URL
  private let client: HTTPClient
  
  public enum Error: Swift.Error {
    case connectivity
    case invalidData
  }
  
  public init(url: URL, client: HTTPClient) {
    self.url = url
    self.client = client
  }
  
  public func load(completion: @escaping (FeedLoader.Result) -> Void) {
    client.get(from: self.url) { [weak self] (result) in
      guard let self = self else { return }
      switch result {
      case .failure(_):
        completion(.failure(Error.connectivity))
      case .success((let data, let response)):
        if response.statusCode != 200 {
          completion(.failure(Error.invalidData))
          return
        }
        do {
          let jsonObj = try JSONSerialization.jsonObject(with: data, options: [])
          if let rootJSONDict = jsonObj as? [String:Any] {
            if let dicts = rootJSONDict["items"] as? [[String:Any]] {
              let images = dicts.compactMap({ self.imageForDict($0) })
              completion(.success(images))
              return
            }
          }
          completion(.success([]))
        } catch {
          completion(.failure(Error.invalidData))
        }
      }
    }
  }
  
  
  private func imageForDict(_ dict: [String: Any]) -> FeedImage? {
    guard let uuid = self.uuidForDict(dict) else {
        return nil
    }
    guard let url = self.imageURLforDict(dict) else {
        return nil
    }
    let description = dict["image_desc"] as? String
    let location = dict["image_loc"] as? String
    return FeedImage(id: uuid,
                     description: description,
                     location: location,
                     url: url)
  }
  
  private func uuidForDict(_ dict: [String: Any]) -> UUID? {
    guard let id = dict["image_id"] as? String,
      let uuid = UUID(uuidString: id) else {
        return nil
    }
    return uuid
  }
  
  private func imageURLforDict(_ dict: [String: Any]) -> URL? {
    guard let imageURL = dict["image_url"] as? String,
      let url = URL(string: imageURL) else {
        return nil
    }
    return url
  }
}
