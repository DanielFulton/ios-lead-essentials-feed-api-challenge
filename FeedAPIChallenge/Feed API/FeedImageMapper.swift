//
//  FeedImageMapper.swift
//  FeedAPIChallenge
//
//  Created by FultonDaniel on 2021/06/04.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

struct FeedImageMapper {
  let rootDictionaryKey = "items"
  let imageDescriptionKey = "image_desc"
  let imageLocationKey = "image_loc"
  let imageIdKey = "image_id"
  let imageUrlKey = "image_url"
  
  func imagesForData(_ data: Data) -> [FeedImage]? {
    do {
      let jsonObj = try JSONSerialization.jsonObject(with: data, options: [])
      var images: [FeedImage] = []
      if let rootJSONDict = self.dictForJsonObject(jsonObj),
        let dicts = rootJSONDict[rootDictionaryKey] as? [[String:Any]] {
        images = dicts.compactMap({ self.imageForDict($0) })
      }
      return images
    } catch {
      return nil
    }
  }
  
  fileprivate func dictForJsonObject(_ object: Any) -> [String: Any]? {
    return object as? [String: Any]
  }
  
  private func imageForDict(_ dict: [String: Any]) -> FeedImage? {
    guard let uuid = self.uuidForDict(dict) else {
      return nil
    }
    guard let url = self.imageURLforDict(dict) else {
      return nil
    }
    let description = dict[imageDescriptionKey] as? String
    let location = dict[imageLocationKey] as? String
    return FeedImage(id: uuid,
                     description: description,
                     location: location,
                     url: url)
  }
  
  private func uuidForDict(_ dict: [String: Any]) -> UUID? {
    guard let id = dict[imageIdKey] as? String,
      let uuid = UUID(uuidString: id) else {
        return nil
    }
    return uuid
  }
  
  private func imageURLforDict(_ dict: [String: Any]) -> URL? {
    guard let imageURL = dict[imageUrlKey] as? String,
      let url = URL(string: imageURL) else {
        return nil
    }
    return url
  }
}
