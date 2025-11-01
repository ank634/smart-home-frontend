//
//  Errors.swift
//  smart_home_system_frontend
//
//  Created by Emmanuel Bastidas on 8/10/25.
//

enum BetterHomeError: String, Error, Codable{
    case valueNotUnique = "NOT_UNIQUE"
    //case duplicateDevice
    //case nameNotUnique
    //case roomDoesNotExist
    case emptyStringNotAllowed = "ILLEGAL_VALUE"
    case nullValueNotAllowed = "NULL_NOT_ALLOWED"
}

