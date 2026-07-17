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
    var imageUrl: String
    var originalImageUrl: String?
    var description: String

    var imageURL: URL? {
        URL(string: imageUrl)
    }
}

let sampleCar = CarModel(
    id: UUID(),
    itemId: 1,
    name: "Toyota Camry",
    imageUrl:
        "https://cars.usnews.com/static/images/Auto/izmo/i159615463/2022_toyota_camry_angularfront.jpg",
    originalImageUrl:
        "https://cars.usnews.com/static/images/Auto/izmo/i159615463/2022_toyota_camry_angularfront.jpg",
    description: "TRD 2021"

)

let sampleCars: [CarModel] = [
    sampleCar,
    CarModel(
        id: UUID(),
        itemId: 2,
        name: "Honda Civic",
        imageUrl:
            "https://upload.wikimedia.org/wikipedia/commons/thumb/1/1a/Honda_Civic_e-HEV_Sport_%28XI%29_%E2%80%93_f_30062024.jpg/1280px-Honda_Civic_e-HEV_Sport_%28XI%29_%E2%80%93_f_30062024.jpg",
        description: "Sport 2022"
    ),
    CarModel(
        id: UUID(),
        itemId: 3,
        name: "Ford Mustang",
        imageUrl:
            "https://www.usnews.com/object/image/0000019b-0a66-dbed-adff-0a7612800000/2026-ford-mustang-front-angle-view-ak.jpg?update-time=1765406019919&size=responsive640&format=webp",
        description: "GT 2023"
    ),
    CarModel(
        id: UUID(),
        itemId: 4,
        name: "BMW M3",
        imageUrl:
            "https://www.bmwusa.com/content/dam/bmw/marketUS/common/limited-edition/2024/soc25/m4-cs/BMW-LimitedEdition-M4-CSL-all.jpg",
        description: "Competition"
    ),
]
