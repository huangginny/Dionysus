//
//  Filter.swift
//  Dionysus
//
//  Created by Ginny Huang on 1/17/22.
//  Copyright © 2022 Ginny Huang. All rights reserved.
//

import Foundation

enum Category {
    case anything
    case breakfast
    case lunch
    case dinner
    case cafe
    case dessert
    case nightlife
}

struct Filter {
    let category : Category?
}
