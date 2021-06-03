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
      guard let _ = self else { return }
      switch result {
      case .failure(_):
        completion(.failure(Error.connectivity))
      case .success((let data, let response)):
        guard response.statusCode == 200 else {
          completion(.failure(Error.invalidData))
          return
        }
        guard let images = FeedImageMapper().imagesForData(data) else {
          completion(.failure(Error.invalidData))
          return
        }
        completion(.success(images))
      }
    }
  }
}
