//
//  Types+CustomStringConvertable.swift
//  YandexDeliveryExpressAPI
//
//  Created by Paul Buktab on 7/22/25.
//
// TODO: Implement using `JSONEncoder.prettyPrinted`.
@available(iOS 15, tvOS 15, watchOS 8, macOS 12, *)
extension Operations.CalculateOffers.Output: CustomStringConvertible {
    public var description: String {
        switch self {
        case .unauthorized(let error): (try? error.body.json.message) ?? String(localized: "Unknown error", comment: "Error description")
        case .badRequest(let error): (try? error.body.json.message) ?? String(localized: "Unknown error", comment: "Error description")
        case .internalServerError(let error): (try? error.body.json.message) ?? String(localized: "Unknown error", comment: "Error description")
        case .tooManyRequests(let error): (try? error.body.json.message) ?? String(localized: "Unknown error", comment: "Error description")
        case .ok(let body): (try? body.body.json.offers.description) ?? String(localized: "Undecoded JSON", comment: "Error description")
        case .undocumented(statusCode: let statusCode, let payload):  String(localized: "Undocumented response: status code \(statusCode).\nPayload: payload", comment: "Error description")
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

@available(iOS 15, tvOS 15, watchOS 8, macOS 12, *)
extension Components.Parameters.AcceptLanguage: CustomStringConvertible {
    public var description: String {
        switch self {
        case .ru: String(localized: "Russian", comment: "Components.Parameters.AcceptLanguage")
        case .en: String(localized: "English", comment: "Components.Parameters.AcceptLanguage")
        }
    }
}

@available(iOS 15, tvOS 15, watchOS 8, macOS 12, *)
extension Components.Schemas.Currency: CustomStringConvertible {
    public var description: String {
        rawValue
    }
}

@available(iOS 15, tvOS 15, watchOS 8, macOS 12, *)
extension Components.Schemas.TaxiClass: CustomStringConvertible {
    public var description: String {
        switch self {
        case .cargo:   String(localized: "cargo",   comment: "Components.Schemas.TaxiClass")
        case .courier: String(localized: "courier", comment: "Components.Schemas.TaxiClass")
        case .express: String(localized: "express", comment: "Components.Schemas.TaxiClass")
        case .sddLong: String(localized: "sddLong", comment: "Components.Schemas.TaxiClass")
        }
    }
}

@available(iOS 15, tvOS 15, watchOS 8, macOS 12, *)
extension Components.Schemas.CargoType: CustomStringConvertible {
    public var description: String {
        rawValue
    }
}

@available(iOS 15, tvOS 15, watchOS 8, macOS 12, *)
extension Components.Schemas.CargoOption: CustomStringConvertible {
    public var description: String {
        rawValue
    }
}

@available(iOS 15, tvOS 15, watchOS 8, macOS 12, *)
extension Components.Schemas.PointType: CustomStringConvertible {
    public var description: String {
        rawValue
    }
}

@available(iOS 15, tvOS 15, watchOS 8, macOS 12, *)
extension Components.Schemas.CancelState: CustomStringConvertible {
    public var description: String {
        switch self {
        case .free: String(localized: "Free", comment: "Components.Schemas.CancelState")
        case .paid: String(localized: "Paid", comment: "Components.Schemas.CancelState")
        }
    }
}
