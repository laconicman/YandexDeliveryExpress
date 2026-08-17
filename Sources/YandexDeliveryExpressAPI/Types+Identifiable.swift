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

extension Components.Schemas.RoutePointWithAddress: Identifiable {
    public var id: Int64 { value1.id }
}

extension Components.Schemas.CalculatedOffer: Identifiable {
    public var id: Int { hashValue }
}
