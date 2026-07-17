//
//  CarModel.swift
//  Cars
//
//  Created by Adetunji Adeyinka on 14/07/2026.
//
import SwiftUI

struct CarModel: Decodable, Identifiable {
    var id: UUID
    var itemId: Int
    var name: String
    var brand: String
    var description: String
    var dateOfCapture: Int
    var location: String
    var imageUrl: String
    var originalImageUrl: String?
    var images: [String]

    var imageURL: URL? {
        URL(string: imageUrl)
    }
}

let sampleCar = CarModel(
    id: UUID(),
    itemId: 1,
    name: "Camry",
    brand: "Toyota",
    description: "Sleek daily driver that still turns heads downtown",
    dateOfCapture: 1721088000,
    location: "Los Angeles, CA",
    imageUrl:
        "https://cars.usnews.com/static/images/Auto/izmo/i159615463/2022_toyota_camry_angularfront.jpg",
    originalImageUrl:
        "https://cars.usnews.com/static/images/Auto/izmo/i159615463/2022_toyota_camry_angularfront.jpg",
    images: [
        "https://cars.usnews.com/static/images/Auto/izmo/i159615463/2022_toyota_camry_angularfront.jpg"
    ]
)

let sampleCars: [CarModel] = [
    sampleCar,
    CarModel(
        id: UUID(),
        itemId: 2,
        name: "Civic",
        brand: "Honda",
        description: "Nimble hatchback built for city street adventures",
        dateOfCapture: 1719792000,
        location: "San Francisco, CA",
        imageUrl:
            "https://upload.wikimedia.org/wikipedia/commons/thumb/1/1a/Honda_Civic_e-HEV_Sport_%28XI%29_%E2%80%93_f_30062024.jpg/1280px-Honda_Civic_e-HEV_Sport_%28XI%29_%E2%80%93_f_30062024.jpg",
        images: [
            "https://upload.wikimedia.org/wikipedia/commons/thumb/1/1a/Honda_Civic_e-HEV_Sport_%28XI%29_%E2%80%93_f_30062024.jpg/1280px-Honda_Civic_e-HEV_Sport_%28XI%29_%E2%80%93_f_30062024.jpg"
        ]
    ),
    CarModel(
        id: UUID(),
        itemId: 3,
        name: "Mustang",
        brand: "Ford",
        description: "American muscle with a roaring highway attitude",
        dateOfCapture: 1717200000,
        location: "Austin, TX",
        imageUrl:
            "https://www.usnews.com/object/image/0000019b-0a66-dbed-adff-0a7612800000/2026-ford-mustang-front-angle-view-ak.jpg?update-time=1765406019919&size=responsive640&format=webp",
        images: [
            "https://www.usnews.com/object/image/0000019b-0a66-dbed-adff-0a7612800000/2026-ford-mustang-front-angle-view-ak.jpg?update-time=1765406019919&size=responsive640&format=webp"
        ]
    ),
    CarModel(
        id: UUID(),
        itemId: 4,
        name: "M3",
        brand: "BMW",
        description: "Precision machine that thrives on twisty canyon roads",
        dateOfCapture: 1714608000,
        location: "Munich, Germany",
        imageUrl:
            "https://www.bmwusa.com/content/dam/bmw/marketUS/common/limited-edition/2024/soc25/m4-cs/BMW-LimitedEdition-M4-CSL-all.jpg",
        images: [
            "https://www.bmwusa.com/content/dam/bmw/marketUS/common/limited-edition/2024/soc25/m4-cs/BMW-LimitedEdition-M4-CSL-all.jpg"
        ]
    ),
]
