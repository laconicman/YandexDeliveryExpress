//
//  Types+CustomStringConvertible.swift
//  YandexDeliveryExpressAPI
//
//  Created by Paul Buktab on 7/22/25.
//

import Foundation

// TODO: Implement using `JSONEncoder.prettyPrinted`.
extension Operations.CalculateOffers.Output: CustomStringConvertible {
    public var description: String {
        switch self {
        case .unauthorized(let error): (try? error.body.json.message) ?? String(localized: "Unknown error", bundle: #bundle, comment: "Error description")
        case .badRequest(let error): (try? error.body.json.message) ?? String(localized: "Unknown error", bundle: #bundle, comment: "Error description")
        case .internalServerError(let error): (try? error.body.json.message) ?? String(localized: "Unknown error", bundle: #bundle, comment: "Error description")
        case .tooManyRequests(let error): (try? error.body.json.message) ?? String(localized: "Unknown error", bundle: #bundle, comment: "Error description")
        case .ok(let body): (try? body.body.json.offers.description) ?? String(localized: "Undecoded JSON", bundle: #bundle, comment: "Error description")
        case .undocumented(statusCode: let statusCode, let payload):  String(localized: "Undocumented response: status code \(statusCode).\nPayload: \(String(describing: payload))", bundle: #bundle, comment: "Error description")
        }
    }
}

extension Operations.CreateClaim.Output: CustomStringConvertible {
    public var description: String {
        return "\(self)"
    }
}

extension Operations.GetClaimInfo.Output: CustomStringConvertible {
    public var description: String {
        return "\(self)"
    }
}

extension Operations.AcceptClaim.Output: CustomStringConvertible {
    public var description: String {
        return "\(self)"
    }
}

extension Operations.CancelClaim.Output: CustomStringConvertible {
    public var description: String {
        return "\(self)"
    }
}

extension Components.Parameters.AcceptLanguage: CustomStringConvertible {
    public var description: String {
        switch self {
        case .ru: String(localized: "Russian", bundle: #bundle, comment: "Components.Parameters.AcceptLanguage")
        case .en: String(localized: "English", bundle: #bundle, comment: "Components.Parameters.AcceptLanguage")
        }
    }
}

extension Components.Schemas.Currency: CustomStringConvertible {
    public var description: String {
        rawValue
    }
}

extension Components.Schemas.TaxiClass: CustomStringConvertible {
    public var description: String {
        switch self {
        case .cargo:   String(localized: "cargo",   bundle: #bundle, comment: "Components.Schemas.TaxiClass")
        case .courier: String(localized: "courier", bundle: #bundle, comment: "Components.Schemas.TaxiClass")
        case .express: String(localized: "express", bundle: #bundle, comment: "Components.Schemas.TaxiClass")
        case .sddLong: String(localized: "sddLong", bundle: #bundle, comment: "Components.Schemas.TaxiClass")
        }
    }
}

extension Components.Schemas.CargoType: CustomStringConvertible {
    public var description: String {
        rawValue
    }
}

extension Components.Schemas.CargoOption: CustomStringConvertible {
    public var description: String {
        rawValue
    }
}

extension Components.Schemas.PointType: CustomStringConvertible {
    public var description: String {
        rawValue
    }
}

extension Components.Schemas.CancelState: CustomStringConvertible {
    public var description: String {
        switch self {
        case .free: String(localized: "Free", bundle: #bundle, comment: "Components.Schemas.CancelState")
        case .paid: String(localized: "Paid", bundle: #bundle, comment: "Components.Schemas.CancelState")
        }
    }
}
