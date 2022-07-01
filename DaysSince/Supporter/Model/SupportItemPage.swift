//
//  SupportItemPage.swift
//  Supporter
//
//  Created by Jordi Bruin on 01/12/2021.
//

import Foundation

/// The model for the individual pages you can link to from a header of highlighted support item
struct SupportItemPage: Identifiable, Codable {
    let id: Int
    let title: String
    let subtitle: String
    let videoURL: String?
    let darkVideoURL: String?
    let imageURL: String?
    let darkImageURL: String?
    
    init(
        id: Int,
        title: String,
        subtitle: String,
        videoURL: String? = nil,
        darkVideoURL: String? = nil,
        imageURL: String? = nil,
        darkImageURL: String? = nil
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.videoURL = videoURL
        self.darkVideoURL = darkVideoURL
        self.imageURL = imageURL
        self.darkImageURL = darkImageURL
    }
}
