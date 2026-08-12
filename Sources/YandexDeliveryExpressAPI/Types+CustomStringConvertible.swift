//
//  Types+CustomStringConvertible.swift
//  YandexDeliveryExpressAPI
//
//  Created by Paul Buktab on 7/22/25.
//

import Foundation
import OpenAPIRuntime

// MARK: - Shared renderings

/// Every documented error response in this API carries the same `{code, message}` body
/// behind a throwing `body.json`, so one helper serves every error case of every operation.
private func message(of response: Components.Schemas.ErrorResponse?) -> String {
    response?.message ?? String(localized: "Unknown error", bundle: #bundle, comment: "Error description")
}

/// An `.undocumented` response means `openapi.yaml` is wrong — see the `SpecOwnership`
/// article — so show the status and the payload rather than a generic failure.
private func undocumentedDescription(statusCode: Int, payload: UndocumentedPayload) -> String {
    String(
        localized: "Undocumented response: status code \(statusCode).\nPayload: \(String(describing: payload))",
        bundle: #bundle,
        comment: "Error description"
    )
}

/// A 2xx whose body was not the JSON the document promised.
private var undecodedJSON: String {
    String(localized: "Undecoded JSON", bundle: #bundle, comment: "Error description")
}

// MARK: - Operations.CalculateOffers.Output + CustomStringConvertible

extension Operations.CalculateOffers.Output: CustomStringConvertible {
    public var description: String {
        switch self {
        case .ok(let response): (try? response.body.json)?.prettyJSON ?? undecodedJSON
        case .badRequest(let error): message(of: try? error.body.json)
        case .unauthorized(let error): message(of: try? error.body.json)
        case .conflict(let error): message(of: try? error.body.json)
        case .tooManyRequests(let error): message(of: try? error.body.json)
        case .internalServerError(let error): message(of: try? error.body.json)
        case .undocumented(let statusCode, let payload): undocumentedDescription(statusCode: statusCode, payload: payload)
        }
    }
}

// MARK: - Operations.CreateClaim.Output + CustomStringConvertible

extension Operations.CreateClaim.Output: CustomStringConvertible {
    public var description: String {
        switch self {
        case .ok(let response): (try? response.body.json)?.prettyJSON ?? undecodedJSON
        case .badRequest(let error): message(of: try? error.body.json)
        case .unauthorized(let error): message(of: try? error.body.json)
        case .tooManyRequests(let error): message(of: try? error.body.json)
        case .internalServerError(let error): message(of: try? error.body.json)
        case .undocumented(let statusCode, let payload): undocumentedDescription(statusCode: statusCode, payload: payload)
        }
    }
}

// MARK: - Operations.GetClaimInfo.Output + CustomStringConvertible

extension Operations.GetClaimInfo.Output: CustomStringConvertible {
    public var description: String {
        switch self {
        case .ok(let response): (try? response.body.json)?.prettyJSON ?? undecodedJSON
        case .badRequest(let error): message(of: try? error.body.json)
        case .unauthorized(let error): message(of: try? error.body.json)
        case .notFound(let error): message(of: try? error.body.json)
        case .tooManyRequests(let error): message(of: try? error.body.json)
        case .internalServerError(let error): message(of: try? error.body.json)
        case .undocumented(let statusCode, let payload): undocumentedDescription(statusCode: statusCode, payload: payload)
        }
    }
}

// MARK: - Operations.AcceptClaim.Output + CustomStringConvertible

extension Operations.AcceptClaim.Output: CustomStringConvertible {
    public var description: String {
        switch self {
        case .ok(let response): (try? response.body.json)?.prettyJSON ?? undecodedJSON
        case .badRequest(let error): message(of: try? error.body.json)
        case .unauthorized(let error): message(of: try? error.body.json)
        case .conflict(let error): message(of: try? error.body.json)
        case .tooManyRequests(let error): message(of: try? error.body.json)
        case .internalServerError(let error): message(of: try? error.body.json)
        case .undocumented(let statusCode, let payload): undocumentedDescription(statusCode: statusCode, payload: payload)
        }
    }
}

// MARK: - Operations.GetClaimCancelInfo.Output + CustomStringConvertible

extension Operations.GetClaimCancelInfo.Output: CustomStringConvertible {
    public var description: String {
        switch self {
        case .ok(let response): (try? response.body.json)?.prettyJSON ?? undecodedJSON
        case .badRequest(let error): message(of: try? error.body.json)
        case .unauthorized(let error): message(of: try? error.body.json)
        case .notFound(let error): message(of: try? error.body.json)
        case .conflict(let error): message(of: try? error.body.json)
        case .tooManyRequests(let error): message(of: try? error.body.json)
        case .internalServerError(let error): message(of: try? error.body.json)
        case .undocumented(let statusCode, let payload): undocumentedDescription(statusCode: statusCode, payload: payload)
        }
    }
}

// MARK: - Operations.CancelClaim.Output + CustomStringConvertible

extension Operations.CancelClaim.Output: CustomStringConvertible {
    public var description: String {
        switch self {
        case .ok(let response): (try? response.body.json)?.prettyJSON ?? undecodedJSON
        case .badRequest(let error): message(of: try? error.body.json)
        case .unauthorized(let error): message(of: try? error.body.json)
        case .conflict(let error): message(of: try? error.body.json)
        case .tooManyRequests(let error): message(of: try? error.body.json)
        case .internalServerError(let error): message(of: try? error.body.json)
        case .undocumented(let statusCode, let payload): undocumentedDescription(statusCode: statusCode, payload: payload)
        }
    }
}

// MARK: - Components.Parameters.AcceptLanguage + CustomStringConvertible

extension Components.Parameters.AcceptLanguage: CustomStringConvertible {
    public var description: String {
        switch self {
        case .ru: String(localized: "Russian", bundle: #bundle, comment: "Components.Parameters.AcceptLanguage")
        case .en: String(localized: "English", bundle: #bundle, comment: "Components.Parameters.AcceptLanguage")
        }
    }
}

// MARK: - Components.Schemas.Currency + CustomStringConvertible

extension Components.Schemas.Currency: CustomStringConvertible {
    public var description: String {
        rawValue
    }
}

// MARK: - Components.Schemas.TaxiClass + CustomStringConvertible

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

// MARK: - Components.Schemas.CargoType + CustomStringConvertible

extension Components.Schemas.CargoType: CustomStringConvertible {
    public var description: String {
        rawValue
    }
}

// MARK: - Components.Schemas.CargoOption + CustomStringConvertible

extension Components.Schemas.CargoOption: CustomStringConvertible {
    public var description: String {
        rawValue
    }
}

// MARK: - Components.Schemas.PointType + CustomStringConvertible

extension Components.Schemas.PointType: CustomStringConvertible {
    public var description: String {
        rawValue
    }
}

// MARK: - Components.Schemas.CancelState + CustomStringConvertible

extension Components.Schemas.CancelState: CustomStringConvertible {
    public var description: String {
        switch self {
        case .free: String(localized: "Free", bundle: #bundle, comment: "Components.Schemas.CancelState")
        case .paid: String(localized: "Paid", bundle: #bundle, comment: "Components.Schemas.CancelState")
        }
    }
}

// MARK: - Components.Schemas.CancelInfoCancelState + CustomStringConvertible

/// The three-case sibling — the one `getClaimCancelInfo` actually returns, and therefore the
/// one a caller displays. `CancelState` is the request-side enum you echo back, and it has no
/// `.unavailable`; the document is explicit that the two must not be confused.
extension Components.Schemas.CancelInfoCancelState: CustomStringConvertible {
    public var description: String {
        // Its own keys, with `defaultValue` carrying the English. Sharing `"Free"` / `"Paid"`
        // with `CancelState` would have read as tidy and quietly welded the two enums
        // together: a String Catalog stores one comment per key, so the two `comment:`
        // strings would conflict, and neither wording could ever diverge from the other —
        // in the one place this package insists they are different things.
        switch self {
        case .free:
            String(localized: "cancelInfo.free", defaultValue: "Free", bundle: #bundle, comment: "Components.Schemas.CancelInfoCancelState")
        case .paid:
            String(localized: "cancelInfo.paid", defaultValue: "Paid", bundle: #bundle, comment: "Components.Schemas.CancelInfoCancelState")
        case .unavailable:
            String(localized: "cancelInfo.unavailable", defaultValue: "Unavailable", bundle: #bundle, comment: "Components.Schemas.CancelInfoCancelState")
        }
    }
}
