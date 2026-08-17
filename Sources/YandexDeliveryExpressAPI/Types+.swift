//
//  Types+.swift
//  YandexDeliveryExpressAPI
//
//  Created by Paul Buktab on 8/11/25.
//

import Foundation

public extension [Components.Schemas.RoutePointBase] {
    
    func newRoutePoint(address: Components.Schemas.Address = .init(fullname: ""),
                       contact: Components.Schemas.Contact = .init(name: "", phone: ""),
                       pointType: Components.Schemas.PointType = .destination) -> Element {
        let newId = (map(\.pointId).max() ?? 0) + 1
        let newVisitOrder = (map(\.visitOrder).max() ?? 0) + 1
        
        return .init(address: address, contact: contact, pointId: newId, _type: pointType, visitOrder: newVisitOrder)
    }
    
    mutating func addRoutePoint(address: Components.Schemas.Address = .init(fullname: ""),
                                contact: Components.Schemas.Contact = .init(name: "", phone: ""),
                                pointType: Components.Schemas.PointType = .destination) {
        self.append(self.newRoutePoint(address: address, contact: contact, pointType: pointType))
    }

}
