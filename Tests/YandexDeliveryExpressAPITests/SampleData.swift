//
//  SampleData.swift
//  YandexDeliveryExpressAPITests
//
//  Request-side sample data: route points, contacts, cargo items, and the requests built
//  from them. This lived in the *shipping* target until TD-12 — public API in every app that
//  linked the package, and in the binary — and belongs here, beside the response fixtures it
//  pairs with.
//
//  The addresses, names, phone numbers and e-mail addresses are fictional, confirmed by the
//  author. The names and one phone number are `openapi.yaml`'s own `Contact` examples, and
//  every domain is `example.com`, reserved for documentation by RFC 2606.
//

import Foundation
@testable import YandexDeliveryExpressAPI

// MARK: - Route Point Samples

extension Components.Schemas.RoutePointWithAddress {
    static let exampleMoscowOffice: Self = .init(value1: .init(id: 1), value2: .exampleMoscowOffice)
    static let exampleMoscowApartment: Self = .init(value1: .init(id: 2), value2: .exampleMoscowApartment)
    static let exampleMoscowStore: Self = .init(value1: .init(id: 3), value2: .exampleMoscowStore)
    static let exampleSPbWarehouse: Self = .init(value1: .init(id: 4), value2: .exampleSPbWarehouse)
}

// MARK: - Item Samples

extension Components.Schemas.ItemBase {
    static let exampleSmallPackage: Self = .init(
        quantity: 1,
        pickupPoint: 1,
        dropoffPoint: 2,
        size: .exampleSmallBox,
        weight: 0.5
    )
    
    static let exampleMediumPackage: Self = .init(
        quantity: 2,
        pickupPoint: 1,
        dropoffPoint: 2,
        size: .exampleMediumBox,
        weight: 2.0
    )
    
    static let exampleLargePackage: Self = .init(
        quantity: 1,
        pickupPoint: 1,
        dropoffPoint: 2,
        size: .exampleLargeBox,
        weight: 5.0
    )
    
    static let exampleDocuments: Self = .init(
        quantity: 1,
        pickupPoint: 1,
        dropoffPoint: 2,
        size: .exampleDocumentEnvelope,
        weight: 0.1
    )
}

// MARK: - Item Size Samples

extension Components.Schemas.ItemSize {
    static let exampleSmallBox: Self = .init(
        length: 0.1,
        width: 0.1,
        height: 0.1
    )
    
    static let exampleMediumBox: Self = .init(
        length: 0.3,
        width: 0.2,
        height: 0.2
    )
    
    static let exampleLargeBox: Self = .init(
        length: 0.5,
        width: 0.4,
        height: 0.3
    )
    
    static let exampleDocumentEnvelope: Self = .init(
        length: 0.32,
        width: 0.23,
        height: 0.01
    )
}

// MARK: - Cargo Item Samples

extension Components.Schemas.CargoItem {
    static let exampleSmartphone: Self = .init(
        costCurrency: .rub,
        costValue: "89990.00",
        pickupPoint: 1,
        quantity: 1,
        title: "Смартфон Apple iPhone 15",
        dropoffPoint: 2,
        extraId: "ORDER-PHONE-001",
        size: .init(length: 0.15, width: 0.07, height: 0.01),
        weight: 0.2,
    )
    
    static let exampleLaptop: Self = .init(
        costCurrency: .rub,
        costValue: "199990.00",
        pickupPoint: 1,
        quantity: 1,
        title: "Ноутбук MacBook Pro",
        dropoffPoint: 2,
        extraId: "ORDER-LAPTOP-002",
        size: .init(length: 0.35, width: 0.25, height: 0.02),
        weight: 1.6
    )
    
    static let exampleBooks: Self = .init(
        costCurrency: .rub,
        costValue: "2500.00",
        pickupPoint: 1,
        quantity: 5,
        title: "Комплект учебников",
        dropoffPoint: 2,
        extraId: "ORDER-BOOKS-003",
        size: .init(length: 0.25, width: 0.18, height: 0.15),
        weight: 2.0
    )
    
    static let exampleClothing: Self = .init(
        costCurrency: .rub,
        costValue: "5000.00",
        pickupPoint: 1,
        quantity: 3,
        title: "Комплект одежды",
        dropoffPoint: 2,
        extraId: "ORDER-CLOTHES-004",
        size: .init(length: 0.4, width: 0.3, height: 0.1),
        weight: 1.0
    )
    
    static let exampleFood: Self = .init(
        costCurrency: .rub,
        costValue: "1200.00",
        pickupPoint: 1,
        quantity: 1,
        title: "Готовая еда",
        dropoffPoint: 2,
        extraId: "ORDER-FOOD-005",
        size: .init(length: 0.3, width: 0.2, height: 0.1),
        weight: 0.8
    )
}

// MARK: - Point Address Samples

extension Components.Schemas.Address {
    static let exampleMoscowOffice: Self = .init(
        fullname: "Москва, ул Москворечье, 6",
        building: "1",
        city: "Москва",
        comment: "В кирпичном здании",
        coordinates: [37.6173, 55.7558],
        country: "Россия",
        doorCode: "301К",
        porch: "А",
        sflat: "301",
        sfloor: "3",
        street: "Москворечье"
    )
    
    static let exampleMoscowApartment: Self = .init(
        fullname: "Москва, Каширское шоссе, 52",
        building: "1",
        city: "Москва",
        comment: "В здании ремонт, всё нормально",
        coordinates: [37.668176, 55.646068],
        country: "Россия",
        porch: "2",
        sflat: "15",
        sfloor: "1",
        street: "Каширское шоссе"
    )
    
    static let exampleMoscowStore: Self = .init(
        fullname: "Москва, Арбат, 10, магазин 'Электроника'",
        building: "10",
        city: "Москва",
        comment: "Магазин электроники, вход со стороны Арбата",
        coordinates: [37.5983, 55.7558],
        country: "Россия",
        street: "Арбат"
    )
    
    static let exampleSPbWarehouse: Self = .init(
        fullname: "Санкт-Петербург, Невский проспект, 100, склад",
        building: "100",
        city: "Санкт-Петербург",
        comment: "Склад, работает с 9:00 до 18:00",
        coordinates: [30.3141, 59.9311],
        country: "Россия",
        street: "Невский проспект"
    )
}

// MARK: - Contact Samples

extension Components.Schemas.Contact {
    static let exampleSender: Self = .init(
        name: "Иван Петров",
        phone: "+79123456789",
        email: "ivan.petrov@example.com"
    )
    
    static let exampleRecipient: Self = .init(
        name: "Анна Сидорова",
        phone: "+79987654321",
        email: "anna.sidorova@example.com"
    )
    
    static let exampleBusinessContact: Self = .init(
        name: "Менеджер склада",
        phone: "+74951234567",
        email: "warehouse@company.com",
        phoneAdditionalCode: "123"
    )
    
    static let exampleCourier: Self = .init(
        name: "Служба доставки",
        phone: "+79001234567",
        email: "delivery@service.com"
    )
}

// MARK: - Cargo Point Samples

extension Components.Schemas.RoutePointBase {
    static let examplePickupOffice: Self = .init(
        address: .exampleMoscowOffice,
        contact: .exampleSender,
        pointId: 1,
        _type: .source,
        visitOrder: 1
)
    
    static let exampleDeliveryApartment: Self = .init(
        address: .exampleMoscowApartment,
        contact: .exampleRecipient,
        pointId: 2,
        _type: .destination,
        visitOrder: 2,
        externalOrderId: "EXT-ORDER-002",
        skipConfirmation: false
    )
    
    static let exampleReturnWarehouse: Self = .init(
        address: .exampleSPbWarehouse,
        contact: .exampleBusinessContact,
        pointId: 3,
        _type: ._return,
        visitOrder: 3,
        externalOrderId: "EXT-ORDER-002",
        skipConfirmation: true
    )
}

// MARK: - Requirements Samples

extension Components.Schemas.OfferRequirements {
    /// No `cargoLoaders`. The live API rejects loaders on the `express` tariff with
    /// `409 estimating.too_many_loaders` — «В выбранном кузове не получится заказать столько
    /// грузчиков» — which is how this fixture was found to be invalid: it had `cargoLoaders: 1`
    /// and every live call using it failed before reaching anything worth testing. Loaders
    /// belong to `cargo`; see `exampleCargoDelivery`.
    static let exampleExpressDelivery: Self = .init(
        proCourier: true,
        skipDoorToDoor: false,
        taxiClasses: [.express]
    )
    
    static let exampleCourierDelivery: Self = .init(
        cargoOptions: [.thermobag],
        proCourier: false,
        skipDoorToDoor: false,
        taxiClasses: [.courier]
    )
    
    static let exampleCargoDelivery: Self = .init(
        cargoLoaders: 2,
        cargoType: .van,
        proCourier: false,
        skipDoorToDoor: true,
        taxiClasses: [.cargo]
    )
    
    static let exampleScheduledDelivery: Self = .init(
        cargoLoaders: 1,
        due: Calendar.current.date(byAdding: .hour, value: 2, to: Date()),
        proCourier: true,
        skipDoorToDoor: false,
        taxiClasses: [.express]
    )
}

extension Components.Schemas.ClientRequirements {
    static let exampleExpressClient: Self = .init(
        taxiClass: .express,
        cargoLoaders: 1,
        proCourier: true
    )
    
    static let exampleCourierClient: Self = .init(
        taxiClass: .courier,
        cargoOptions: [.thermobag],
        proCourier: false
    )
    
    static let exampleCargoClient: Self = .init(
        taxiClass: .cargo,
        cargoLoaders: 2,
        cargoType: .van,
        proCourier: false
    )
}

// MARK: - Request Samples

extension Components.Schemas.OffersCalculateRequest {
    static let exampleBasicRequest: Self = .init(
        routePoints: [
            .exampleMoscowOffice,
            .exampleMoscowApartment
        ],
        items: [
            .exampleSmallPackage
        ],
        requirements: .exampleExpressDelivery
    )
    
    static let exampleMultiPointRequest: Self = .init(
        routePoints: [
            .exampleMoscowOffice,
            .exampleMoscowStore,
            .exampleMoscowApartment
        ],
        items: [
            .exampleSmallPackage,
            .exampleMediumPackage
        ],
        requirements: .exampleCourierDelivery
    )
    
    static let exampleCargoRequest: Self = .init(
        routePoints: [
            .exampleMoscowOffice,
            .exampleSPbWarehouse
        ],
        items: [
            .exampleLargePackage
        ],
        requirements: .exampleCargoDelivery
    )
}

extension Components.Schemas.ClaimCreateRequest {
    static let exampleSmartphoneDelivery: Self = .init(
        items: [.exampleSmartphone],
        routePoints: [
            .examplePickupOffice,
            .exampleDeliveryApartment
        ],
        clientRequirements: .exampleExpressClient,
        comment: "Срочная доставка смартфона"
    )
    
    static let exampleMultiItemDelivery: Self = .init(
        items: [
            .exampleLaptop,
            .exampleBooks
        ],
        routePoints: [
            .examplePickupOffice,
            .exampleDeliveryApartment,
            .exampleReturnWarehouse
        ],
        clientRequirements: .exampleCourierClient,
        comment: "Доставка электроники и книг с возможностью возврата",
        shippingDocument: "Накладная №12345",
        skipDoorToDoor: false
    )
    
    static let exampleFoodDelivery: Self = .init(
        items: [.exampleFood],
        routePoints: [
            .examplePickupOffice,
            .exampleDeliveryApartment
        ],
        clientRequirements: .exampleCourierClient,
        comment: "Доставка готовой еды в термосумке"
    )
}

// MARK: - Array Extensions

extension [Components.Schemas.RoutePointWithAddress] {
    static let exampleMoscowRoute: Self = [
        .exampleMoscowOffice,
        .exampleMoscowApartment
    ]
    
    static let exampleMoscowMultiPoint: Self = [
        .exampleMoscowOffice,
        .exampleMoscowStore,
        .exampleMoscowApartment
    ]
    
    static let exampleInterCityRoute: Self = [
        .exampleMoscowOffice,
        .exampleSPbWarehouse
    ]
}

extension [Components.Schemas.ItemBase] {
    static let exampleSmallOrder: Self = [
        .exampleSmallPackage
    ]
    
    static let exampleMixedOrder: Self = [
        .exampleSmallPackage,
        .exampleMediumPackage,
        .exampleDocuments
    ]
    
    static let exampleLargeOrder: Self = [
        .exampleLargePackage
    ]
}

extension [Components.Schemas.CargoItem] {
    static let exampleElectronicsOrder: Self = [
        .exampleSmartphone,
        .exampleLaptop
    ]
    
    static let exampleMixedOrder: Self = [
        .exampleSmartphone,
        .exampleBooks,
        .exampleClothing
    ]
    
    static let exampleSingleItemOrder: Self = [
        .exampleLaptop
    ]
}

extension [Components.Schemas.RoutePointBase] {
    static let exampleSimpleRoute: Self = [
        .examplePickupOffice,
        .exampleDeliveryApartment
    ]
    
    static let exampleRouteWithReturn: Self = [
        .examplePickupOffice,
        .exampleDeliveryApartment,
        .exampleReturnWarehouse
    ]
}

extension [Components.Schemas.TaxiClass] {
    static let exampleTaxiClasses: Self = [.cargo, .express, .sddLong]
}
