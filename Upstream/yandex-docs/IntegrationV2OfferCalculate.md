---
Source: https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2OfferCalculate
Captured: 2026-09-29
Title: "1. Варианты доставки (для РФ) - Базовые методы | Яндекс Доставка"
SHA-256: 5076f1cca0d36aa0fed91dcaceb4d24658f72a20dd5944a7a5a5208d60361db1
---

# Получение вариантов доставки (для РФ)

-   Метод возвращает доступные варианты доставки.
-   Каждый вариант содержит цену, временной интервал забора заказа на точке А, временной интервал доставки на точку B.
-   После получения вариантов доставки можно выбрать оптимальный и создать заказ с использованием выбранного варианта.
-   Получить варианты доставки можно только в России.

## Request <a id="request"></a>

POST

```
b2b.taxi.yandex.net/b2b/cargo/integration/v2/offers/calculate
```

Адрес сервиса

### Headers <a id="headers"></a>

|     |     |
| --- | --- |
| **Name** | **Description** |
| _Accept-Language_ (required) | **Type**: string<br><br>Предпочитаемый язык ответа<br><br>Например:  <br>`ru` — русский  <br>`en` — английский<br><br>_Example:_ `ru` |

### Body <a id="body"></a>

**application/json**

```
{
  "items": [
    {
      "size": {
        "length": 0.1,
        "width": 0.2,
        "height": 0.3
      },
      "weight": 2.105,
      "quantity": 1,
      "pickup_point": 1,
      "dropoff_point": 2,
      "age_restricted": false
    }
  ],
  "route_points": [
    {
      "id": 1,
      "coordinates": [
        0.1,
        0.1
      ],
      "fullname": "Санкт-Петербург, Большая Монетная улица, 1к1А",
      "country": "Россия",
      "city": "Санкт-Петербург",
      "street": "Большая Монетная улица",
      "building": "23к1А",
      "porch": "A",
      "sfloor": "1",
      "sflat": "1"
    },
    {
      "id": 1,
      "coordinates": [
        0.1,
        0.1
      ],
      "fullname": "Санкт-Петербург, Большая Монетная улица, 1к1А",
      "country": "Россия",
      "city": "Санкт-Петербург",
      "street": "Большая Монетная улица",
      "building": "23к1А",
      "porch": "A",
      "sfloor": "1",
      "sflat": "1"
    }
  ],
  "referral_source": "bitrix",
  "requirements": {
    "taxi_classes": [
      "cargo"
    ],
    "cargo_type": "lcv_m",
    "cargo_loaders": 1,
    "pro_courier": false,
    "cargo_options": [
      "thermobag"
    ],
    "skip_door_to_door": false,
    "due": "2020-01-01T00:00:00+00:00",
    "rental_duration": 0
  }
}
```

|     |     |
| --- | --- |
| **Name** | **Description** |
| _items_ (required) | **Type**: [Item](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2OfferCalculate#entity-Item)\[\]<br><br>Параметры товаров<br><br>_Min items:_ `1`<br><br>**Example**<br><br>```<br>[<br>  {<br>    "size": {<br>      "length": 0.1,<br>      "width": 0.2,<br>      "height": 0.3<br>    },<br>    "weight": 2.105,<br>    "quantity": 1,<br>    "pickup_point": 1,<br>    "dropoff_point": 2,<br>    "age_restricted": false<br>  }<br>]<br>``` |
| _route\_points_ (required) | **Type**: [RoutePointWithAddress](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2OfferCalculate#entity-RoutePointWithAddress)\[\]<br><br>Точки маршрута. Отсортированы в порядке посещения А-Б1....БN<br><br>_Min items:_ `2`<br><br>**Example**<br><br>```<br>[<br>  {<br>    "id": 1,<br>    "coordinates": [<br>      0.1,<br>      0.1<br>    ],<br>    "fullname": "Санкт-Петербург, Большая Монетная улица, 1к1А",<br>    "country": "Россия",<br>    "city": "Санкт-Петербург",<br>    "street": "Большая Монетная улица",<br>    "building": "23к1А",<br>    "porch": "A",<br>    "sfloor": "1",<br>    "sflat": "1"<br>  },<br>  {<br>    "id": 1,<br>    "coordinates": [<br>      0.1,<br>      0.1<br>    ],<br>    "fullname": "Санкт-Петербург, Большая Монетная улица, 1к1А",<br>    "country": "Россия",<br>    "city": "Санкт-Петербург",<br>    "street": "Большая Монетная улица",<br>    "building": "23к1А",<br>    "porch": "A",<br>    "sfloor": "1",<br>    "sflat": "1"<br>  }<br>]<br>``` |
| _referral\_source_ | **Type**: string<br><br>Источник заявки (например, наименование CMS или интеграционного модуля).  <br>Учитывается при расчёте стоимости доставки. При создании заявки через claims/create  <br>передавайте то же значение referral\_source, которое использовали при расчёте оффера.  <br>Для LandPro используйте module\_berid, для прямой интеграции с Wildberries — wildberries.<br><br>_Example:_ `bitrix` |
| _requirements_ | **Type**: [OfferRequirements](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2OfferCalculate#entity-OfferRequirements)<br><br>Требования к доставке<br><br>**Example**<br><br>```<br>{<br>  "taxi_classes": [<br>    "cargo"<br>  ],<br>  "cargo_type": "lcv_m",<br>  "cargo_loaders": 1,<br>  "pro_courier": false,<br>  "cargo_options": [<br>    "thermobag"<br>  ],<br>  "skip_door_to_door": false,<br>  "due": "2020-01-01T00:00:00+00:00",<br>  "rental_duration": 0<br>}<br>``` |

### CargoItemSizes <a id="entity-CargoItemSizes"></a>

Габариты товара в метрах. В полях следует передавать актуальные значения.

Если габариты не были переданы, заказ оформляется с учетом
максимально допустимых габаритов для выбранного тарифа.

Если фактические характеристики товара превысят допустимые,
курьер вправе отказаться от выполнения такого заказа на месте.
В этом случае будет удержана стоимость подачи.

Курьер (courier): до 0.80 м × 0.50 м × 0.50 м
Экспресс (express): до 1.00 м × 0.60 м × 0.50 м
Грузовой (cargo):

-   Маленький кузов: до 1.70 м × 0.96 м × 0.90 м
-   Средний кузов: до 2.60 м × 1.30 м × 1.50 м
-   Большой кузов: до 3.80 м × 1.80 м × 1.80 м

|     |     |
| --- | --- |
| **Name** | **Description** |
| _height_ (required) | **Type**: number<br><br>Высота в метрах<br><br>_Min value:_ `0`<br><br>_Max value:_ `500` |
| _length_ (required) | **Type**: number<br><br>Длина в метрах<br><br>_Min value:_ `0`<br><br>_Max value:_ `500` |
| _width_ (required) | **Type**: number<br><br>Ширина в метрах<br><br>_Min value:_ `0`<br><br>_Max value:_ `500` |

**Example**

```
{
  "length": 0.1,
  "width": 0.2,
  "height": 0.3
}
```

### Item <a id="entity-Item"></a>

|     |     |
| --- | --- |
| **Name** | **Description** |
| _quantity_ (required) | **Type**: integer<br><br>Количество единиц товара<br><br>_Min value:_ `1` |
| _age\_restricted_ | **Type**: boolean<br><br>Нужно ли проверить возраст клиента при выдаче товара.  <br>Проверка возраста недоступна для заказов роботом доставщиком.<br><br>_Default:_ `false` |
| _dropoff\_point_ | **Type**: integer<br><br>Идентификатор точки (int64), куда нужно доставить товар.  <br>Может быть любым числом. Должен соответствовать значению route\_points\[\].id у точки назначения.  <br>Параметр обязательный, если в заказе несколько точек доставки. |
| _pickup\_point_ | **Type**: integer<br><br>Идентификатор точки (int64), откуда нужно забрать товар.  <br>Может быть любым числом. Должен соответствовать значению route\_points\[\].id у точки отправки.  <br>Параметр обязательный, если в заказе несколько точек доставки. |
| _size_ | **Type**: [CargoItemSizes](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2OfferCalculate#entity-CargoItemSizes)<br><br>Габариты товара в метрах. В полях следует передавать актуальные значения.<br><br>Если габариты не были переданы, заказ оформляется с учетом  <br>максимально допустимых габаритов для выбранного тарифа.<br><br>Если фактические характеристики товара превысят допустимые,  <br>курьер вправе отказаться от выполнения такого заказа на месте.  <br>В этом случае будет удержана стоимость подачи.<br><br>Курьер (courier): до 0.80 м × 0.50 м × 0.50 м  <br>Экспресс (express): до 1.00 м × 0.60 м × 0.50 м  <br>Грузовой (cargo):<br><br>  <br>\- Маленький кузов: до 1.70 м × 0.96 м × 0.90 м  <br>\- Средний кузов: до 2.60 м × 1.30 м × 1.50 м  <br>\- Большой кузов: до 3.80 м × 1.80 м × 1.80 м **Example**<br><br>```<br>{<br>  "length": 0.1,<br>  "width": 0.2,<br>  "height": 0.3<br>}<br>``` |
| _weight_ | **Type**: number<br><br>Вес товара в килограммах.  <br>Пример: 2.105 |

**Example**

```
{
  "size": {
    "length": 0.1,
    "width": 0.2,
    "height": 0.3
  },
  "weight": 2.105,
  "quantity": 1,
  "pickup_point": 1,
  "dropoff_point": 2,
  "age_restricted": false
}
```

### Point <a id="entity-Point"></a>

Координаты точек в виде массива из двух вещественных чисел: долгота, широта — именно в таком порядке.

**Type**: number\[\]

_Min items:_ `2`

_Max items:_ `2`

**Example**

```
[
  0.1,
  0.1
]
```

### AddressFullname <a id="entity-AddressFullname"></a>

Полный адрес с указанием города, улицы и номера дома.
Номер квартиры, подъезда и этаж указывать не нужно.

**Type**: string

_Example:_ `Санкт-Петербург, Большая Монетная улица, 1к1А`

### RoutePointWithAddress <a id="entity-RoutePointWithAddress"></a>

|     |     |
| --- | --- |
| **Name** | **Description** |
| _building_ | **Type**: string<br><br>Строение<br><br>_Example:_ `23к1А` |
| _city_ | **Type**: string<br><br>Город<br><br>_Example:_ `Санкт-Петербург` |
| _coordinates_ | **Type**: [Point](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2OfferCalculate#entity-Point)<br><br>Координаты точек в виде массива из двух вещественных чисел: долгота, широта — именно в таком порядке.<br><br>_Min items:_ `2`<br><br>_Max items:_ `2`<br><br>**Example**<br><br>```<br>[<br>  0.1,<br>  0.1<br>]<br>``` |
| _country_ | **Type**: string<br><br>Страна<br><br>_Example:_ `Россия` |
| _fullname_ | **Type**: [AddressFullname](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2OfferCalculate#entity-AddressFullname)<br><br>Полный адрес с указанием города, улицы и номера дома.  <br>Номер квартиры, подъезда и этаж указывать не нужно.<br><br>_Example:_ `Санкт-Петербург, Большая Монетная улица, 1к1А` |
| _id_ | **Type**: integer<br><br>Числовой id точки(int64). Параметр обязательный, если в заказе несколько точек доставки |
| _porch_ | **Type**: string<br><br>Подъезд (может быть A)<br><br>_Example:_ `A` |
| _sflat_ | **Type**: string<br><br>Квартира<br><br>_Example:_ `1` |
| _sfloor_ | **Type**: string<br><br>Этаж<br><br>_Example:_ `1` |
| _street_ | **Type**: string<br><br>Улица<br><br>_Example:_ `Большая Монетная улица` |

**Example**

```
{
  "id": 1,
  "coordinates": [
    0.1,
    0.1
  ],
  "fullname": "Санкт-Петербург, Большая Монетная улица, 1к1А",
  "country": "Россия",
  "city": "Санкт-Петербург",
  "street": "Большая Монетная улица",
  "building": "23к1А",
  "porch": "A",
  "sfloor": "1",
  "sflat": "1"
}
```

### CargoType <a id="entity-CargoType"></a>

Тип (размер) кузова для грузового тарифа.
Возможные значения:

-   van ("Маленький кузов")
-   lcv\_m ("Средний кузов")
-   lcv\_l ("Большой кузов")
-   lcv\_xl ("Кузов XL")
    Точный список возможных значений для конкретной геоточки уточняйте с помощью метода получения тарифов [tariffs](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2Tariffs)

**Type**: string

_Enum:_ `van`, `lcv_m`, `lcv_l`, `lcv_xl`

### CargoOptions <a id="entity-CargoOptions"></a>

Список дополнительных опций тарифа.

Возможные отдельные опции:

-   auto\_courier (курьер только на автомобиле)
-   thermobag (курьер с термосумкой)

Пример списка опций: \["auto\_courier"\].

Точный список возможных значений для конкретной геоточки
уточните с помощью метода получения тарифов [tariffs](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2Tariffs)

**Type**: string\[\]

**Example**

```
[
  "thermobag"
]
```

### OfferRequirements <a id="entity-OfferRequirements"></a>

Требования к доставке

|     |     |
| --- | --- |
| **Name** | **Description** |
| _cargo\_loaders_ | **Type**: integer<br><br>Число грузчиков для грузового тарифа.  <br>Возможные значения: 0, 1, 2.<br><br>Точный список возможных значений для конкретной геоточки  <br>уточните с помощью метода получения тарифов [tariffs](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2Tariffs) |
| _cargo\_options_ | **Type**: [CargoOptions](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2OfferCalculate#entity-CargoOptions)<br><br>Список дополнительных опций тарифа.<br><br>Возможные отдельные опции:<br><br>  <br>\- auto\_courier (курьер только на автомобиле)  <br>\- thermobag (курьер с термосумкой)<br><br>Пример списка опций: \["auto\_courier"\].<br><br>Точный список возможных значений для конкретной геоточки  <br>уточните с помощью метода получения тарифов [tariffs](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2Tariffs)<br><br>**Example**<br><br>```<br>[<br>  "thermobag"<br>]<br>``` |
| _cargo\_type_ | **Type**: [CargoType](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2OfferCalculate#entity-CargoType)<br><br>Тип (размер) кузова для грузового тарифа.  <br>Возможные значения:<br><br>  <br>\- van ("Маленький кузов")  <br>\- lcv\_m ("Средний кузов")  <br>\- lcv\_l ("Большой кузов")  <br>\- lcv\_xl ("Кузов XL")  <br>Точный список возможных значений для конкретной геоточки уточняйте с помощью метода получения тарифов [tariffs](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2Tariffs)<br><br>_Enum:_ `van`, `lcv_m`, `lcv_l`, `lcv_xl` |
| _due_ | **Type**: string<date-time><br><br>Желаемое время прибытия исполнителя на точку А (source).  <br>В РФ отложить расчетное время прибытия исполнителя можно:  <br>\- на 30-240 минут от текущего момента – для тарифа `express`;  <br>\- на пять суток от текущего момента – для тарифа `cargo`.<br><br>Параметр не совместим с опциями замедления в тарифе `express` на территории РФ.  <br>Если этот параметр не задан, то запустится поиск исполнителя на ближайшее время.<br><br>_Example:_ `2020-01-01T00:00:00+00:00` |
| _pro\_courier_ | **Type**: boolean<br><br>Включить опцию "Профи" для тарифов "Экспресс" и "Курьер".  <br>Поиск исполнителя будет происходить только среди опытных курьеров. |
| _rental\_duration_ | **Type**: integer<br><br>Время аренды, которое планирует клиент. Указывается в минутах.  <br>Указывайте этот параметр только для почасового тарифа |
| _skip\_door\_to\_door_ | **Type**: boolean<br><br>Отключить доставку до двери (выключить опцию "От двери до двери").<br><br>Возможные значения:<br><br>  <br>\- true (курьер доставит заказ только на улицу, до подъезда)  <br>\- false (курьер доставит заказ до двери)<br><br>_Default:_ `false` |
| _taxi\_classes_ | **Type**: string\[\]<br><br>Класс автомобиля для доставки.  <br>Возможные значения: courier, express, cargo, sdd\_multislot<br><br>Точный список возможных значений для конкретной геоточки  <br>уточните с помощью метода получения тарифов [tariffs](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2Tariffs)<br><br>_Min items:_ `1`<br><br>**Example**<br><br>```<br>[<br>  "cargo"<br>]<br>``` |

**Example**

```
{
  "taxi_classes": [
    "cargo"
  ],
  "cargo_type": "lcv_m",
  "cargo_loaders": 1,
  "pro_courier": false,
  "cargo_options": [
    "thermobag"
  ],
  "skip_door_to_door": false,
  "due": "2020-01-01T00:00:00+00:00",
  "rental_duration": 0
}
```

## Responses <a id="responses"></a>

## 200 OK <a id="200-ok"></a>

OK

### Body <a id="body1"></a>

**application/json**

```
{
  "offers": [
    {
      "price": {
        "total_price": "673.0",
        "total_price_with_vat": "807.6",
        "base_price": "611.8",
        "surge_ratio": 1.1,
        "currency": "RUB"
      },
      "taxi_class": "express",
      "pickup_interval": {
        "from": "2023-07-17T08:02:26.607358+00:00",
        "to": "2023-07-17T08:42:26.607358+00:00"
      },
      "delivery_interval": {
        "from": "2023-07-17T08:02:26.607358+00:00",
        "to": "2023-07-17T09:15:43.607358+00:00"
      },
      "description": "express_30min_longer",
      "payload": "5e2TPP5f7Yqyv19yRZ+QVas4JK+lhwa17ncxA3VCGI8hvnFS+CIySbmfHQlR6vhC2S4XsW+M7TbEV0EQl1/1Z0PO3QQX8KbGb6rtKay",
      "offer_ttl": "2020-01-02T00:00:00+00:00"
    }
  ]
}
```

|     |     |
| --- | --- |
| **Name** | **Description** |
| _offers_ (required) | **Type**: [CalculatedOffer](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2OfferCalculate#entity-CalculatedOffer)\[\]<br><br>Массив предложений доставки<br><br>**Example**<br><br>```<br>[<br>  {<br>    "price": {<br>      "total_price": "673.0",<br>      "total_price_with_vat": "807.6",<br>      "base_price": "611.8",<br>      "surge_ratio": 1.1,<br>      "currency": "RUB"<br>    },<br>    "taxi_class": "express",<br>    "pickup_interval": {<br>      "from": "2023-07-17T08:02:26.607358+00:00",<br>      "to": "2023-07-17T08:42:26.607358+00:00"<br>    },<br>    "delivery_interval": {<br>      "from": "2023-07-17T08:02:26.607358+00:00",<br>      "to": "2023-07-17T09:15:43.607358+00:00"<br>    },<br>    "description": "express_30min_longer",<br>    "payload": "5e2TPP5f7Yqyv19yRZ+QVas4JK+lhwa17ncxA3VCGI8hvnFS+CIySbmfHQlR6vhC2S4XsW+M7TbEV0EQl1/1Z0PO3QQX8KbGb6rtKay",<br>    "offer_ttl": "2020-01-02T00:00:00+00:00"<br>  }<br>]<br>``` |

### Currency <a id="entity-Currency"></a>

Трехзначный код валюты, в которой ведется расчет

**Type**: string

_Min length:_ `3`

_Max length:_ `3`

_Example:_ `RUB`

### CalculatedOfferPrice <a id="entity-CalculatedOfferPrice"></a>

Стоимость доставки

|     |     |
| --- | --- |
| **Name** | **Description** |
| _currency_ (required) | **Type**: [Currency](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2OfferCalculate#entity-Currency)<br><br>Трехзначный код валюты, в которой ведется расчет<br><br>_Min length:_ `3`<br><br>_Max length:_ `3`<br><br>_Example:_ `RUB` |
| _surge\_ratio_ (required) | **Type**: number<br><br>Коэффициент роста стоимости заказа (в зависимости от нагрузки на систему) |
| _total\_price_ (required) | **Type**: string<br><br>Цена c учетом коэффициента роста стоимости заказа (без НДС)<br><br>_Pattern:_ `^-?[0-9]{1,14}(\.[0-9]{0,4})?$`<br><br>_Example:_ `673.0` |
| _total\_price\_with\_vat_ (required) | **Type**: string<br><br>Цена с учетом коэффициента роста стоимости заказа (с НДС)<br><br>_Pattern:_ `^-?[0-9]{1,14}(\.[0-9]{0,4})?$`<br><br>_Example:_ `807.6` |
| _base\_price_ | **Type**: string<br><br>Базовая цена доставки<br><br>_Pattern:_ `^-?[0-9]{1,14}(\.[0-9]{0,4})?$`<br><br>_Example:_ `611.8` |

**Example**

```
{
  "total_price": "673.0",
  "total_price_with_vat": "807.6",
  "base_price": "611.8",
  "surge_ratio": 1.1,
  "currency": "RUB"
}
```

### PickupTimeInterval <a id="entity-PickupTimeInterval"></a>

Временной интервал забора (по точке A)

|     |     |
| --- | --- |
| **Name** | **Description** |
| _from_ (required) | **Type**: string<date-time><br><br>Начало интервала (UTC)<br><br>_Example:_ `2023-07-17T08:02:26.607358+00:00` |
| _to_ (required) | **Type**: string<date-time><br><br>Окончание интервала (дата и время)<br><br>_Example:_ `2023-07-17T08:42:26.607358+00:00` |

**Example**

```
{
  "from": "2023-07-17T08:02:26.607358+00:00",
  "to": "2023-07-17T08:42:26.607358+00:00"
}
```

### DeliveryTimeInterval <a id="entity-DeliveryTimeInterval"></a>

Временной интервал доставки (по точке B)

|     |     |
| --- | --- |
| **Name** | **Description** |
| _from_ (required) | **Type**: string<date-time><br><br>Начало интервала (UTC)<br><br>_Example:_ `2023-07-17T08:02:26.607358+00:00` |
| _to_ (required) | **Type**: string<date-time><br><br>Окончание интервала (дата и время)<br><br>_Example:_ `2023-07-17T09:15:43.607358+00:00` |

**Example**

```
{
  "from": "2023-07-17T08:02:26.607358+00:00",
  "to": "2023-07-17T09:15:43.607358+00:00"
}
```

### CalculatedOffer <a id="entity-CalculatedOffer"></a>

Варианты доставки

|     |     |
| --- | --- |
| **Name** | **Description** |
| _delivery\_interval_ (required) | **Type**: [DeliveryTimeInterval](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2OfferCalculate#entity-DeliveryTimeInterval)<br><br>Временной интервал доставки (по точке B)<br><br>**Example**<br><br>```<br>{<br>  "from": "2023-07-17T08:02:26.607358+00:00",<br>  "to": "2023-07-17T09:15:43.607358+00:00"<br>}<br>``` |
| _payload_ (required) | **Type**: string<br><br>payload оффера доставки. Чтобы заказать доставку по выбранному офферу, нужно передать payload в методе [claims/create](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate).<br><br>_Example:_ `5e2TPP5f7Yqyv19yRZ+QVas4JK+lhwa17ncxA3VCGI8hvnFS+CIySbmfHQlR6vhC2S4XsW+M7TbEV0EQl1/1Z0PO3QQX8KbGb6rtKay` |
| _pickup\_interval_ (required) | **Type**: [PickupTimeInterval](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2OfferCalculate#entity-PickupTimeInterval)<br><br>Временной интервал забора (по точке A)<br><br>**Example**<br><br>```<br>{<br>  "from": "2023-07-17T08:02:26.607358+00:00",<br>  "to": "2023-07-17T08:42:26.607358+00:00"<br>}<br>``` |
| _price_ (required) | **Type**: [CalculatedOfferPrice](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2OfferCalculate#entity-CalculatedOfferPrice)<br><br>Стоимость доставки<br><br>**Example**<br><br>```<br>{<br>  "total_price": "673.0",<br>  "total_price_with_vat": "807.6",<br>  "base_price": "611.8",<br>  "surge_ratio": 1.1,<br>  "currency": "RUB"<br>}<br>``` |
| _taxi\_class_ (required) | **Type**: string<br><br>Тарифный класс<br><br>_Example:_ `express` |
| _description_ | **Type**: string<br><br>Описание варианта доставки. Пример: express\_30min\_longer (экспресс с замедлением на 30 минут)<br><br>_Example:_ `express_30min_longer` |
| _offer\_ttl_ | **Type**: string<date-time><br><br>Время, до которого оффер можно использовать для создания заявки. Если  <br>создать заявку после этого момента, то заявка перейдет в  <br>статус 'estimating\_failed'<br><br>_Example:_ `2020-01-02T00:00:00+00:00` |

**Example**

```
{
  "price": {
    "total_price": "673.0",
    "total_price_with_vat": "807.6",
    "base_price": "611.8",
    "surge_ratio": 1.1,
    "currency": "RUB"
  },
  "taxi_class": "express",
  "pickup_interval": {
    "from": "2023-07-17T08:02:26.607358+00:00",
    "to": "2023-07-17T08:42:26.607358+00:00"
  },
  "delivery_interval": {
    "from": "2023-07-17T08:02:26.607358+00:00",
    "to": "2023-07-17T09:15:43.607358+00:00"
  },
  "description": "express_30min_longer",
  "payload": "5e2TPP5f7Yqyv19yRZ+QVas4JK+lhwa17ncxA3VCGI8hvnFS+CIySbmfHQlR6vhC2S4XsW+M7TbEV0EQl1/1Z0PO3QQX8KbGb6rtKay",
  "offer_ttl": "2020-01-02T00:00:00+00:00"
}
```

## 400 Bad Request <a id="400-bad-request"></a>

Неверный запрос

### Body <a id="body2"></a>

**application/json**

```
{
  "code": "bad_request",
  "message": "bad request"
}
```

|     |     |
| --- | --- |
| **Name** | **Description** |
| _code_ (required) | **Type**: string<br><br>Код ошибки<br><br>_Enum:_ `unknown_error`, `bad_request`, `address_not_found`, `validation_error` |
| _message_ (required) | **Type**: string<br><br>Описание ошибки<br><br>_Example:_ `bad request` |

## 409 Conflict <a id="409-conflict"></a>

Не удалось рассчитать офферы

### Body <a id="body3"></a>

**application/json**

```
{
  "code": "estimating.requirement_unavailable",
  "message": "requirement unavailable"
}
```

|     |     |
| --- | --- |
| **Name** | **Description** |
| _code_ (required) | **Type**: string<br><br>Код ошибки<br><br>_Enum:_ `unknown_error`, `errors.suitable_offer_not_found`, `estimating.cargocorp_payment_failure`, `estimating.limited_by_claims_creation_overflow`, `estimating.no_pickup_point`, `estimating.payment_method_cant_order`, `estimating.payment_method_forbidden`, `estimating.permitted_tariffs_not_enough`, `estimating.requirement_unavailable`, `estimating.route_too_long`, `estimating.route_too_short`, `estimating.tariff.not_available_in_zone`, `estimating.tariff.not_present_in_tariff_line_strategy`, `estimating.tariff.no_sdd_tariff`, `estimating.too_large_linear_size`, `estimating.too_many_loaders`, `estimating.cargo_type_unavailable`, `estimating.warning.too_heavy_item`, `estimating.warning.too_large_item`, `estimating.zone_unavailable`, `estimating.swapped_coordinates`, `estimating.payment_method_zone_unavailable`, `estimating.route_is_prohibited`, `estimating.robot.no_route` |
| _message_ (required) | **Type**: string<br><br>Описание ошибки<br><br>_Example:_ `requirement unavailable` |

## 429 Too Many Requests <a id="429-too-many-requests"></a>

Слишком много запросов

### Body <a id="body4"></a>

**application/json**

```
{
  "code": "too_many_requests",
  "message": "Слишком много запросов"
}
```

|     |     |
| --- | --- |
| **Name** | **Description** |
| _code_ (required) | **Type**: string<br><br>Код ошибки<br><br>_Enum:_ `unknown_error`, `too_many_requests` |
| _message_ (required) | **Type**: string<br><br>Описание ошибки<br><br>_Example:_ `Слишком много запросов` |
