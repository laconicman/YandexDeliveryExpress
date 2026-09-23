//
//  Types+Identifiable.swift
//  YandexDeliveryExpressAPI
//
//  Created by Paul Buktab on 7/25/25.
//

extension Components.Parameters.AcceptLanguage: Identifiable {
    public var id: Self { self }
}

extension Components.Schemas.Currency: Identifiable {
    public var id: Self { self }
}

extension Components.Schemas.TaxiClass: Identifiable {
    public var id: Self { self }
}

extension Components.Schemas.CargoType: Identifiable {
    public var id: Self { self }
}

extension Components.Schemas.CargoOption: Identifiable {
    public var id: Self { self }
}

extension Components.Schemas.CancelState: Identifiable {
    public var id: Self { self }
}

extension Components.Schemas.RoutePointBase: Identifiable {
    public var id: Int64 { pointId }
}

extension Components.Schemas.PointType: Identifiable {
    public var id: Self { self }
}

// The flat schema (TD-5 discharge) declares `id` itself, so the conformance is empty.
extension Components.Schemas.RoutePointWithAddress: Identifiable {}

extension Components.Schemas.CalculatedOffer: Identifiable {
    public var id: Int { hashValue }
}

// The app's claims list enumerates search results and journal events in SwiftUI.
extension Components.Schemas.ClaimResponse: Identifiable {}

extension Components.Schemas.JournalEvent: Identifiable {
    /// `operation_id` is the event's position in the journal — unique and monotonic.
    public var id: Int64 { operationId }
}
