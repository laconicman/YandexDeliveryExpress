---
Source: https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate
Captured: 2026-09-29
Title: "2. Создание заявки - Базовые методы | Яндекс Доставка"
SHA-256: 2de7214a9f6604786362d796fa26e6c37a0374e2531d344c6ee7bb5145ba5635
---

# Создание заявки

Метод создает заявку с указанными параметрами в системе Яндекс Доставки. Отправка запроса не означает, что заказ принят в работу.
Для доставки в течение дня необходимо в теле запроса заполнить поле `same_day_data` указать габариты и вес товара. Раздел `client_requirements` заполнять не нужно. Тариф доставки в течение дня недоступен в России.
Результат оценки заказа можно узнать при помощи метода [claims/info](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsInfo).

## Request <a id="request"></a>

POST

```
b2b.taxi.yandex.net/b2b/cargo/integration/v2/claims/create
```

Адрес сервиса

### Query parameters <a id="query-parameters"></a>

|     |     |
| --- | --- |
| **Name** | **Description** |
| _request\_id_ (required) | **Type**: string<br><br>Токен идемпотентности. Допускаются буквы, цифры, другие символы. Чтобы гарантировать уникальность значений, рекомендуем использовать формат uuid и его производные.<br><br>Если при создании заявки была получена ошибка сервера (код 5xx) или произошел таймаут, используйте то же значение для повторной попытки. (Иначе возможно дублирование заявки, в результате чего за заказом может приехать несколько курьеров).<br><br>В остальных случаях (при создании новой заявки) следует использовать новое значение request\_id.  <br>[Подробнее](https://yandex.ru/support/delivery-profile/ru/api/express/faq#claim-create)<br><br>_Min length:_ `1`<br><br>_Max length:_ `128`<br><br>_Example:_ \`\` |

### Headers <a id="headers"></a>

|     |     |
| --- | --- |
| **Name** | **Description** |
| _Accept-Language_ (required) | **Type**: string<br><br>Предпочитаемый язык ответа<br><br>Например:  <br>`ru` — русский  <br>`en` — английский<br><br>_Example:_ `ru` |

### Body <a id="body"></a>

**application/json**

```
{
  "shipping_document": "example",
  "items": [
    {
      "extra_id": "БП-208",
      "pickup_point": 1,
      "dropoff_point": 2,
      "droppof_point": 0,
      "title": "Плюмбус",
      "size": {
        "length": 0.1,
        "width": 0.2,
        "height": 0.3
      },
      "weight": 2,
      "cost_value": "2.00",
      "cost_currency": "RUB",
      "quantity": 1,
      "fiscalization": {
        "excise": "12.50",
        "vat_code_str": "vat_none",
        "supplier_inn": "3664069397",
        "article": "20ML50OWKY4FC86",
        "mark": {
          "kind": "gs1_data_matrix_base64",
          "code": "444D00000000003741"
        },
        "item_type": "product"
      },
      "age_restricted": false
    }
  ],
  "packages": [
    {
      "package_id": "a8e5b0e6-3d67-4d6f-89a5-3b6c1a0e4f5c",
      "package_type": "other",
      "package_code": "ab10702030/?",
      "pickup_point": 1,
      "dropoff_point": 2
    }
  ],
  "route_points": [
    {
      "point_id": 6987,
      "visit_order": 1,
      "contact": {
        "name": "Морти",
        "phone": "+79099999998",
        "phone_additional_code": "602 17 500",
        "email": "example@yandex.ru"
      },
      "address": {
        "fullname": "Санкт-Петербург, Большая Монетная улица, 1к1А",
        "shortname": "Большая Монетная улица, 1к1А",
        "coordinates": [
          0.5,
          0.5
        ],
        "country": "Россия",
        "city": "Санкт-Петербург",
        "building_name": "БЦ На Большой Монетной",
        "street": "Большая Монетная улица",
        "building": "23к1А",
        "porch": "A",
        "sfloor": "1",
        "sflat": "1",
        "door_code": "169",
        "door_code_extra": "код на вход во двор #1234, код от апартаментов #4321",
        "doorbell_name": "Магидович",
        "comment": "Домофон не работает",
        "uri": "ymapsbm1://geo?ll=38.805%2C55.084",
        "description": "Санкт-Петербург, Россия"
      },
      "skip_confirmation": false,
      "leave_under_door": true,
      "meet_outside": true,
      "no_door_call": true,
      "type": "source",
      "buyout": {
        "payment_method": "card"
      },
      "payment_on_delivery": {
        "customer": {
          "inn": "3664069397",
          "email": "example@yandex.ru",
          "phone": "79000000000"
        },
        "payment_method": null
      },
      "external_order_id": "100",
      "external_order_cost": {
        "value": "100.0",
        "currency": "RUB",
        "currency_sign": "₽"
      },
      "pickup_code": "893422",
      "nonblocking_pickup_code": "ab#001",
      "should_notify_on_order_readiness": false,
      "code_verification_properties": {
        "code_verification_url": "https://www.example.com/"
      }
    },
    {
      "point_id": 6987,
      "visit_order": 1,
      "contact": {
        "name": "Морти",
        "phone": "+79099999998",
        "phone_additional_code": "602 17 500",
        "email": "example@yandex.ru"
      },
      "address": {
        "fullname": "Санкт-Петербург, Большая Монетная улица, 1к1А",
        "shortname": "Большая Монетная улица, 1к1А",
        "coordinates": [
          0.5,
          0.5
        ],
        "country": "Россия",
        "city": "Санкт-Петербург",
        "building_name": "БЦ На Большой Монетной",
        "street": "Большая Монетная улица",
        "building": "23к1А",
        "porch": "A",
        "sfloor": "1",
        "sflat": "1",
        "door_code": "169",
        "door_code_extra": "код на вход во двор #1234, код от апартаментов #4321",
        "doorbell_name": "Магидович",
        "comment": "Домофон не работает",
        "uri": "ymapsbm1://geo?ll=38.805%2C55.084",
        "description": "Санкт-Петербург, Россия"
      },
      "skip_confirmation": false,
      "leave_under_door": true,
      "meet_outside": true,
      "no_door_call": true,
      "type": "source",
      "buyout": {
        "payment_method": "card"
      },
      "payment_on_delivery": {
        "customer": {
          "inn": "3664069397",
          "email": "example@yandex.ru",
          "phone": "79000000000"
        },
        "payment_method": null
      },
      "external_order_id": "100",
      "external_order_cost": {
        "value": "100.0",
        "currency": "RUB",
        "currency_sign": "₽"
      },
      "pickup_code": "893422",
      "nonblocking_pickup_code": "ab#001",
      "should_notify_on_order_readiness": false,
      "code_verification_properties": {
        "code_verification_url": "https://www.example.com/"
      }
    }
  ],
  "emergency_contact": {
    "name": "Рик",
    "phone": "+79826810246",
    "phone_additional_code": "602 17 500"
  },
  "client_requirements": {
    "taxi_class": "express",
    "cargo_type": "lcv_m",
    "cargo_loaders": 0,
    "cargo_options": [
      "thermobag"
    ],
    "pro_courier": false,
    "assign_robot": true,
    "rental_duration": 0
  },
  "callback_properties": {
    "callback_url": "https://www.example.com/"
  },
  "skip_door_to_door": false,
  "skip_client_notify": false,
  "skip_emergency_notify": false,
  "skip_act": false,
  "optional_return": false,
  "due": "2020-01-01T00:00:00+00:00",
  "comment": "Ресторан",
  "referral_source": "bitrix",
  "same_day_data": {
    "delivery_interval": {
      "from": "2020-01-01T07:00:00+00:00",
      "to": "2020-01-01T07:00:00+00:00"
    }
  },
  "auto_accept": true,
  "offer_payload": "asjdijasDKL;ahsdfljhlkjhasF;HS;Ldjf;ljloshf"
}
```

|     |     |
| --- | --- |
| **Name** | **Description** |
| _items_ (required) | **Type**: [CargoItem](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-CargoItem)\[\]<br><br>Параметры товаров<br><br>_Min items:_ `1`<br><br>**Example**<br><br>```<br>[<br>  {<br>    "extra_id": "БП-208",<br>    "pickup_point": 1,<br>    "dropoff_point": 2,<br>    "droppof_point": 0,<br>    "title": "Плюмбус",<br>    "size": {<br>      "length": 0.1,<br>      "width": 0.2,<br>      "height": 0.3<br>    },<br>    "weight": 2,<br>    "cost_value": "2.00",<br>    "cost_currency": "RUB",<br>    "quantity": 1,<br>    "fiscalization": {<br>      "excise": "12.50",<br>      "vat_code_str": "vat_none",<br>      "supplier_inn": "3664069397",<br>      "article": "20ML50OWKY4FC86",<br>      "mark": {<br>        "kind": "gs1_data_matrix_base64",<br>        "code": "444D00000000003741"<br>      },<br>      "item_type": "product"<br>    },<br>    "age_restricted": false<br>  }<br>]<br>``` |
| _route\_points_ (required) | **Type**: [RequestCargoRoutePoints](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-RequestCargoRoutePoints)<br><br>Информация по точкам маршрута<br><br>_Min items:_ `2`<br><br>_Max items:_ `300`<br><br>**Example**<br><br>```<br>[<br>  {<br>    "point_id": 6987,<br>    "visit_order": 1,<br>    "contact": {<br>      "name": "Морти",<br>      "phone": "+79099999998",<br>      "phone_additional_code": "602 17 500",<br>      "email": "example@yandex.ru"<br>    },<br>    "address": {<br>      "fullname": "Санкт-Петербург, Большая Монетная улица, 1к1А",<br>      "shortname": "Большая Монетная улица, 1к1А",<br>      "coordinates": [<br>        0.5,<br>        0.5<br>      ],<br>      "country": "Россия",<br>      "city": "Санкт-Петербург",<br>      "building_name": "БЦ На Большой Монетной",<br>      "street": "Большая Монетная улица",<br>      "building": "23к1А",<br>      "porch": "A",<br>      "sfloor": "1",<br>      "sflat": "1",<br>      "door_code": "169",<br>      "door_code_extra": "код на вход во двор #1234, код от апартаментов #4321",<br>      "doorbell_name": "Магидович",<br>      "comment": "Домофон не работает",<br>      "uri": "ymapsbm1://geo?ll=38.805%2C55.084",<br>      "description": "Санкт-Петербург, Россия"<br>    },<br>    "skip_confirmation": false,<br>    "leave_under_door": true,<br>    "meet_outside": true,<br>    "no_door_call": true,<br>    "type": "source",<br>    "buyout": {<br>      "payment_method": "card"<br>    },<br>    "payment_on_delivery": {<br>      "customer": {<br>        "inn": "3664069397",<br>        "email": "example@yandex.ru",<br>        "phone": "79000000000"<br>      },<br>      "payment_method": null<br>    },<br>    "external_order_id": "100",<br>    "external_order_cost": {<br>      "value": "100.0",<br>      "currency": "RUB",<br>      "currency_sign": "₽"<br>    },<br>    "pickup_code": "893422",<br>    "nonblocking_pickup_code": "ab#001",<br>    "should_notify_on_order_readiness": false,<br>    "code_verification_properties": {<br>      "code_verification_url": "https://www.example.com/"<br>    }<br>  },<br>  {<br>    "point_id": 6987,<br>    "visit_order": 1,<br>    "contact": {<br>      "name": "Морти",<br>      "phone": "+79099999998",<br>      "phone_additional_code": "602 17 500",<br>      "email": "example@yandex.ru"<br>    },<br>    "address": {<br>      "fullname": "Санкт-Петербург, Большая Монетная улица, 1к1А",<br>      "shortname": "Большая Монетная улица, 1к1А",<br>      "coordinates": [<br>        0.5,<br>        0.5<br>      ],<br>      "country": "Россия",<br>      "city": "Санкт-Петербург",<br>      "building_name": "БЦ На Большой Монетной",<br>      "street": "Большая Монетная улица",<br>      "building": "23к1А",<br>      "porch": "A",<br>      "sfloor": "1",<br>      "sflat": "1",<br>      "door_code": "169",<br>      "door_code_extra": "код на вход во двор #1234, код от апартаментов #4321",<br>      "doorbell_name": "Магидович",<br>      "comment": "Домофон не работает",<br>      "uri": "ymapsbm1://geo?ll=38.805%2C55.084",<br>      "description": "Санкт-Петербург, Россия"<br>    },<br>    "skip_confirmation": false,<br>    "leave_under_door": true,<br>    "meet_outside": true,<br>    "no_door_call": true,<br>    "type": "source",<br>    "buyout": {<br>      "payment_method": "card"<br>    },<br>    "payment_on_delivery": {<br>      "customer": {<br>        "inn": "3664069397",<br>        "email": "example@yandex.ru",<br>        "phone": "79000000000"<br>      },<br>      "payment_method": null<br>    },<br>    "external_order_id": "100",<br>    "external_order_cost": {<br>      "value": "100.0",<br>      "currency": "RUB",<br>      "currency_sign": "₽"<br>    },<br>    "pickup_code": "893422",<br>    "nonblocking_pickup_code": "ab#001",<br>    "should_notify_on_order_readiness": false,<br>    "code_verification_properties": {<br>      "code_verification_url": "https://www.example.com/"<br>    }<br>  }<br>]<br>``` |
| _auto\_accept_ | **Type**: boolean<br><br>Включить автоматическое подтверждение заявки после создания. Для использования данной опции требуется согласование менеджера |
| _callback\_properties_ | **Type**: [CallbackProperties](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-CallbackProperties)<br><br>Параметры уведомления сервера клиента о смене статуса заявки.<br><br>Уведомление представляет собой POST-запрос по указанному url, к  <br>которому будут добавлены информация о дате последнего изменения  <br>заявки и идентификатора заявки в виде  <br>'updated\_ts=&claim\_id=<id заявки>', то есть url вида  <br>'https://example.com/?my\_order\_id=123&' будет расширен до  <br>'https://example.com/?my\_order\_id=123&updated\_ts=...&claim\_id=...'.<br><br>Важно: параметры добавляются конкатенацией к callback\_url, то есть  <br>url вида 'https://example.com' превратится в невалидный  <br>'https://example.comupdated\_ts=...&claim\_id=...'.<br><br>Поддерживаются только http и https. При https ssl-сертификат должен  <br>быть выдан известным серверу центром сертификации.<br><br>К уведомлениям следует относиться как к push ahead of polling, как  <br>к ускорению получения информации о смене статусов. Сервер ожидает  <br>ответ 200, при таймаутах или любом другом ответе какое-то время  <br>будет пытаться доставить уведомление, после чего прекратит попытки.  <br>То есть для надежного получения статуса по заявке клиенту  <br>необходимо запрашивать информацию с помощью метода [claims/info](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsInfo).<br><br>Клиенту следует учесть, что ответ операции [claims/info](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsInfo) может  <br>содержать более старое состояние заявки (надо ориентироваться на  <br>значение поля updated\_ts). В этом случает необходимо повторить  <br>вызов операции через некоторое время (от 5 до 30 секунд).<br><br>**Example**<br><br>```<br>{<br>  "callback_url": "https://www.example.com/"<br>}<br>``` |
| _client\_requirements_ | **Type**: [ClientRequirements](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-ClientRequirements)<br><br>Требования от клиента, указанные при создании или редактировании заявки<br><br>**Example**<br><br>```<br>{<br>  "taxi_class": "express",<br>  "cargo_type": "lcv_m",<br>  "cargo_loaders": 0,<br>  "cargo_options": [<br>    "thermobag"<br>  ],<br>  "pro_courier": false,<br>  "assign_robot": true,<br>  "rental_duration": 0<br>}<br>``` |
| _comment_ | **Type**: string<br><br>Комментарий к заказу<br><br>_Max length:_ `7000`<br><br>_Example:_ `Ресторан` |
| _due_ | **Type**: [Due](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-Due)<br><br>Желаемое время прибытия исполнителя на точку А (source).  <br>В РФ отложить расчетное время прибытия исполнителя можно:  <br>\- на 30-240 минут от текущего момента – для тарифа `express`;  <br>\- на пять суток от текущего момента – для тарифа `cargo`.<br><br>Параметр не совместим с опциями замедления в тарифе `express` на территории РФ.  <br>Если этот параметр не задан, то запустится поиск исполнителя на ближайшее время.<br><br>_Example:_ `2020-01-01T00:00:00+00:00` |
| _emergency\_contact_ | **Type**: [ContactWithPhone](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-ContactWithPhone)<br><br>Информация о контактном лице с номером телефона<br><br>**Example**<br><br>```<br>{<br>  "name": "Рик",<br>  "phone": "+79826810246",<br>  "phone_additional_code": "602 17 500"<br>}<br>``` |
| _offer\_payload_ | **Type**: string<br><br>Payload, полученный методом [offers/calculate](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2OfferCalculate)<br><br>_Example:_ `asjdijasDKL;ahsdfljhlkjhasF;HS;Ldjf;ljloshf` |
| _optional\_return_ | **Type**: [OptionalReturn](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-OptionalReturn)<br><br>Отключить возврат товаров в случае отмены заказа.<br><br>Возможные значения:<br><br>  <br>\- true (курьер оставляет товар себе)  <br>\- false (по умолчанию, требуется вернуть товар)<br><br>_Default:_ `false`<br><br>_Example:_ `false` |
| _packages_ | **Type**: [Package](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-Package)\[\]<br><br>Список грузомест<br><br>_Min items:_ `1`<br><br>**Example**<br><br>```<br>[<br>  {<br>    "package_id": "a8e5b0e6-3d67-4d6f-89a5-3b6c1a0e4f5c",<br>    "package_type": "other",<br>    "package_code": "ab10702030/?",<br>    "pickup_point": 1,<br>    "dropoff_point": 2<br>  }<br>]<br>``` |
| _referral\_source_ | **Type**: string<br><br>Источник заявки (можно передать наименование CMS, из которой создается запрос)<br><br>_Example:_ `bitrix` |
| _same\_day\_data_ | **Type**: [SameDayData](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-SameDayData)<br><br>Признаки заказа "В течение дня"<br><br>Дополнительная информация для заявок `В течение дня`. Недоступно в России<br><br>**Example**<br><br>```<br>{<br>  "delivery_interval": {<br>    "from": "2020-01-01T07:00:00+00:00",<br>    "to": "2020-01-01T07:00:00+00:00"<br>  }<br>}<br>``` |
| _shipping\_document_ | **Type**: string<br><br>Сопроводительные документы<br><br>_Example:_ `example` |
| _skip\_act_ | **Type**: [SkipAct](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-SkipAct)<br><br>Не показывать акт приема-передачи<br><br>_Example:_ `false` |
| _skip\_client\_notify_ | **Type**: [SkipClientNotify](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-SkipClientNotify)<br><br>Не отправлять отправителю/получателю смс-уведомления,  <br>когда к нему направится курьер.<br><br>Значение по умолчанию: false (отправлять уведомления)<br><br>_Default:_ `false`<br><br>_Example:_ `false` |
| _skip\_door\_to\_door_ | **Type**: [SkipDoorToDoor](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-SkipDoorToDoor)<br><br>Отключить доставку до двери (выключить опцию "От двери до двери").<br><br>Возможные значения:<br><br>  <br>\- true (курьер доставит заказ только на улицу, до подъезда)  <br>\- false (курьер доставит до двери) - значение по умолчанию<br><br>_Default:_ `false`<br><br>_Example:_ `false` |
| _skip\_emergency\_notify_ | **Type**: [SkipEmergencyNotify](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-SkipEmergencyNotify)<br><br>Не отправлять уведомление запасному контактному лицу<br><br>Значение по умолчанию: false (отправлять уведомления)<br><br>_Default:_ `false`<br><br>_Example:_ `false` |

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

### Currency <a id="entity-Currency"></a>

Трехзначный код валюты, в которой ведется расчет

**Type**: string

_Min length:_ `3`

_Max length:_ `3`

_Example:_ `RUB`

### Money <a id="entity-Money"></a>

Стоимость доставки в формате десятичной дроби Decimal(18, 4)

**Type**: string

_Pattern:_ `^-?[0-9]{1,14}(\.[0-9]{0,4})?$`

_Example:_ `12.50`

### VatCodeStrApi <a id="entity-VatCodeStrApi"></a>

Ставка НДС. Возможные значения:
vat\_none - без НДС;
vat0 - нулевая ставка НДС (применяется в редких случаях);
vat10 - ставка НДС 10%;
vat20 - ставка НДС 20%.

**Type**: string

_Example:_ `vat_none`

### SupplierInn <a id="entity-SupplierInn"></a>

ИНН поставщика (10 или 12 цифр).

**Type**: string

_Pattern:_ `^[A-Z0-9\\-]+$`

_Example:_ `3664069397`

### ItemArticle <a id="entity-ItemArticle"></a>

Артикул товара.
Должен быть уникальным для товаров, передаваемых из одной точки.

**Type**: string

_Example:_ `20ML50OWKY4FC86`

### ItemMark <a id="entity-ItemMark"></a>

Уникальный код товара (КИЗ). Актуален для РФ.
Если товары имеют уникальный код, то на каждый товар необходимо создать отдельный блок

|     |     |
| --- | --- |
| **Name** | **Description** |
| _code_ (required) | **Type**: string<br><br>Код маркировки товара в соответствии с форматом kind<br><br>_Example:_ `444D00000000003741` |
| _kind_ (required) | **Type**: string<br><br>Тип маркировки.  <br>Возможные значения:<br><br>  <br>1\. compiled - уже разобранная марка с выделенным GTIN и Serial.  <br>Пример:  <br>\- 444D00000000003741  <br>2\. gs1\_data\_matrix\_base64 - код товара в формате GS1 Data Matrix,  <br>подлежащий маркировке средствами идентификации.  <br>Максимум 200 символов.  <br>Код товара необходимо передавать целиком,  <br>закодировав строку в формат base64.<br><br>_Example:_ `gs1_data_matrix_base64` |

**Example**

```
{
  "kind": "gs1_data_matrix_base64",
  "code": "444D00000000003741"
}
```

### ItemType <a id="entity-ItemType"></a>

Тип наименования: товар или услуга.
Значение по умолчанию: product

**Type**: string

_Enum:_ `product`, `service`

### ItemFiscalization <a id="entity-ItemFiscalization"></a>

Информация по фискализации (актуально для оплаты при получении)

|     |     |
| --- | --- |
| **Name** | **Description** |
| _article_ | **Type**: [ItemArticle](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-ItemArticle)<br><br>Артикул товара.  <br>Должен быть уникальным для товаров, передаваемых из одной точки.<br><br>_Example:_ `20ML50OWKY4FC86` |
| _excise_ | **Type**: [Money](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-Money)<br><br>Сумма акциза<br><br>Стоимость доставки в формате десятичной дроби Decimal(18, 4)<br><br>_Pattern:_ `^-?[0-9]{1,14}(\.[0-9]{0,4})?$`<br><br>_Example:_ `12.50` |
| _item\_type_ | **Type**: [ItemType](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-ItemType)<br><br>Тип наименования: товар или услуга.  <br>Значение по умолчанию: product<br><br>_Enum:_ `product`, `service` |
| _mark_ | **Type**: [ItemMark](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-ItemMark)<br><br>Уникальный код товара (КИЗ). Актуален для РФ.  <br>Если товары имеют уникальный код, то на каждый товар необходимо создать отдельный блок<br><br>**Example**<br><br>```<br>{<br>  "kind": "gs1_data_matrix_base64",<br>  "code": "444D00000000003741"<br>}<br>``` |
| _supplier\_inn_ | **Type**: [SupplierInn](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-SupplierInn)<br><br>ИНН поставщика (10 или 12 цифр).<br><br>_Pattern:_ `^[A-Z0-9\\-]+$`<br><br>_Example:_ `3664069397` |
| _vat\_code\_str_ | **Type**: [VatCodeStrApi](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-VatCodeStrApi)<br><br>Ставка НДС. Возможные значения:  <br>vat\_none - без НДС;  <br>vat0 - нулевая ставка НДС (применяется в редких случаях);  <br>vat10 - ставка НДС 10%;  <br>vat20 - ставка НДС 20%.<br><br>_Example:_ `vat_none` |

**Example**

```
{
  "excise": "12.50",
  "vat_code_str": "vat_none",
  "supplier_inn": "3664069397",
  "article": "20ML50OWKY4FC86",
  "mark": {
    "kind": "gs1_data_matrix_base64",
    "code": "444D00000000003741"
  },
  "item_type": "product"
}
```

### CargoItem <a id="entity-CargoItem"></a>

|     |     |
| --- | --- |
| **Name** | **Description** |
| _cost\_currency_ (required) | **Type**: [Currency](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-Currency)<br><br>Трехзначный код валюты, в которой ведется расчет<br><br>_Min length:_ `3`<br><br>_Max length:_ `3`<br><br>_Example:_ `RUB` |
| _cost\_value_ (required) | **Type**: string<br><br>Цена за единицу товара в валюте cost\_currency.  <br>Для страхования стоимости передайте фактическую цену груза<br><br>_Pattern:_ `^[0-9]+(\.[0-9]{1,2})?$`<br><br>_Example:_ `2.00` |
| _pickup\_point_ (required) | **Type**: integer<br><br>Идентификатор точки (int64), откуда нужно забрать  <br>товар. Отличается от идентификатора в заявке.<br><br>Может быть любым числом. Должен соответствовать значению route\_points\[\].point\_id  <br>у точки отправки |
| _quantity_ (required) | **Type**: integer<br><br>Количество товара в единицах (int64)<br><br>_Min value:_ `1` |
| _title_ (required) | **Type**: string<br><br>Наименование единицы товара<br><br>_Example:_ `Плюмбус` |
| _age\_restricted_ | **Type**: boolean<br><br>Нужно ли проверить возраст клиента при выдаче товара<br><br>_Default:_ `false` |
| _dropoff\_point_ | **Type**: integer<br><br>Идентификатор точки (int64), куда нужно доставить товар (отличается от идентификатора в заявке).<br><br>Может быть любым числом. Должен соответствовать значению route\_points\[\].point\_id у точки назначения |
| _droppof\_point_ | **Type**: integer<br><br>deprecated, use dropoff\_point |
| _extra\_id_ | **Type**: string<br><br>Краткий уникальный идентификатор товара (номер заказа в рамках заявки, как правило идентичен external\_order\_id)<br><br>_Max length:_ `512`<br><br>_Example:_ `БП-208` |
| _fiscalization_ | **Type**: [ItemFiscalization](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-ItemFiscalization)<br><br>Информация по фискализации (актуально для оплаты при получении)<br><br>**Example**<br><br>```<br>{<br>  "excise": "12.50",<br>  "vat_code_str": "vat_none",<br>  "supplier_inn": "3664069397",<br>  "article": "20ML50OWKY4FC86",<br>  "mark": {<br>    "kind": "gs1_data_matrix_base64",<br>    "code": "444D00000000003741"<br>  },<br>  "item_type": "product"<br>}<br>``` |
| _size_ | **Type**: [CargoItemSizes](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-CargoItemSizes)<br><br>Габариты товара в метрах. В полях следует передавать актуальные значения.<br><br>Если габариты не были переданы, заказ оформляется с учетом  <br>максимально допустимых габаритов для выбранного тарифа.<br><br>Если фактические характеристики товара превысят допустимые,  <br>курьер вправе отказаться от выполнения такого заказа на месте.  <br>В этом случае будет удержана стоимость подачи.<br><br>Курьер (courier): до 0.80 м × 0.50 м × 0.50 м  <br>Экспресс (express): до 1.00 м × 0.60 м × 0.50 м  <br>Грузовой (cargo):<br><br>  <br>\- Маленький кузов: до 1.70 м × 0.96 м × 0.90 м  <br>\- Средний кузов: до 2.60 м × 1.30 м × 1.50 м  <br>\- Большой кузов: до 3.80 м × 1.80 м × 1.80 м **Example**<br><br>```<br>{<br>  "length": 0.1,<br>  "width": 0.2,<br>  "height": 0.3<br>}<br>``` |
| _weight_ | **Type**: number<br><br>Вес единицы товара в кг. В поле следует передавать актуальные значения.<br><br>Если вес не был передан, заказ оформляется с учетом  <br>максимально допустимых габаритов для выбранного тарифа.<br><br>Если фактические характеристики товара превысят допустимые,  <br>курьер вправе отказаться от выполнения такого заказа на месте.  <br>В этом случае будет удержана стоимость подачи.<br><br>Курьер (courier): до 10 кг  <br>Экспресс (express): до 20 кг  <br>Грузовой (cargo):<br><br>  <br>\- Маленький кузов: до 300 кг  <br>\- Средний кузов: до 700 кг  <br>\- Большой кузов: до 1400 кг<br><br>_Min value:_ `0`<br><br>_Max value:_ `500000` |

**Example**

```
{
  "extra_id": "БП-208",
  "pickup_point": 1,
  "dropoff_point": 2,
  "droppof_point": 0,
  "title": "Плюмбус",
  "size": {
    "length": 0.1,
    "width": 0.2,
    "height": 0.3
  },
  "weight": 2,
  "cost_value": "2.00",
  "cost_currency": "RUB",
  "quantity": 1,
  "fiscalization": {
    "excise": "12.50",
    "vat_code_str": "vat_none",
    "supplier_inn": "3664069397",
    "article": "20ML50OWKY4FC86",
    "mark": {
      "kind": "gs1_data_matrix_base64",
      "code": "444D00000000003741"
    },
    "item_type": "product"
  },
  "age_restricted": false
}
```

### PackageId <a id="entity-PackageId"></a>

Уникальный в рамках заявки идентификатор грузоместа.
Генерируется клиентом перед отправкой запроса

**Type**: string<uuid>

_Example:_ `a8e5b0e6-3d67-4d6f-89a5-3b6c1a0e4f5c`

### PackageType <a id="entity-PackageType"></a>

Тип грузоместа.
Возможные значения:

-   package — пакет
-   box — коробка
-   bag — мешок
-   pallet — паллета
-   other — тип по умолчанию

**Type**: string

_Default:_ `other`

_Enum:_ `package`, `box`, `bag`, `pallet`, `other`

### PackageCode <a id="entity-PackageCode"></a>

Опциональный код/маркировка грузоместа.
Может содержать только латинские буквы, цифры и ASCII-спецсимволы.
Кириллица, emoji и другие не-ASCII символы не допускаются. Длина значения — от 1 до 30 символов.
Может повторяться в пределах заявки.

**Type**: string

_Min length:_ `1`

_Max length:_ `30`

_Pattern:_ `^[\x21-\x7E]+$`

_Example:_ `ab10702030/?`

### Package <a id="entity-Package"></a>

Грузоместо — отдельная физическая единица обработки и перевозки.
Содержит тип грузоместа, его идентификатор и опциональную маркировку. Связано с соответствующими точками

|     |     |
| --- | --- |
| **Name** | **Description** |
| _dropoff\_point_ (required) | **Type**: integer<br><br>Идентификатор точки, куда нужно доставить товар (отличается от идентификатора в заявке).  <br>Может быть любым числом. Должен соответствовать значению route\_points\[\].point\_id у точки назначения |
| _package\_id_ (required) | **Type**: [PackageId](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-PackageId)<br><br>Уникальный в рамках заявки идентификатор грузоместа.  <br>Генерируется клиентом перед отправкой запроса<br><br>_Example:_ `a8e5b0e6-3d67-4d6f-89a5-3b6c1a0e4f5c` |
| _pickup\_point_ (required) | **Type**: integer<br><br>Идентификатор точки, откуда нужно забрать товар (отличается от идентификатора в заявке).  <br>Может быть любым числом. Должен соответствовать значению route\_points\[\].point\_id у точки забора |
| _package\_code_ | **Type**: [PackageCode](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-PackageCode)<br><br>Опциональный код/маркировка грузоместа.  <br>Может содержать только латинские буквы, цифры и ASCII-спецсимволы.  <br>Кириллица, emoji и другие не-ASCII символы не допускаются. Длина значения — от 1 до 30 символов.  <br>Может повторяться в пределах заявки.<br><br>_Min length:_ `1`<br><br>_Max length:_ `30`<br><br>_Pattern:_ `^[\x21-\x7E]+$`<br><br>_Example:_ `ab10702030/?` |
| _package\_type_ | **Type**: [PackageType](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-PackageType)<br><br>Тип грузоместа.  <br>Возможные значения:<br><br>  <br>\- package — пакет  <br>\- box — коробка  <br>\- bag — мешок  <br>\- pallet — паллета  <br>\- other — тип по умолчанию<br><br>_Default:_ `other`<br><br>_Enum:_ `package`, `box`, `bag`, `pallet`, `other` |

**Example**

```
{
  "package_id": "a8e5b0e6-3d67-4d6f-89a5-3b6c1a0e4f5c",
  "package_type": "other",
  "package_code": "ab10702030/?",
  "pickup_point": 1,
  "dropoff_point": 2
}
```

### CreatedContactOnPoint <a id="entity-CreatedContactOnPoint"></a>

Информация о контактном лице

|     |     |
| --- | --- |
| **Name** | **Description** |
| _name_ (required) | **Type**: string<br><br>Имя контактного лица<br><br>_Example:_ `Морти` |
| _phone_ (required) | **Type**: string<br><br>Телефон контактного лица<br><br>_Max length:_ `30`<br><br>_Pattern:_ `[0-9 \\(\\)\\-\\+]+`<br><br>_Example:_ `+79099999998` |
| _email_ | **Type**: string<br><br>Email — обязательный параметр для точек с типом source и return<br><br>_Max length:_ `320`<br><br>_Pattern:_ `\S+@\S+.\S+`<br><br>_Example:_ `example@yandex.ru` |
| _phone\_additional\_code_ | **Type**: string<br><br>Добавочный номер для звонка курьера<br><br>_Example:_ `602 17 500` |

**Example**

```
{
  "name": "Морти",
  "phone": "+79099999998",
  "phone_additional_code": "602 17 500",
  "email": "example@yandex.ru"
}
```

### AddressFullname <a id="entity-AddressFullname"></a>

Полный адрес с указанием города, улицы и номера дома.
Номер квартиры, подъезда и этаж указывать не нужно.

**Type**: string

_Example:_ `Санкт-Петербург, Большая Монетная улица, 1к1А`

### CargoPointAddress <a id="entity-CargoPointAddress"></a>

Адрес точки

|     |     |
| --- | --- |
| **Name** | **Description** |
| _fullname_ (required) | **Type**: [AddressFullname](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-AddressFullname)<br><br>Полный адрес с указанием города, улицы и номера дома.  <br>Номер квартиры, подъезда и этаж указывать не нужно.<br><br>_Example:_ `Санкт-Петербург, Большая Монетная улица, 1к1А` |
| _building_ | **Type**: string<br><br>Строение<br><br>_Example:_ `23к1А` |
| _building\_name_ | **Type**: string<br><br>Название апартаментов (здания)<br><br>_Example:_ `БЦ На Большой Монетной` |
| _city_ | **Type**: string<br><br>Город<br><br>_Example:_ `Санкт-Петербург` |
| _comment_ | **Type**: string<br><br>Комментарий для курьера.<br><br>Для точки отправки используйте шаблон: "Доставка из магазина <>. Сообщите менеджеру, что заказ для Яндекс Доставки. Назовите номер заказа <> и заберите товар. Заказ оплачен безналично, при передаче заказа нельзя требовать с получателя деньги за доставку."<br><br>Для точек доставки в комментарии передавайте пожелания получателя. Например, "домофон не работает" / "шлагбаум закрыт, позвонить за 10 минут" / "не звонить, спит ребенок".<br><br>_Max length:_ `7000`<br><br>_Example:_ `Домофон не работает` |
| _coordinates_ | **Type**: number\[\]<br><br>Координаты точек в виде массива из двух вещественных чисел: долгота, широта — именно в таком порядке.  <br>Указываются округленные значения координат.<br><br>_Min items:_ `2`<br><br>_Max items:_ `2`<br><br>**Example**<br><br>```<br>[<br>  0.5,<br>  0.5<br>]<br>``` |
| _country_ | **Type**: string<br><br>Страна<br><br>_Example:_ `Россия` |
| _description_ | **Type**: string<br><br>Географическая область, уточняющая краткий адрес до глобального соответствия<br><br>_Example:_ `Санкт-Петербург, Россия` |
| _door\_code_ | **Type**: string<br><br>Код домофона<br><br>_Example:_ `169` |
| _door\_code\_extra_ | **Type**: string<br><br>Дополнительные указания по домофонам<br><br>_Example:_ `код на вход во двор #1234, код от апартаментов #4321` |
| _doorbell\_name_ | **Type**: string<br><br>Имя на дверном звонке<br><br>_Example:_ `Магидович` |
| _porch_ | **Type**: string<br><br>Подъезд (может быть A)<br><br>_Example:_ `A` |
| _sflat_ | **Type**: string<br><br>Квартира<br><br>_Example:_ `1` |
| _sfloor_ | **Type**: string<br><br>Этаж<br><br>_Example:_ `1` |
| _shortname_ | **Type**: string<br><br>Краткий адрес в пределах города (как на Таксометре)<br><br>_Example:_ `Большая Монетная улица, 1к1А` |
| _street_ | **Type**: string<br><br>Улица<br><br>_Example:_ `Большая Монетная улица` |
| _uri_ | **Type**: string<br><br>URI геообъекта на картах<br><br>_Example:_ `ymapsbm1://geo?ll=38.805%2C55.084` |

**Example**

```
{
  "fullname": "Санкт-Петербург, Большая Монетная улица, 1к1А",
  "shortname": "Большая Монетная улица, 1к1А",
  "coordinates": [
    0.5,
    0.5
  ],
  "country": "Россия",
  "city": "Санкт-Петербург",
  "building_name": "БЦ На Большой Монетной",
  "street": "Большая Монетная улица",
  "building": "23к1А",
  "porch": "A",
  "sfloor": "1",
  "sflat": "1",
  "door_code": "169",
  "door_code_extra": "код на вход во двор #1234, код от апартаментов #4321",
  "doorbell_name": "Магидович",
  "comment": "Домофон не работает",
  "uri": "ymapsbm1://geo?ll=38.805%2C55.084",
  "description": "Санкт-Петербург, Россия"
}
```

### CargoPointSkipConfirmation <a id="entity-CargoPointSkipConfirmation"></a>

Пропускать подтверждение по смс в данной точке

Значение по умолчанию: false (подтверждение требуется).

**Type**: boolean

_Default:_ `false`

### PointType <a id="entity-PointType"></a>

Тип точки:

-   source - точка отправления, где курьер забирает товар
-   destination – точки назначения, где курьер передает товар
-   return - точка возврата товара (добавляется автоматически и по умолчанию совпадает с точкой отправления, но также можно определить другую точку)

**Type**: string

_Enum:_ `source`, `destination`, `return`

### PaymentMethod <a id="entity-PaymentMethod"></a>

Выбранный тип оплаты.
card - оплата картой;
cash - оплата наличными (пока недоступна);

**Type**: string

_Enum:_ `card`, `cash`

### RequestBuyout <a id="entity-RequestBuyout"></a>

Информация по выкупу товара курьером в точке отправления (актуально, если для всех точек назначения в маршруте включена оплата при получении).

|     |     |
| --- | --- |
| **Name** | **Description** |
| _payment\_method_ (required) | **Type**: [PaymentMethod](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-PaymentMethod)<br><br>На данный момент актуально только cash<br><br>Выбранный тип оплаты.  <br>card - оплата картой;  <br>cash - оплата наличными (пока недоступна);<br><br>_Enum:_ `card`, `cash` |

**Example**

```
{
  "payment_method": "card"
}
```

### Inn <a id="entity-Inn"></a>

ИНН пользователя (10 или 12 цифр)

**Type**: string

_Pattern:_ `^[A-Z0-9\\-]+$`

_Example:_ `3664069397`

### RequestCustomerFiscalization <a id="entity-RequestCustomerFiscalization"></a>

Информация о получателе

|     |     |
| --- | --- |
| **Name** | **Description** |
| _email_ | **Type**: string<br><br>Электронная почта пользователя в формате example@yandex.ru.  <br>Если не указано, будет использована почта получателя из точки назначения<br><br>_Example:_ `example@yandex.ru` |
| _inn_ | **Type**: [Inn](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-Inn)<br><br>ИНН пользователя (10 или 12 цифр)<br><br>_Pattern:_ `^[A-Z0-9\\-]+$`<br><br>_Example:_ `3664069397` |
| _phone_ | **Type**: string<br><br>Телефон пользователя в формате +X XXX XXX XX XX. Если не указано, будет использован телефон получателя из точки<br><br>_Example:_ `79000000000` |

**Example**

```
{
  "inn": "3664069397",
  "email": "example@yandex.ru",
  "phone": "79000000000"
}
```

### CreateRequestPaymentOnDelivery <a id="entity-CreateRequestPaymentOnDelivery"></a>

Информация по оплате при получении (актуально для оплаты при получении)

|     |     |
| --- | --- |
| **Name** | **Description** |
| _payment\_method_ (required) | **Type**: [PaymentMethod](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-PaymentMethod)<br><br>Выбранный тип оплаты.  <br>card - оплата картой;  <br>cash - оплата наличными (пока недоступна);<br><br>_Enum:_ `card`, `cash` |
| _customer_ | **Type**: [RequestCustomerFiscalization](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-RequestCustomerFiscalization)<br><br>Информация о получателе<br><br>**Example**<br><br>```<br>{<br>  "inn": "3664069397",<br>  "email": "example@yandex.ru",<br>  "phone": "79000000000"<br>}<br>``` |

**Example**

```
{
  "customer": {
    "inn": "3664069397",
    "email": "example@yandex.ru",
    "phone": "79000000000"
  },
  "payment_method": "card"
}
```

### ExternalOrderCost <a id="entity-ExternalOrderCost"></a>

Стоимость внешнего заказа, привязанного к точке

|     |     |
| --- | --- |
| **Name** | **Description** |
| _currency_ (required) | **Type**: string<br><br>Валюта<br><br>_Example:_ `RUB` |
| _currency\_sign_ (required) | **Type**: string<br><br>Знак валюты<br><br>_Example:_ `₽` |
| _value_ (required) | **Type**: string<br><br>Стоимость<br><br>_Example:_ `100.0` |

**Example**

```
{
  "value": "100.0",
  "currency": "RUB",
  "currency_sign": "₽"
}
```

### PickupCode <a id="entity-PickupCode"></a>

Код выдачи заказа курьеру.
Курьеру потребуется ввести этот код, чтобы подтвердить, что он забрал заказ.
Для этого необходимо, чтобы ваши сотрудники на точке выдачи имели возможность назвать этот код курьеру.
Актуально для точки с типом 'source'.
Формат кода: 6 цифр
|
Код выдачи товара (ПВЗ)

**Type**: string

_Example:_ `893422`

### NonblockingPickupCode <a id="entity-NonblockingPickupCode"></a>

Неблокирующий код выдачи заказа курьеру. Актуально для точки с типом 'source'. Разрешены цифры, латиница и некоторые специальные символы.

**Type**: string

_Min length:_ `4`

_Max length:_ `6`

_Example:_ `ab#001`

### CodeVerificationProperties <a id="entity-CodeVerificationProperties"></a>

Параметры проверки кода во внешнем сервисе.

Если поле заполнено, то проверка кода представляет собой запрос по указанному url. Для корректной
работы проверки кода для этого url необходимо поддержать следующее api:

```
post:
    description: |
      bearerAuth: содержит JWT с зашифрованным payload:
        type: object
          required:
            - iss
            - sub
            - exp
            - claim_id
            - point_id
          properties:
            claim_id:
              type: string
              description: Уникальный идентификатор заявки
              example: "123456789"
            point_id:
              type: string
              description: Идентификатор точки
              example: "123456789"
            iss:
              type: string
              description: Издатель токена
              enum: [dostavka.yandex.ru]
            sub:
              type: string
              description: Сущность, для которой токен выписан
              example: "example.com"
            exp:
              type: string
              format: date-time
              description: Время истечения срока жизни токена
      расшифровывать информацию следует с помощью публичных токенов доступных по ссылке https://dostavka.yandex.ru/.well-known/jwks.json и традиционных библиотек для JWT
    security:
      - bearerAuth: []
    requestBody:
      required: true
      content:
        application/json:
            type: object
            required:
              - verification_code
            properties:
              verification_code:
                type: string
                description: Код подтверждения для сборочного задания
                example: "8392"
    responses:
      '200':
        description: Результат обработки кода подтверждения
        content:
          application/json:
            type: object
            required:
              - status
            properties:
              status:
                type: string
                description: |
                Результат обработки кода подтверждения

                Описание значений:
                  - `in_progress` — проверка кода выполняется
                  - `completed` — код подтвержден успешно
                  - `invalid_code` — передан неверный код подтверждения
                enum:
                  - in_progress
                  - completed
                  - invalid_code
                example: "in_progress"
      '400':
        description: Некорректный формат запроса
      '401':
        description: Отсутствует или невалидный JWT
      '403':
        description: Ошибка проверки подписи JWT
      '404':
        description: Заявка не найдена
        content:
          application/json:
            type: object
            required:
              - status
            properties:
              status:
                type: string
                enum: [not_found]
                example: "not_found"
      '409':
        description: Конфликт при обработке запроса
        content:
          application/json:
            type: object
            required:
              - status
            properties:
              status:
                type: string
                description: |
                  Код причины конфликта:
                  - `b2b_problem` — проблема с доступом или токеном у b2b клиента(access_denied, token_problem)
                  - `state_mismatch` — операция невозможна для текущего статуса заявки
                  - `operation_timeout` — не удалось обработать запрос подтверждения кода в течение 60 секунд (параметр конфигурируется) из-за превышения лимитов (rate limit) на выполнение запросов.
                enum:
                  - b2b_problem
                  - state_mismatch
                  - operation_timeout
                example: "b2b_problem"
              message:
                type: string
                description: |
                  человекочитаемое сообщение об ошибке
      '500':
        description: Внутренняя ошибка сервиса
```

Поддерживаются только https, ssl-сертификат должен
быть выдан известным серверу центром сертификации.

|     |     |
| --- | --- |
| **Name** | **Description** |
| _code\_verification\_url_ (required) | **Type**: string<br><br>URL, который вызывается при проверке кода получателя.<br><br>_Pattern:_ `^https?:.*`<br><br>_Example:_ `https://www.example.com/` |

**Example**

```
{
  "code_verification_url": "https://www.example.com/"
}
```

### RequestPoint <a id="entity-RequestPoint"></a>

|     |     |
| --- | --- |
| **Name** | **Description** |
| _address_ (required) | **Type**: [CargoPointAddress](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-CargoPointAddress)<br><br>Адрес точки<br><br>**Example**<br><br>```<br>{<br>  "fullname": "Санкт-Петербург, Большая Монетная улица, 1к1А",<br>  "shortname": "Большая Монетная улица, 1к1А",<br>  "coordinates": [<br>    0.5,<br>    0.5<br>  ],<br>  "country": "Россия",<br>  "city": "Санкт-Петербург",<br>  "building_name": "БЦ На Большой Монетной",<br>  "street": "Большая Монетная улица",<br>  "building": "23к1А",<br>  "porch": "A",<br>  "sfloor": "1",<br>  "sflat": "1",<br>  "door_code": "169",<br>  "door_code_extra": "код на вход во двор #1234, код от апартаментов #4321",<br>  "doorbell_name": "Магидович",<br>  "comment": "Домофон не работает",<br>  "uri": "ymapsbm1://geo?ll=38.805%2C55.084",<br>  "description": "Санкт-Петербург, Россия"<br>}<br>``` |
| _contact_ (required) | **Type**: [CreatedContactOnPoint](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-CreatedContactOnPoint)<br><br>Информация о контактном лице<br><br>**Example**<br><br>```<br>{<br>  "name": "Морти",<br>  "phone": "+79099999998",<br>  "phone_additional_code": "602 17 500",<br>  "email": "example@yandex.ru"<br>}<br>``` |
| _point\_id_ (required) | **Type**: integer<br><br>Целочисленный идентификатор точки (int64), уникальна в рамках создания заявки |
| _type_ (required) | **Type**: [PointType](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-PointType)<br><br>Тип точки:<br><br>  <br>\- source - точка отправления, где курьер забирает товар  <br>\- destination – точки назначения, где курьер передает товар  <br>\- return - точка возврата товара (добавляется автоматически и по умолчанию совпадает с точкой отправления, но также можно определить другую точку)<br><br>_Enum:_ `source`, `destination`, `return` |
| _visit\_order_ (required) | **Type**: integer<br><br>Порядок посещения точки (нумерация начинается с 1) (int64) |
| _buyout_ | **Type**: [RequestBuyout](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-RequestBuyout)<br><br>Информация по выкупу товара курьером в точке отправления (актуально, если для всех точек назначения в маршруте включена оплата при получении).<br><br>**Example**<br><br>```<br>{<br>  "payment_method": "card"<br>}<br>``` |
| _code\_verification\_properties_ | **Type**: [CodeVerificationProperties](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-CodeVerificationProperties)<br><br>Параметры проверки кода во внешнем сервисе.<br><br>Если поле заполнено, то проверка кода представляет собой запрос по указанному url. Для корректной  <br>работы проверки кода для этого url необходимо поддержать следующее api:<br><br>```<br>post:<br>    description: &#124;<br>      bearerAuth: содержит JWT с зашифрованным payload:<br>        type: object<br>          required:<br>            - iss<br>            - sub<br>            - exp<br>            - claim_id<br>            - point_id<br>          properties:<br>            claim_id:<br>              type: string<br>              description: Уникальный идентификатор заявки<br>              example: "123456789"<br>            point_id:<br>              type: string<br>              description: Идентификатор точки<br>              example: "123456789"<br>            iss:<br>              type: string<br>              description: Издатель токена<br>              enum: [dostavka.yandex.ru]<br>            sub:<br>              type: string<br>              description: Сущность, для которой токен выписан<br>              example: "example.com"<br>            exp:<br>              type: string<br>              format: date-time<br>              description: Время истечения срока жизни токена<br>      расшифровывать информацию следует с помощью публичных токенов доступных по ссылке https://dostavka.yandex.ru/.well-known/jwks.json и традиционных библиотек для JWT<br>    security:<br>      - bearerAuth: []<br>    requestBody:<br>      required: true<br>      content:<br>        application/json:<br>            type: object<br>            required:<br>              - verification_code<br>            properties:<br>              verification_code:<br>                type: string<br>                description: Код подтверждения для сборочного задания<br>                example: "8392"<br>    responses:<br>      '200':<br>        description: Результат обработки кода подтверждения<br>        content:<br>          application/json:<br>            type: object<br>            required:<br>              - status<br>            properties:<br>              status:<br>                type: string<br>                description: &#124;<br>                Результат обработки кода подтверждения<br><br>                Описание значений:<br>                  - `in_progress` — проверка кода выполняется<br>                  - `completed` — код подтвержден успешно<br>                  - `invalid_code` — передан неверный код подтверждения<br>                enum:<br>                  - in_progress<br>                  - completed<br>                  - invalid_code<br>                example: "in_progress"<br>      '400':<br>        description: Некорректный формат запроса<br>      '401':<br>        description: Отсутствует или невалидный JWT<br>      '403':<br>        description: Ошибка проверки подписи JWT<br>      '404':<br>        description: Заявка не найдена<br>        content:<br>          application/json:<br>            type: object<br>            required:<br>              - status<br>            properties:<br>              status:<br>                type: string<br>                enum: [not_found]<br>                example: "not_found"<br>      '409':<br>        description: Конфликт при обработке запроса<br>        content:<br>          application/json:<br>            type: object<br>            required:<br>              - status<br>            properties:<br>              status:<br>                type: string<br>                description: &#124;<br>                  Код причины конфликта:<br>                  - `b2b_problem` — проблема с доступом или токеном у b2b клиента(access_denied, token_problem)<br>                  - `state_mismatch` — операция невозможна для текущего статуса заявки<br>                  - `operation_timeout` — не удалось обработать запрос подтверждения кода в течение 60 секунд (параметр конфигурируется) из-за превышения лимитов (rate limit) на выполнение запросов.<br>                enum:<br>                  - b2b_problem<br>                  - state_mismatch<br>                  - operation_timeout<br>                example: "b2b_problem"<br>              message:<br>                type: string<br>                description: &#124;<br>                  человекочитаемое сообщение об ошибке<br>      '500':<br>        description: Внутренняя ошибка сервиса<br>```<br><br>Поддерживаются только https, ssl-сертификат должен  <br>быть выдан известным серверу центром сертификации.<br><br>**Example**<br><br>```<br>{<br>  "code_verification_url": "https://www.example.com/"<br>}<br>``` |
| _external\_order\_cost_ | **Type**: [ExternalOrderCost](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-ExternalOrderCost)<br><br>Стоимость внешнего заказа, привязанного к точке<br><br>**Example**<br><br>```<br>{<br>  "value": "100.0",<br>  "currency": "RUB",<br>  "currency_sign": "₽"<br>}<br>``` |
| _external\_order\_id_ | **Type**: string<br><br>Номер заказа из системы клиента.  <br>Передается для точки с типом destination<br><br>_Max length:_ `512`<br><br>_Example:_ `100` |
| _leave\_under\_door_ | **Type**: boolean<br><br>Оставить заказ у двери |
| _meet\_outside_ | **Type**: boolean<br><br>Курьера встретят на улице у подъезда |
| _no\_door\_call_ | **Type**: boolean<br><br>Не звонить в дверь |
| _nonblocking\_pickup\_code_ | **Type**: [NonblockingPickupCode](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-NonblockingPickupCode)<br><br>Неблокирующий код выдачи заказа курьеру. Актуально для точки с типом 'source'. Разрешены цифры, латиница и некоторые специальные символы.<br><br>_Min length:_ `4`<br><br>_Max length:_ `6`<br><br>_Example:_ `ab#001` |
| _payment\_on\_delivery_ | **Type**: [CreateRequestPaymentOnDelivery](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-CreateRequestPaymentOnDelivery)<br><br>Информация по оплате при получении (актуально для оплаты при получении)<br><br>**Example**<br><br>```<br>{<br>  "customer": {<br>    "inn": "3664069397",<br>    "email": "example@yandex.ru",<br>    "phone": "79000000000"<br>  },<br>  "payment_method": "card"<br>}<br>``` |
| _pickup\_code_ | **Type**: [PickupCode](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-PickupCode)<br><br>Код выдачи заказа курьеру.  <br>Курьеру потребуется ввести этот код, чтобы подтвердить, что он забрал заказ.  <br>Для этого необходимо, чтобы ваши сотрудники на точке выдачи имели возможность назвать этот код курьеру.  <br>Актуально для точки с типом 'source'.  <br>Формат кода: 6 цифр  <br>\|  <br>Код выдачи товара (ПВЗ)<br><br>_Example:_ `893422` |
| _should\_notify\_on\_order\_readiness_ | **Type**: boolean<br><br>Укажите этот параметр равным `true`, чтобы использовать метод [Готовность заказа к выдаче](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsSetPointReady) для уведомления курьера о готовности заказа.  <br>Доступно только для точки отправления<br><br>_Default:_ `false` |
| _skip\_confirmation_ | **Type**: [CargoPointSkipConfirmation](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-CargoPointSkipConfirmation)<br><br>Пропускать подтверждение по смс в данной точке<br><br>Значение по умолчанию: false (подтверждение требуется).<br><br>_Default:_ `false`<br><br>_Example:_ `false` |

**Example**

```
{
  "point_id": 6987,
  "visit_order": 1,
  "contact": {
    "name": "Морти",
    "phone": "+79099999998",
    "phone_additional_code": "602 17 500",
    "email": "example@yandex.ru"
  },
  "address": {
    "fullname": "Санкт-Петербург, Большая Монетная улица, 1к1А",
    "shortname": "Большая Монетная улица, 1к1А",
    "coordinates": [
      0.5,
      0.5
    ],
    "country": "Россия",
    "city": "Санкт-Петербург",
    "building_name": "БЦ На Большой Монетной",
    "street": "Большая Монетная улица",
    "building": "23к1А",
    "porch": "A",
    "sfloor": "1",
    "sflat": "1",
    "door_code": "169",
    "door_code_extra": "код на вход во двор #1234, код от апартаментов #4321",
    "doorbell_name": "Магидович",
    "comment": "Домофон не работает",
    "uri": "ymapsbm1://geo?ll=38.805%2C55.084",
    "description": "Санкт-Петербург, Россия"
  },
  "skip_confirmation": false,
  "leave_under_door": true,
  "meet_outside": true,
  "no_door_call": true,
  "type": "source",
  "buyout": {
    "payment_method": "card"
  },
  "payment_on_delivery": {
    "customer": {
      "inn": "3664069397",
      "email": "example@yandex.ru",
      "phone": "79000000000"
    },
    "payment_method": null
  },
  "external_order_id": "100",
  "external_order_cost": {
    "value": "100.0",
    "currency": "RUB",
    "currency_sign": "₽"
  },
  "pickup_code": "893422",
  "nonblocking_pickup_code": "ab#001",
  "should_notify_on_order_readiness": false,
  "code_verification_properties": {
    "code_verification_url": "https://www.example.com/"
  }
}
```

### RequestCargoRoutePoints <a id="entity-RequestCargoRoutePoints"></a>

Информация по точкам маршрута

**Type**: [RequestPoint](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-RequestPoint)\[\]

_Min items:_ `2`

_Max items:_ `300`

**Example**

```
[
  {
    "point_id": 6987,
    "visit_order": 1,
    "contact": {
      "name": "Морти",
      "phone": "+79099999998",
      "phone_additional_code": "602 17 500",
      "email": "example@yandex.ru"
    },
    "address": {
      "fullname": "Санкт-Петербург, Большая Монетная улица, 1к1А",
      "shortname": "Большая Монетная улица, 1к1А",
      "coordinates": [
        0.5,
        0.5
      ],
      "country": "Россия",
      "city": "Санкт-Петербург",
      "building_name": "БЦ На Большой Монетной",
      "street": "Большая Монетная улица",
      "building": "23к1А",
      "porch": "A",
      "sfloor": "1",
      "sflat": "1",
      "door_code": "169",
      "door_code_extra": "код на вход во двор #1234, код от апартаментов #4321",
      "doorbell_name": "Магидович",
      "comment": "Домофон не работает",
      "uri": "ymapsbm1://geo?ll=38.805%2C55.084",
      "description": "Санкт-Петербург, Россия"
    },
    "skip_confirmation": false,
    "leave_under_door": true,
    "meet_outside": true,
    "no_door_call": true,
    "type": "source",
    "buyout": {
      "payment_method": "card"
    },
    "payment_on_delivery": {
      "customer": {
        "inn": "3664069397",
        "email": "example@yandex.ru",
        "phone": "79000000000"
      },
      "payment_method": null
    },
    "external_order_id": "100",
    "external_order_cost": {
      "value": "100.0",
      "currency": "RUB",
      "currency_sign": "₽"
    },
    "pickup_code": "893422",
    "nonblocking_pickup_code": "ab#001",
    "should_notify_on_order_readiness": false,
    "code_verification_properties": {
      "code_verification_url": "https://www.example.com/"
    }
  },
  {
    "point_id": 6987,
    "visit_order": 1,
    "contact": {
      "name": "Морти",
      "phone": "+79099999998",
      "phone_additional_code": "602 17 500",
      "email": "example@yandex.ru"
    },
    "address": {
      "fullname": "Санкт-Петербург, Большая Монетная улица, 1к1А",
      "shortname": "Большая Монетная улица, 1к1А",
      "coordinates": [
        0.5,
        0.5
      ],
      "country": "Россия",
      "city": "Санкт-Петербург",
      "building_name": "БЦ На Большой Монетной",
      "street": "Большая Монетная улица",
      "building": "23к1А",
      "porch": "A",
      "sfloor": "1",
      "sflat": "1",
      "door_code": "169",
      "door_code_extra": "код на вход во двор #1234, код от апартаментов #4321",
      "doorbell_name": "Магидович",
      "comment": "Домофон не работает",
      "uri": "ymapsbm1://geo?ll=38.805%2C55.084",
      "description": "Санкт-Петербург, Россия"
    },
    "skip_confirmation": false,
    "leave_under_door": true,
    "meet_outside": true,
    "no_door_call": true,
    "type": "source",
    "buyout": {
      "payment_method": "card"
    },
    "payment_on_delivery": {
      "customer": {
        "inn": "3664069397",
        "email": "example@yandex.ru",
        "phone": "79000000000"
      },
      "payment_method": null
    },
    "external_order_id": "100",
    "external_order_cost": {
      "value": "100.0",
      "currency": "RUB",
      "currency_sign": "₽"
    },
    "pickup_code": "893422",
    "nonblocking_pickup_code": "ab#001",
    "should_notify_on_order_readiness": false,
    "code_verification_properties": {
      "code_verification_url": "https://www.example.com/"
    }
  }
]
```

### ContactWithPhone <a id="entity-ContactWithPhone"></a>

Информация о контактном лице с номером телефона

|     |     |
| --- | --- |
| **Name** | **Description** |
| _name_ (required) | **Type**: string<br><br>Имя контактного лица<br><br>_Example:_ `Рик` |
| _phone_ (required) | **Type**: string<br><br>Телефон контактного лица<br><br>_Example:_ `+79826810246` |
| _phone\_additional\_code_ | **Type**: string<br><br>Добавочный номер для звонка курьера<br><br>_Example:_ `602 17 500` |

**Example**

```
{
  "name": "Рик",
  "phone": "+79826810246",
  "phone_additional_code": "602 17 500"
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

### ClientRequirements <a id="entity-ClientRequirements"></a>

Требования от клиента, указанные при создании или редактировании заявки

|     |     |
| --- | --- |
| **Name** | **Description** |
| _taxi\_class_ (required) | **Type**: string<br><br>Тариф доставки. Возможные значения: courier, express, cargo, sdd\_multislot<br><br>_Example:_ `express` |
| _assign\_robot_ | **Type**: boolean<br><br>Разрешить выполнение заказа роботом |
| _cargo\_loaders_ | **Type**: integer<br><br>Число грузчиков для грузового тарифа.  <br>Возможные значения: 0, 1, 2.<br><br>Точный список возможных значений для конкретной точки  <br>уточняйте с помощью метода получения тарифов [tariffs](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2Tariffs).<br><br>_Min value:_ `0` |
| _cargo\_options_ | **Type**: [CargoOptions](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-CargoOptions)<br><br>Список дополнительных опций тарифа.<br><br>Возможные отдельные опции:<br><br>  <br>\- auto\_courier (курьер только на автомобиле)  <br>\- thermobag (курьер с термосумкой)<br><br>Пример списка опций: \["auto\_courier"\].<br><br>Точный список возможных значений для конкретной геоточки  <br>уточните с помощью метода получения тарифов [tariffs](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2Tariffs)<br><br>**Example**<br><br>```<br>[<br>  "thermobag"<br>]<br>``` |
| _cargo\_type_ | **Type**: [CargoType](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-CargoType)<br><br>Тип (размер) кузова для грузового тарифа.  <br>Возможные значения:<br><br>  <br>\- van ("Маленький кузов")  <br>\- lcv\_m ("Средний кузов")  <br>\- lcv\_l ("Большой кузов")  <br>\- lcv\_xl ("Кузов XL")  <br>Точный список возможных значений для конкретной геоточки уточняйте с помощью метода получения тарифов [tariffs](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2Tariffs)<br><br>_Enum:_ `van`, `lcv_m`, `lcv_l`, `lcv_xl` |
| _pro\_courier_ | **Type**: boolean<br><br>Включить опцию "Профи" для тарифов "Экспресс" и "Курьер".  <br>Поиск исполнителя будет происходить только среди опытных курьеров. |
| _rental\_duration_ | **Type**: integer<br><br>Время аренды, которое планирует клиент. Указывается в минутах.  <br>Указывайте этот параметр только для почасового тарифа |

**Example**

```
{
  "taxi_class": "express",
  "cargo_type": "lcv_m",
  "cargo_loaders": 0,
  "cargo_options": [
    "thermobag"
  ],
  "pro_courier": false,
  "assign_robot": true,
  "rental_duration": 0
}
```

### CallbackProperties <a id="entity-CallbackProperties"></a>

Параметры уведомления сервера клиента о смене статуса заявки.

Уведомление представляет собой POST-запрос по указанному url, к
которому будут добавлены информация о дате последнего изменения
заявки и идентификатора заявки в виде
'updated\_ts=&claim\_id=<id заявки>', то есть url вида
'https://example.com/?my\_order\_id=123&' будет расширен до
'https://example.com/?my\_order\_id=123&updated\_ts=...&claim\_id=...'.

Важно: параметры добавляются конкатенацией к callback\_url, то есть
url вида 'https://example.com' превратится в невалидный
'https://example.comupdated\_ts=...&claim\_id=...'.

Поддерживаются только http и https. При https ssl-сертификат должен
быть выдан известным серверу центром сертификации.

К уведомлениям следует относиться как к push ahead of polling, как
к ускорению получения информации о смене статусов. Сервер ожидает
ответ 200, при таймаутах или любом другом ответе какое-то время
будет пытаться доставить уведомление, после чего прекратит попытки.
То есть для надежного получения статуса по заявке клиенту
необходимо запрашивать информацию с помощью метода [claims/info](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsInfo).

Клиенту следует учесть, что ответ операции [claims/info](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsInfo) может
содержать более старое состояние заявки (надо ориентироваться на
значение поля updated\_ts). В этом случает необходимо повторить
вызов операции через некоторое время (от 5 до 30 секунд).

|     |     |
| --- | --- |
| **Name** | **Description** |
| _callback\_url_ (required) | **Type**: string<br><br>URL, который вызывается при смене статусов по заявке.<br><br>Этот механизм устарел и может быть ненадежен, рекомендуем использовать в связке с [claims/journal](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsJournal)<br><br>_Pattern:_ `^https?:.*`<br><br>_Example:_ `https://www.example.com/` |

**Example**

```
{
  "callback_url": "https://www.example.com/"
}
```

### SkipDoorToDoor <a id="entity-SkipDoorToDoor"></a>

Отключить доставку до двери (выключить опцию "От двери до двери").

Возможные значения:

-   true (курьер доставит заказ только на улицу, до подъезда)
-   false (курьер доставит до двери) - значение по умолчанию

**Type**: boolean

_Default:_ `false`

### SkipClientNotify <a id="entity-SkipClientNotify"></a>

Не отправлять отправителю/получателю смс-уведомления,
когда к нему направится курьер.

Значение по умолчанию: false (отправлять уведомления)

**Type**: boolean

_Default:_ `false`

### SkipEmergencyNotify <a id="entity-SkipEmergencyNotify"></a>

Не отправлять уведомление запасному контактному лицу

Значение по умолчанию: false (отправлять уведомления)

**Type**: boolean

_Default:_ `false`

### SkipAct <a id="entity-SkipAct"></a>

Не показывать акт приема-передачи

**Type**: boolean

### OptionalReturn <a id="entity-OptionalReturn"></a>

Отключить возврат товаров в случае отмены заказа.

Возможные значения:

-   true (курьер оставляет товар себе)
-   false (по умолчанию, требуется вернуть товар)

**Type**: boolean

_Default:_ `false`

### Due <a id="entity-Due"></a>

Желаемое время прибытия исполнителя на точку А (source).
В РФ отложить расчетное время прибытия исполнителя можно:
\- на 30-240 минут от текущего момента – для тарифа `express`;
\- на пять суток от текущего момента – для тарифа `cargo`.

Параметр не совместим с опциями замедления в тарифе `express` на территории РФ.
Если этот параметр не задан, то запустится поиск исполнителя на ближайшее время.

**Type**: string<date-time>

_Example:_ `2020-01-01T00:00:00+00:00`

### PerformerGroupRequirement <a id="entity-PerformerGroupRequirement"></a>

Информация о логистической группе

|     |     |
| --- | --- |
| **Name** | **Description** |
| _type_ (required) | **Type**: string<br><br>_Example:_ `performer_group` |
| _logistic\_group_ | **Type**: string<br><br>_Example:_ `ya_eats_group` |
| _meta\_group_ | **Type**: string<br><br>_Example:_ `lavka` |
| _performers\_restriction\_type_ | **Type**: string<br><br>_Example:_ `group_only &#124; no_restrictions &#124; time_expanding_group` |
| _shift\_type_ | **Type**: string<br><br>_Enum:_ `eats`, `grocery` |
| _time\_expanding\_min_ | **Type**: integer<br><br>Количество минут до включения флага allow\_classes (int64)<br><br>_Min value:_ `0` |

**Example**

```
{
  "type": "performer_group",
  "logistic_group": "ya_eats_group",
  "meta_group": "lavka",
  "performers_restriction_type": "group_only | no_restrictions | time_expanding_group",
  "shift_type": "eats",
  "time_expanding_min": 10
}
```

### ClaimRequirements <a id="entity-ClaimRequirements"></a>

Список дополнительных требований к заявке

**Type**: [PerformerGroupRequirement](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-PerformerGroupRequirement)\[\]

**Example**

```
[
  {
    "type": "performer_group",
    "logistic_group": "ya_eats_group",
    "meta_group": "lavka",
    "performers_restriction_type": "group_only | no_restrictions | time_expanding_group",
    "shift_type": "eats",
    "time_expanding_min": 10
  }
]
```

### TaxiCorpInfo <a id="entity-TaxiCorpInfo"></a>

Доп информация о такси пользователе

|     |     |
| --- | --- |
| **Name** | **Description** |
| _department\_ids_ | **Type**: string\[\]<br><br>**Example**<br><br>```<br>[<br>  "example"<br>]<br>``` |
| _user\_id_ | **Type**: string<br><br>_Example:_ `example` |

**Example**

```
{
  "user_id": "example",
  "department_ids": [
    "example"
  ]
}
```

### PaymentComplement <a id="entity-PaymentComplement"></a>

|     |     |
| --- | --- |
| **Name** | **Description** |
| _type_ (required) | **Type**: string<br><br>Тип композитного способа оплаты.<br><br>_Example:_ `example` |
| _id_ | **Type**: string<br><br>Идентификатор композитного способа оплаты.<br><br>_Example:_ `example` |

**Example**

```
{
  "type": "example",
  "id": "example"
}
```

### ClaimFeature <a id="entity-ClaimFeature"></a>

Дополнительное свойство заявки

|     |     |
| --- | --- |
| **Name** | **Description** |
| _id_ (required) | **Type**: string<br><br>Уникальный идентификатор свойства заявки<br><br>_Example:_ `example` |
| _is\_inner_ | **Type**: boolean |

**Example**

```
{
  "id": "example",
  "is_inner": true
}
```

### SameDayData <a id="entity-SameDayData"></a>

Дополнительная информация для заявок `В течение дня`. Недоступно в России

**Name**

**Description**

_delivery\_interval_ (required)

**Type**: object

|     |     |
| --- | --- |
| _from_ (required) | **Type**: string<date-time><br><br>Начало интервала<br><br>_Example:_ `2020-01-01T07:00:00+00:00` |
| _to_ (required) | **Type**: string<date-time><br><br>Окончание интервала (дата и время)<br><br>_Example:_ `2020-01-01T07:00:00+00:00` |

Интервал забора и доставки заказа

**Example**

```
{
  "from": "2020-01-01T07:00:00+00:00",
  "to": "2020-01-01T07:00:00+00:00"
}
```
**Example**

```
{
  "delivery_interval": {
    "from": "2020-01-01T07:00:00+00:00",
    "to": "2020-01-01T07:00:00+00:00"
  }
}
```

## Responses <a id="responses"></a>

## 200 OK <a id="200-ok"></a>

Ок, заявка создана

### Body <a id="body1"></a>

**application/json**

```
{
  "id": "741cedf82cd464fa6fa16d87155c636",
  "corp_client_id": "cd8cc018bde34597932855e3cfdce927",
  "items": [
    {
      "extra_id": "БП-208",
      "pickup_point": 1,
      "dropoff_point": 2,
      "droppof_point": 0,
      "title": "Плюмбус",
      "size": {
        "length": 0.1,
        "width": 0.2,
        "height": 0.3
      },
      "weight": 2,
      "cost_value": "2.00",
      "cost_currency": "RUB",
      "quantity": 1,
      "fiscalization": {
        "excise": "12.50",
        "vat_code_str": "vat_none",
        "supplier_inn": "3664069397",
        "article": "20ML50OWKY4FC86",
        "mark": {
          "kind": "gs1_data_matrix_base64",
          "code": "444D00000000003741"
        },
        "item_type": "product"
      },
      "age_restricted": false
    }
  ],
  "packages": [
    {
      "package_id": "a8e5b0e6-3d67-4d6f-89a5-3b6c1a0e4f5c",
      "package_type": "other",
      "package_code": "ab10702030/?",
      "pickup_point": 1,
      "dropoff_point": 2
    }
  ],
  "route_points": [
    {
      "id": 1,
      "contact": {
        "name": "Морти",
        "phone": "+79099999998",
        "phone_additional_code": "602 17 500",
        "email": "example@yandex.ru"
      },
      "address": {
        "fullname": "Санкт-Петербург, Большая Монетная улица, 1к1А",
        "shortname": "Большая Монетная улица, 1к1А",
        "coordinates": [
          0.5,
          0.5
        ],
        "country": "Россия",
        "city": "Санкт-Петербург",
        "building_name": "БЦ На Большой Монетной",
        "street": "Большая Монетная улица",
        "building": "23к1А",
        "porch": "A",
        "sfloor": "1",
        "sflat": "1",
        "door_code": "169",
        "door_code_extra": "код на вход во двор #1234, код от апартаментов #4321",
        "doorbell_name": "Магидович",
        "comment": "Домофон не работает",
        "uri": "ymapsbm1://geo?ll=38.805%2C55.084",
        "description": "Санкт-Петербург, Россия"
      },
      "type": "source",
      "visit_order": 1,
      "visit_status": "pending",
      "skip_confirmation": false,
      "leave_under_door": true,
      "meet_outside": true,
      "no_door_call": true,
      "payment_on_delivery": {
        "payment_ref_id": "123e4567-e89b-12d3-a456-426614174000",
        "client_order_id": "100",
        "is_paid": false,
        "cost": "12.50",
        "customer": {
          "full_name": "Морти",
          "inn": "3664069397",
          "email": "example@yandex.ru",
          "phone": "79000000000"
        },
        "payment_method": "card",
        "invoice_link": "https://ofd.yandex.ru/vaucher/0005312316002718/9410/2604520024"
      },
      "external_order_id": "100",
      "external_order_cost": {
        "value": "100.0",
        "currency": "RUB",
        "currency_sign": "₽"
      },
      "expected_visit_interval": {
        "from": "2020-01-01T00:00:00+00:00",
        "to": "2020-01-02T00:00:00+00:00"
      },
      "pickup_code": "893422",
      "return_reasons": [
        "example"
      ],
      "return_comment": "example",
      "visited_at": {
        "expected": "2025-01-01T00:00:00Z",
        "expected_waiting_time_sec": 0,
        "actual": "2025-01-01T00:00:00Z"
      }
    },
    {
      "id": 1,
      "contact": {
        "name": "Морти",
        "phone": "+79099999998",
        "phone_additional_code": "602 17 500",
        "email": "example@yandex.ru"
      },
      "address": {
        "fullname": "Санкт-Петербург, Большая Монетная улица, 1к1А",
        "shortname": "Большая Монетная улица, 1к1А",
        "coordinates": [
          0.5,
          0.5
        ],
        "country": "Россия",
        "city": "Санкт-Петербург",
        "building_name": "БЦ На Большой Монетной",
        "street": "Большая Монетная улица",
        "building": "23к1А",
        "porch": "A",
        "sfloor": "1",
        "sflat": "1",
        "door_code": "169",
        "door_code_extra": "код на вход во двор #1234, код от апартаментов #4321",
        "doorbell_name": "Магидович",
        "comment": "Домофон не работает",
        "uri": "ymapsbm1://geo?ll=38.805%2C55.084",
        "description": "Санкт-Петербург, Россия"
      },
      "type": "source",
      "visit_order": 1,
      "visit_status": "pending",
      "skip_confirmation": false,
      "leave_under_door": true,
      "meet_outside": true,
      "no_door_call": true,
      "payment_on_delivery": {
        "payment_ref_id": "123e4567-e89b-12d3-a456-426614174000",
        "client_order_id": "100",
        "is_paid": false,
        "cost": "12.50",
        "customer": {
          "full_name": "Морти",
          "inn": "3664069397",
          "email": "example@yandex.ru",
          "phone": "79000000000"
        },
        "payment_method": "card",
        "invoice_link": "https://ofd.yandex.ru/vaucher/0005312316002718/9410/2604520024"
      },
      "external_order_id": "100",
      "external_order_cost": {
        "value": "100.0",
        "currency": "RUB",
        "currency_sign": "₽"
      },
      "expected_visit_interval": {
        "from": "2020-01-01T00:00:00+00:00",
        "to": "2020-01-02T00:00:00+00:00"
      },
      "pickup_code": "893422",
      "return_reasons": [
        "example"
      ],
      "return_comment": "example",
      "visited_at": {
        "expected": "2025-01-01T00:00:00Z",
        "expected_waiting_time_sec": 0,
        "actual": "2025-01-01T00:00:00Z"
      }
    }
  ],
  "current_point_id": 372036854775807,
  "status": "new",
  "version": 0,
  "user_request_revision": "example",
  "error_messages": [
    {
      "code": "some_error",
      "message": "Some error"
    }
  ],
  "emergency_contact": {
    "name": "Рик",
    "phone": "+79826810246",
    "phone_additional_code": "602 17 500"
  },
  "skip_door_to_door": false,
  "skip_client_notify": false,
  "skip_emergency_notify": false,
  "skip_act": false,
  "optional_return": false,
  "eta": 10,
  "created_ts": "2020-01-01T00:00:00+00:00",
  "updated_ts": "2020-01-01T00:00:00+00:00",
  "last_status_change_ts": "2020-01-01T00:00:00+00:00",
  "pricing": {
    "offer": {
      "offer_id": "28ae5f1d72364468be3f5e26cd6a66bf",
      "price": null,
      "valid_until": "2020-01-01T00:00:00+00:00",
      "price_with_vat": null
    },
    "currency": "RUB",
    "currency_rules": {
      "code": null,
      "text": "руб.",
      "template": "$VALUE$ $SIGN$$CURRENCY$",
      "sign": "₽"
    },
    "final_pricing_calc_id": "example",
    "final_price": null
  },
  "client_requirements": {
    "taxi_class": "express",
    "cargo_type": "lcv_m",
    "cargo_loaders": 0,
    "cargo_options": [
      "thermobag"
    ],
    "pro_courier": false,
    "assign_robot": true,
    "rental_duration": 0
  },
  "matched_cars": [
    {
      "taxi_class": "express",
      "client_taxi_class": "cargo",
      "cargo_type": "lcv_m",
      "cargo_type_int": "2 is equal to \"lcv_m\"",
      "cargo_loaders": 0,
      "door_to_door": false,
      "pro_courier": false
    }
  ],
  "warnings": [
    {
      "source": "client_requirements",
      "code": "not_fit_in_car",
      "message": "предупреждение"
    }
  ],
  "performer_info": {
    "courier_name": "Личность",
    "legal_name": "ИП Птичья личность",
    "car_model": "Hyundai Solaris",
    "car_number": "А100РА100",
    "car_color": "красный",
    "car_color_hex": "FF00000",
    "transport_type": "car"
  },
  "callback_properties": {
    "callback_url": "https://www.example.com/"
  },
  "due": "2020-01-01T00:00:00+00:00",
  "shipping_document": "example",
  "comment": "Ресторан",
  "revision": 1,
  "route_id": "example",
  "same_day_data": {
    "delivery_interval": {
      "from": "2020-01-01T07:00:00+00:00",
      "to": "2020-01-01T07:00:00+00:00"
    }
  },
  "taxi_requirements": {}
}
```

**Name**

**Description**

_created\_ts_ (required)

**Type**: string<date-time>

Дата и время создания заявки

_Example:_ `2020-01-01T00:00:00+00:00`

_id_ (required)

**Type**: [ClaimId](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-ClaimId)

Идентификатор(ID) заявки, полученный на этапе создания заявки

_Min length:_ `32`

_Max length:_ `64`

_Example:_ `741cedf82cd464fa6fa16d87155c636`

_items_ (required)

**Type**: [CargoItem](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-CargoItem)\[\]

Параметры товаров

_Min items:_ `1`

**Example**

```
[
  {
    "extra_id": "БП-208",
    "pickup_point": 1,
    "dropoff_point": 2,
    "droppof_point": 0,
    "title": "Плюмбус",
    "size": {
      "length": 0.1,
      "width": 0.2,
      "height": 0.3
    },
    "weight": 2,
    "cost_value": "2.00",
    "cost_currency": "RUB",
    "quantity": 1,
    "fiscalization": {
      "excise": "12.50",
      "vat_code_str": "vat_none",
      "supplier_inn": "3664069397",
      "article": "20ML50OWKY4FC86",
      "mark": {
        "kind": "gs1_data_matrix_base64",
        "code": "444D00000000003741"
      },
      "item_type": "product"
    },
    "age_restricted": false
  }
]
```

_revision_ (required)

**Type**: integer

Ревизия (int64)

_route\_points_ (required)

**Type**: [ResponseCargoRoutePoints](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-ResponseCargoRoutePoints)

Информация по точкам маршрута

_Min items:_ `2`

**Example**

```
[
  {
    "id": 1,
    "contact": {
      "name": "Морти",
      "phone": "+79099999998",
      "phone_additional_code": "602 17 500",
      "email": "example@yandex.ru"
    },
    "address": {
      "fullname": "Санкт-Петербург, Большая Монетная улица, 1к1А",
      "shortname": "Большая Монетная улица, 1к1А",
      "coordinates": [
        0.5,
        0.5
      ],
      "country": "Россия",
      "city": "Санкт-Петербург",
      "building_name": "БЦ На Большой Монетной",
      "street": "Большая Монетная улица",
      "building": "23к1А",
      "porch": "A",
      "sfloor": "1",
      "sflat": "1",
      "door_code": "169",
      "door_code_extra": "код на вход во двор #1234, код от апартаментов #4321",
      "doorbell_name": "Магидович",
      "comment": "Домофон не работает",
      "uri": "ymapsbm1://geo?ll=38.805%2C55.084",
      "description": "Санкт-Петербург, Россия"
    },
    "type": "source",
    "visit_order": 1,
    "visit_status": "pending",
    "skip_confirmation": false,
    "leave_under_door": true,
    "meet_outside": true,
    "no_door_call": true,
    "payment_on_delivery": {
      "payment_ref_id": "123e4567-e89b-12d3-a456-426614174000",
      "client_order_id": "100",
      "is_paid": false,
      "cost": "12.50",
      "customer": {
        "full_name": "Морти",
        "inn": "3664069397",
        "email": "example@yandex.ru",
        "phone": "79000000000"
      },
      "payment_method": "card",
      "invoice_link": "https://ofd.yandex.ru/vaucher/0005312316002718/9410/2604520024"
    },
    "external_order_id": "100",
    "external_order_cost": {
      "value": "100.0",
      "currency": "RUB",
      "currency_sign": "₽"
    },
    "expected_visit_interval": {
      "from": "2020-01-01T00:00:00+00:00",
      "to": "2020-01-02T00:00:00+00:00"
    },
    "pickup_code": "893422",
    "return_reasons": [
      "example"
    ],
    "return_comment": "example",
    "visited_at": {
      "expected": "2025-01-01T00:00:00Z",
      "expected_waiting_time_sec": 0,
      "actual": "2025-01-01T00:00:00Z"
    }
  },
  {
    "id": 1,
    "contact": {
      "name": "Морти",
      "phone": "+79099999998",
      "phone_additional_code": "602 17 500",
      "email": "example@yandex.ru"
    },
    "address": {
      "fullname": "Санкт-Петербург, Большая Монетная улица, 1к1А",
      "shortname": "Большая Монетная улица, 1к1А",
      "coordinates": [
        0.5,
        0.5
      ],
      "country": "Россия",
      "city": "Санкт-Петербург",
      "building_name": "БЦ На Большой Монетной",
      "street": "Большая Монетная улица",
      "building": "23к1А",
      "porch": "A",
      "sfloor": "1",
      "sflat": "1",
      "door_code": "169",
      "door_code_extra": "код на вход во двор #1234, код от апартаментов #4321",
      "doorbell_name": "Магидович",
      "comment": "Домофон не работает",
      "uri": "ymapsbm1://geo?ll=38.805%2C55.084",
      "description": "Санкт-Петербург, Россия"
    },
    "type": "source",
    "visit_order": 1,
    "visit_status": "pending",
    "skip_confirmation": false,
    "leave_under_door": true,
    "meet_outside": true,
    "no_door_call": true,
    "payment_on_delivery": {
      "payment_ref_id": "123e4567-e89b-12d3-a456-426614174000",
      "client_order_id": "100",
      "is_paid": false,
      "cost": "12.50",
      "customer": {
        "full_name": "Морти",
        "inn": "3664069397",
        "email": "example@yandex.ru",
        "phone": "79000000000"
      },
      "payment_method": "card",
      "invoice_link": "https://ofd.yandex.ru/vaucher/0005312316002718/9410/2604520024"
    },
    "external_order_id": "100",
    "external_order_cost": {
      "value": "100.0",
      "currency": "RUB",
      "currency_sign": "₽"
    },
    "expected_visit_interval": {
      "from": "2020-01-01T00:00:00+00:00",
      "to": "2020-01-02T00:00:00+00:00"
    },
    "pickup_code": "893422",
    "return_reasons": [
      "example"
    ],
    "return_comment": "example",
    "visited_at": {
      "expected": "2025-01-01T00:00:00Z",
      "expected_waiting_time_sec": 0,
      "actual": "2025-01-01T00:00:00Z"
    }
  }
]
```

_status_ (required)

**Type**: [ClaimStatus](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-ClaimStatus)

Статус заявки. Подробнее см. в разделе [Статусная модель](https://yandex.ru/support/delivery-profile/ru/api/express/claim-process)

_Enum:_ `new`, `estimating`, `estimating_failed`, `ready_for_approval`, `accepted`, `performer_lookup`, `performer_draft`, `performer_found`, `performer_not_found`, `pickup_arrived`, `ready_for_pickup_confirmation`, `pickuped`, `delivery_arrived`, `ready_for_delivery_confirmation`, `delivered`, `delivered_finish`, `returning`, `return_arrived`, `ready_for_return_confirmation`, `returned`, `returned_finish`, `failed`, `cancelled`, `cancelled_with_payment`, `cancelled_by_taxi`, `cancelled_with_items_on_hands`

_updated\_ts_ (required)

**Type**: string<date-time>

Дата и время последнего обновления заявки

_Example:_ `2020-01-01T00:00:00+00:00`

_user\_request\_revision_ (required)

**Type**: string

Текущая версия изменений в заявке, переданная пользователем

_Example:_ `example`

_version_ (required)

**Type**: integer

Версия (int64)

_callback\_properties_

**Type**: [CallbackProperties](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-CallbackProperties)

Параметры уведомления сервера клиента о смене статуса заявки.

Уведомление представляет собой POST-запрос по указанному url, к
которому будут добавлены информация о дате последнего изменения
заявки и идентификатора заявки в виде
'updated\_ts=&claim\_id=<id заявки>', то есть url вида
'https://example.com/?my\_order\_id=123&' будет расширен до
'https://example.com/?my\_order\_id=123&updated\_ts=...&claim\_id=...'.

Важно: параметры добавляются конкатенацией к callback\_url, то есть
url вида 'https://example.com' превратится в невалидный
'https://example.comupdated\_ts=...&claim\_id=...'.

Поддерживаются только http и https. При https ssl-сертификат должен
быть выдан известным серверу центром сертификации.

К уведомлениям следует относиться как к push ahead of polling, как
к ускорению получения информации о смене статусов. Сервер ожидает
ответ 200, при таймаутах или любом другом ответе какое-то время
будет пытаться доставить уведомление, после чего прекратит попытки.
То есть для надежного получения статуса по заявке клиенту
необходимо запрашивать информацию с помощью метода [claims/info](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsInfo).

Клиенту следует учесть, что ответ операции [claims/info](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsInfo) может
содержать более старое состояние заявки (надо ориентироваться на
значение поля updated\_ts). В этом случает необходимо повторить
вызов операции через некоторое время (от 5 до 30 секунд).

**Example**

```
{
  "callback_url": "https://www.example.com/"
}
```

_client\_requirements_

**Type**: [ClientRequirements](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-ClientRequirements)

Требования от клиента, указанные при создании или редактировании заявки

**Example**

```
{
  "taxi_class": "express",
  "cargo_type": "lcv_m",
  "cargo_loaders": 0,
  "cargo_options": [
    "thermobag"
  ],
  "pro_courier": false,
  "assign_robot": true,
  "rental_duration": 0
}
```

_comment_

**Type**: string

Общий комментарий к заказу

_Max length:_ `7000`

_Example:_ `Ресторан`

_corp\_client\_id_

**Type**: [CorpClientId](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-CorpClientId)

Идентификатор корпоративного клиента Яндекс Доставки (из OAuth-токена)

_Min length:_ `32`

_Max length:_ `32`

_Example:_ `cd8cc018bde34597932855e3cfdce927`

_current\_point\_id_

**Type**: [ClaimPointId](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-ClaimPointId)

Целочисленный идентификатор точки (int64), генерируемый
на стороне Яндекс Доставки.
Содержится в поле route\_points\[\].id. Применимо к точкам с типом
source, destination, return.

_Example:_ `372036854775807`

_due_

**Type**: [Due](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-Due)

Желаемое время прибытия исполнителя на точку А (source).
В РФ отложить расчетное время прибытия исполнителя можно:
\- на 30-240 минут от текущего момента – для тарифа `express`;
\- на пять суток от текущего момента – для тарифа `cargo`.

Параметр не совместим с опциями замедления в тарифе `express` на территории РФ.
Если этот параметр не задан, то запустится поиск исполнителя на ближайшее время.

_Example:_ `2020-01-01T00:00:00+00:00`

_emergency\_contact_

**Type**: [ContactWithPhone](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-ContactWithPhone)

Информация о контактном лице с номером телефона

**Example**

```
{
  "name": "Рик",
  "phone": "+79826810246",
  "phone_additional_code": "602 17 500"
}
```

_error\_messages_

**Type**: [HumanErrorMessage](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-HumanErrorMessage)\[\]

Список сообщений об ошибках

**Example**

```
[
  {
    "code": "some_error",
    "message": "Some error"
  }
]
```

_eta_

**Type**: [Eta](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-Eta)

Расчетное время выполнения заказа в минутах (int64)

_Example:_ `10`

_last\_status\_change\_ts_

**Type**: string<date-time>

Дата-время последнего изменения статуса

_Example:_ `2020-01-01T00:00:00+00:00`

_matched\_cars_

**Type**: [MatchedCar](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-MatchedCar)\[\]

Информация о подобранном тарифе

**Example**

```
[
  {
    "taxi_class": "express",
    "client_taxi_class": "cargo",
    "cargo_type": "lcv_m",
    "cargo_type_int": "2 is equal to \"lcv_m\"",
    "cargo_loaders": 0,
    "door_to_door": false,
    "pro_courier": false
  }
]
```

_optional\_return_

**Type**: [OptionalReturn](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-OptionalReturn)

Отключить возврат товаров в случае отмены заказа.

Возможные значения:

\- true (курьер оставляет товар себе)
\- false (по умолчанию, требуется вернуть товар)

_Default:_ `false`

_Example:_ `false`

_packages_

**Type**: [Package](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-Package)\[\]

Список грузомест

_Min items:_ `1`

**Example**

```
[
  {
    "package_id": "a8e5b0e6-3d67-4d6f-89a5-3b6c1a0e4f5c",
    "package_type": "other",
    "package_code": "ab10702030/?",
    "pickup_point": 1,
    "dropoff_point": 2
  }
]
```

_performer\_info_

**Type**: [CreatedPerformerInfo](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-CreatedPerformerInfo)

Информация об исполнителе

Информация о курьере

**Example**

```
{
  "courier_name": "Личность",
  "legal_name": "ИП Птичья личность",
  "car_model": "Hyundai Solaris",
  "car_number": "А100РА100",
  "car_color": "красный",
  "car_color_hex": "FF00000",
  "transport_type": "car"
}
```

_pricing_

**Type**: [ClaimPricing](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-ClaimPricing)

Информация о стоимости заказа

**Example**

```
{
  "offer": {
    "offer_id": "28ae5f1d72364468be3f5e26cd6a66bf",
    "price": "12.50",
    "valid_until": "2020-01-01T00:00:00+00:00",
    "price_with_vat": null
  },
  "currency": "RUB",
  "currency_rules": {
    "code": "RUB",
    "text": "руб.",
    "template": "$VALUE$ $SIGN$$CURRENCY$",
    "sign": "₽"
  },
  "final_pricing_calc_id": "example",
  "final_price": null
}
```

_route\_id_

**Type**: string

Идентификатор машрута, в рамках которого доставляется заказ
Если несколько заказов доставляются одним курьером,
они будут иметь одинаковый route\_id
(Актуально только для доставки "В течение дня")

_Example:_ `example`

_same\_day\_data_

**Type**: [SameDayData](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-SameDayData)

Дополнительная информация для заявок `В течение дня`. Недоступно в России

**Example**

```
{
  "delivery_interval": {
    "from": "2020-01-01T07:00:00+00:00",
    "to": "2020-01-01T07:00:00+00:00"
  }
}
```

_shipping\_document_

**Type**: string

Сопроводительные документы

_Example:_ `example`

_skip\_act_

**Type**: [SkipAct](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-SkipAct)

Не показывать акт приема-передачи

_Example:_ `false`

_skip\_client\_notify_

**Type**: [SkipClientNotify](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-SkipClientNotify)

Не отправлять отправителю/получателю смс-уведомления,
когда к нему направится курьер.

Значение по умолчанию: false (отправлять уведомления)

_Default:_ `false`

_Example:_ `false`

_skip\_door\_to\_door_

**Type**: [SkipDoorToDoor](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-SkipDoorToDoor)

Отключить доставку до двери (выключить опцию "От двери до двери").

Возможные значения:

\- true (курьер доставит заказ только на улицу, до подъезда)
\- false (курьер доставит до двери) - значение по умолчанию

_Default:_ `false`

_Example:_ `false`

_skip\_emergency\_notify_

**Type**: [SkipEmergencyNotify](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-SkipEmergencyNotify)

Не отправлять уведомление запасному контактному лицу

Значение по умолчанию: false (отправлять уведомления)

_Default:_ `false`

_Example:_ `false`

_taxi\_requirements_

**Type**: object

**Example**

```
{}
```

_warnings_

**Type**: [ClaimWarning](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-ClaimWarning)\[\]

Предупреждения по ходу обработки заявки

**Example**

```
[
  {
    "source": "client_requirements",
    "code": "not_fit_in_car",
    "message": "предупреждение"
  }
]
```

### ClaimId <a id="entity-ClaimId"></a>

Идентификатор(ID) заявки, полученный на этапе создания заявки

**Type**: string

_Min length:_ `32`

_Max length:_ `64`

_Example:_ `741cedf82cd464fa6fa16d87155c636`

### CorpClientId <a id="entity-CorpClientId"></a>

Идентификатор корпоративного клиента Яндекс Доставки (из OAuth-токена)

**Type**: string

_Min length:_ `32`

_Max length:_ `32`

_Example:_ `cd8cc018bde34597932855e3cfdce927`

### PointVisitStatus <a id="entity-PointVisitStatus"></a>

Статус посещения точки:

-   pending - точка еще не посещена;
-   arrived - курьер прибыл на точку;
-   visited - курьер передал/забрал груз на точке;
-   skipped - точка пропущена (в случае, если не смог принять товар).

**Type**: string

_Enum:_ `pending`, `arrived`, `visited`, `skipped`

### PaymentId <a id="entity-PaymentId"></a>

Идентификатор оплаты

**Type**: string<uuid>

_Example:_ `123e4567-e89b-12d3-a456-426614174000`

### ClientOrderId <a id="entity-ClientOrderId"></a>

Внешний идентификатор клиентского заказа

**Type**: string

_Example:_ `100`

### PaymentComplete <a id="entity-PaymentComplete"></a>

Признак оплаты заказа

**Type**: boolean

### XInternalMoney <a id="entity-XInternalMoney"></a>

Цена Decimal(19, 4)

**Type**: string

_Pattern:_ `^-?[0-9]{1,14}(\.[0-9]{0,4})?$`

_Example:_ `12.50`

### CustomerFiscalization <a id="entity-CustomerFiscalization"></a>

Информация о клиенте(получателе)

|     |     |
| --- | --- |
| **Name** | **Description** |
| _email_ | **Type**: string<br><br>Электронная почта пользователя. Если не указано, будет использована почта получателя из точки назначения<br><br>_Example:_ `example@yandex.ru` |
| _full\_name_ | **Type**: string<br><br>Для юридического лица — название организации, для ИП и физического лица — ФИО<br><br>_Example:_ `Морти` |
| _inn_ | **Type**: [Inn](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-Inn)<br><br>ИНН пользователя (10 или 12 цифр)<br><br>_Pattern:_ `^[A-Z0-9\\-]+$`<br><br>_Example:_ `3664069397` |
| _phone_ | **Type**: string<br><br>Телефон пользователя в формате +X XXX XXX XX XX. Если не указано, будет использован телефон получателя из точки назначения<br><br>_Example:_ `79000000000` |

**Example**

```
{
  "full_name": "Морти",
  "inn": "3664069397",
  "email": "example@yandex.ru",
  "phone": "79000000000"
}
```

### InvoiceLink <a id="entity-InvoiceLink"></a>

Ссылка на чек

**Type**: string

_Example:_ `https://ofd.yandex.ru/vaucher/0005312316002718/9410/2604520024`

### CreateResponsePaymentOnDelivery <a id="entity-CreateResponsePaymentOnDelivery"></a>

Параметры оплаты при получении

|     |     |
| --- | --- |
| **Name** | **Description** |
| _is\_paid_ (required) | **Type**: [PaymentComplete](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-PaymentComplete)<br><br>Признак оплаты заказа<br><br>_Example:_ `false` |
| _client\_order\_id_ | **Type**: [ClientOrderId](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-ClientOrderId)<br><br>Внешний идентификатор клиентского заказа<br><br>_Example:_ `100` |
| _cost_ | **Type**: [XInternalMoney](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-XInternalMoney)<br><br>Цена Decimal(19, 4)<br><br>_Pattern:_ `^-?[0-9]{1,14}(\.[0-9]{0,4})?$`<br><br>_Example:_ `12.50` |
| _customer_ | **Type**: [CustomerFiscalization](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-CustomerFiscalization)<br><br>Информация о клиенте(получателе)<br><br>**Example**<br><br>```<br>{<br>  "full_name": "Морти",<br>  "inn": "3664069397",<br>  "email": "example@yandex.ru",<br>  "phone": "79000000000"<br>}<br>``` |
| _invoice\_link_ | **Type**: [InvoiceLink](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-InvoiceLink)<br><br>Ссылка на чек<br><br>_Example:_ `https://ofd.yandex.ru/vaucher/0005312316002718/9410/2604520024` |
| _payment\_method_ | **Type**: [PaymentMethod](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-PaymentMethod)<br><br>Выбранный тип оплаты.  <br>card - оплата картой;  <br>cash - оплата наличными (пока недоступна);<br><br>_Enum:_ `card`, `cash` |
| _payment\_ref\_id_ | **Type**: [PaymentId](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-PaymentId)<br><br>Идентификатор оплаты<br><br>_Example:_ `123e4567-e89b-12d3-a456-426614174000` |

**Example**

```
{
  "payment_ref_id": "123e4567-e89b-12d3-a456-426614174000",
  "client_order_id": "100",
  "is_paid": false,
  "cost": "12.50",
  "customer": {
    "full_name": "Морти",
    "inn": "3664069397",
    "email": "example@yandex.ru",
    "phone": "79000000000"
  },
  "payment_method": "card",
  "invoice_link": "https://ofd.yandex.ru/vaucher/0005312316002718/9410/2604520024"
}
```

### ExpectedVisitInterval <a id="entity-ExpectedVisitInterval"></a>

Временной интервал посещения курьером точки согласно выбранному офферу

|     |     |
| --- | --- |
| **Name** | **Description** |
| _from_ (required) | **Type**: string<date-time><br><br>Начало интервала<br><br>_Example:_ `2020-01-01T00:00:00+00:00` |
| _to_ (required) | **Type**: string<date-time><br><br>Окончание интервала<br><br>_Example:_ `2020-01-02T00:00:00+00:00` |

**Example**

```
{
  "from": "2020-01-01T00:00:00+00:00",
  "to": "2020-01-02T00:00:00+00:00"
}
```

### PointVisitTime <a id="entity-PointVisitTime"></a>

Информация о времени посещения точки

|     |     |
| --- | --- |
| **Name** | **Description** |
| _actual_ | **Type**: string<date-time><br><br>Фактическое время посещения точки.  <br>Заполняется только для посещенных точек.<br><br>_Example:_ `2025-01-01T00:00:00Z` |
| _expected_ | **Type**: string<date-time><br><br>Расчетное время посещения. Может быть заполнено  <br>только для непосещенных точек.<br><br>_Example:_ `2025-01-01T00:00:00Z` |
| _expected\_waiting\_time\_sec_ | **Type**: integer<br><br>Расчетное время ожидания в точке. (int64) |

**Example**

```
{
  "expected": "2025-01-01T00:00:00Z",
  "expected_waiting_time_sec": 0,
  "actual": "2025-01-01T00:00:00Z"
}
```

### ResponseCargoPoint <a id="entity-ResponseCargoPoint"></a>

Информация по точкам маршрута

|     |     |
| --- | --- |
| **Name** | **Description** |
| _address_ (required) | **Type**: [CargoPointAddress](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-CargoPointAddress)<br><br>Адрес точки<br><br>**Example**<br><br>```<br>{<br>  "fullname": "Санкт-Петербург, Большая Монетная улица, 1к1А",<br>  "shortname": "Большая Монетная улица, 1к1А",<br>  "coordinates": [<br>    0.5,<br>    0.5<br>  ],<br>  "country": "Россия",<br>  "city": "Санкт-Петербург",<br>  "building_name": "БЦ На Большой Монетной",<br>  "street": "Большая Монетная улица",<br>  "building": "23к1А",<br>  "porch": "A",<br>  "sfloor": "1",<br>  "sflat": "1",<br>  "door_code": "169",<br>  "door_code_extra": "код на вход во двор #1234, код от апартаментов #4321",<br>  "doorbell_name": "Магидович",<br>  "comment": "Домофон не работает",<br>  "uri": "ymapsbm1://geo?ll=38.805%2C55.084",<br>  "description": "Санкт-Петербург, Россия"<br>}<br>``` |
| _contact_ (required) | **Type**: [CreatedContactOnPoint](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-CreatedContactOnPoint)<br><br>Информация о контактном лице<br><br>**Example**<br><br>```<br>{<br>  "name": "Морти",<br>  "phone": "+79099999998",<br>  "phone_additional_code": "602 17 500",<br>  "email": "example@yandex.ru"<br>}<br>``` |
| _id_ (required) | **Type**: integer<br><br>Целочисленный идентификатор точки (int64) |
| _type_ (required) | **Type**: [PointType](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-PointType)<br><br>Тип точки:<br><br>  <br>\- source - точка отправления, где курьер забирает товар  <br>\- destination – точки назначения, где курьер передает товар  <br>\- return - точка возврата товара (добавляется автоматически и по умолчанию совпадает с точкой отправления, но также можно определить другую точку)<br><br>_Enum:_ `source`, `destination`, `return` |
| _visit\_order_ (required) | **Type**: integer<br><br>Порядок посещения точки (нумерация начинается с 1) (int64) |
| _visit\_status_ (required) | **Type**: [PointVisitStatus](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-PointVisitStatus)<br><br>Статус посещения точки:<br><br>  <br>\- pending - точка еще не посещена;  <br>\- arrived - курьер прибыл на точку;  <br>\- visited - курьер передал/забрал груз на точке;  <br>\- skipped - точка пропущена (в случае, если не смог принять товар).<br><br>_Enum:_ `pending`, `arrived`, `visited`, `skipped` |
| _visited\_at_ (required) | **Type**: [PointVisitTime](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-PointVisitTime)<br><br>Информация о времени посещения точки<br><br>**Example**<br><br>```<br>{<br>  "expected": "2025-01-01T00:00:00Z",<br>  "expected_waiting_time_sec": 0,<br>  "actual": "2025-01-01T00:00:00Z"<br>}<br>``` |
| _expected\_visit\_interval_ | **Type**: [ExpectedVisitInterval](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-ExpectedVisitInterval)<br><br>Временной интервал посещения курьером точки согласно выбранному офферу<br><br>**Example**<br><br>```<br>{<br>  "from": "2020-01-01T00:00:00+00:00",<br>  "to": "2020-01-02T00:00:00+00:00"<br>}<br>``` |
| _external\_order\_cost_ | **Type**: [ExternalOrderCost](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-ExternalOrderCost)<br><br>Стоимость внешнего заказа, привязанного к точке<br><br>**Example**<br><br>```<br>{<br>  "value": "100.0",<br>  "currency": "RUB",<br>  "currency_sign": "₽"<br>}<br>``` |
| _external\_order\_id_ | **Type**: string<br><br>Номер заказа из системы клиента.  <br>Передается для точки типа destination<br><br>_Example:_ `100` |
| _leave\_under\_door_ | **Type**: boolean<br><br>Оставить заказ у двери |
| _meet\_outside_ | **Type**: boolean<br><br>Курьера встретят на улице у подъезда |
| _no\_door\_call_ | **Type**: boolean<br><br>Не звонить в дверь |
| _payment\_on\_delivery_ | **Type**: [CreateResponsePaymentOnDelivery](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-CreateResponsePaymentOnDelivery)<br><br>Параметры оплаты при получении<br><br>**Example**<br><br>```<br>{<br>  "payment_ref_id": "123e4567-e89b-12d3-a456-426614174000",<br>  "client_order_id": "100",<br>  "is_paid": false,<br>  "cost": "12.50",<br>  "customer": {<br>    "full_name": "Морти",<br>    "inn": "3664069397",<br>    "email": "example@yandex.ru",<br>    "phone": "79000000000"<br>  },<br>  "payment_method": "card",<br>  "invoice_link": "https://ofd.yandex.ru/vaucher/0005312316002718/9410/2604520024"<br>}<br>``` |
| _pickup\_code_ | **Type**: [PickupCode](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-PickupCode)<br><br>Код выдачи заказа курьеру.  <br>Курьеру потребуется ввести этот код, чтобы подтвердить, что он забрал заказ.  <br>Для этого необходимо, чтобы ваши сотрудники на точке выдачи имели возможность назвать этот код курьеру.  <br>Актуально для точки с типом 'source'.  <br>Формат кода: 6 цифр  <br>\|  <br>Код выдачи товара (ПВЗ)<br><br>_Example:_ `893422` |
| _return\_comment_ | **Type**: string<br><br>Комментарий к причинам возврата груза<br><br>_Example:_ `example` |
| _return\_reasons_ | **Type**: string\[\]<br><br>Причины возврата груза<br><br>**Example**<br><br>```<br>[<br>  "example"<br>]<br>``` |
| _skip\_confirmation_ | **Type**: [CargoPointSkipConfirmation](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-CargoPointSkipConfirmation)<br><br>Пропускать подтверждение по смс в данной точке<br><br>Значение по умолчанию: false (подтверждение требуется).<br><br>_Default:_ `false`<br><br>_Example:_ `false` |

**Example**

```
{
  "id": 1,
  "contact": {
    "name": "Морти",
    "phone": "+79099999998",
    "phone_additional_code": "602 17 500",
    "email": "example@yandex.ru"
  },
  "address": {
    "fullname": "Санкт-Петербург, Большая Монетная улица, 1к1А",
    "shortname": "Большая Монетная улица, 1к1А",
    "coordinates": [
      0.5,
      0.5
    ],
    "country": "Россия",
    "city": "Санкт-Петербург",
    "building_name": "БЦ На Большой Монетной",
    "street": "Большая Монетная улица",
    "building": "23к1А",
    "porch": "A",
    "sfloor": "1",
    "sflat": "1",
    "door_code": "169",
    "door_code_extra": "код на вход во двор #1234, код от апартаментов #4321",
    "doorbell_name": "Магидович",
    "comment": "Домофон не работает",
    "uri": "ymapsbm1://geo?ll=38.805%2C55.084",
    "description": "Санкт-Петербург, Россия"
  },
  "type": "source",
  "visit_order": 1,
  "visit_status": "pending",
  "skip_confirmation": false,
  "leave_under_door": true,
  "meet_outside": true,
  "no_door_call": true,
  "payment_on_delivery": {
    "payment_ref_id": "123e4567-e89b-12d3-a456-426614174000",
    "client_order_id": "100",
    "is_paid": false,
    "cost": "12.50",
    "customer": {
      "full_name": "Морти",
      "inn": "3664069397",
      "email": "example@yandex.ru",
      "phone": "79000000000"
    },
    "payment_method": "card",
    "invoice_link": "https://ofd.yandex.ru/vaucher/0005312316002718/9410/2604520024"
  },
  "external_order_id": "100",
  "external_order_cost": {
    "value": "100.0",
    "currency": "RUB",
    "currency_sign": "₽"
  },
  "expected_visit_interval": {
    "from": "2020-01-01T00:00:00+00:00",
    "to": "2020-01-02T00:00:00+00:00"
  },
  "pickup_code": "893422",
  "return_reasons": [
    "example"
  ],
  "return_comment": "example",
  "visited_at": {
    "expected": "2025-01-01T00:00:00Z",
    "expected_waiting_time_sec": 0,
    "actual": "2025-01-01T00:00:00Z"
  }
}
```

### ResponseCargoRoutePoints <a id="entity-ResponseCargoRoutePoints"></a>

Информация по точкам маршрута

**Type**: [ResponseCargoPoint](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-ResponseCargoPoint)\[\]

_Min items:_ `2`

**Example**

```
[
  {
    "id": 1,
    "contact": {
      "name": "Морти",
      "phone": "+79099999998",
      "phone_additional_code": "602 17 500",
      "email": "example@yandex.ru"
    },
    "address": {
      "fullname": "Санкт-Петербург, Большая Монетная улица, 1к1А",
      "shortname": "Большая Монетная улица, 1к1А",
      "coordinates": [
        0.5,
        0.5
      ],
      "country": "Россия",
      "city": "Санкт-Петербург",
      "building_name": "БЦ На Большой Монетной",
      "street": "Большая Монетная улица",
      "building": "23к1А",
      "porch": "A",
      "sfloor": "1",
      "sflat": "1",
      "door_code": "169",
      "door_code_extra": "код на вход во двор #1234, код от апартаментов #4321",
      "doorbell_name": "Магидович",
      "comment": "Домофон не работает",
      "uri": "ymapsbm1://geo?ll=38.805%2C55.084",
      "description": "Санкт-Петербург, Россия"
    },
    "type": "source",
    "visit_order": 1,
    "visit_status": "pending",
    "skip_confirmation": false,
    "leave_under_door": true,
    "meet_outside": true,
    "no_door_call": true,
    "payment_on_delivery": {
      "payment_ref_id": "123e4567-e89b-12d3-a456-426614174000",
      "client_order_id": "100",
      "is_paid": false,
      "cost": "12.50",
      "customer": {
        "full_name": "Морти",
        "inn": "3664069397",
        "email": "example@yandex.ru",
        "phone": "79000000000"
      },
      "payment_method": "card",
      "invoice_link": "https://ofd.yandex.ru/vaucher/0005312316002718/9410/2604520024"
    },
    "external_order_id": "100",
    "external_order_cost": {
      "value": "100.0",
      "currency": "RUB",
      "currency_sign": "₽"
    },
    "expected_visit_interval": {
      "from": "2020-01-01T00:00:00+00:00",
      "to": "2020-01-02T00:00:00+00:00"
    },
    "pickup_code": "893422",
    "return_reasons": [
      "example"
    ],
    "return_comment": "example",
    "visited_at": {
      "expected": "2025-01-01T00:00:00Z",
      "expected_waiting_time_sec": 0,
      "actual": "2025-01-01T00:00:00Z"
    }
  },
  {
    "id": 1,
    "contact": {
      "name": "Морти",
      "phone": "+79099999998",
      "phone_additional_code": "602 17 500",
      "email": "example@yandex.ru"
    },
    "address": {
      "fullname": "Санкт-Петербург, Большая Монетная улица, 1к1А",
      "shortname": "Большая Монетная улица, 1к1А",
      "coordinates": [
        0.5,
        0.5
      ],
      "country": "Россия",
      "city": "Санкт-Петербург",
      "building_name": "БЦ На Большой Монетной",
      "street": "Большая Монетная улица",
      "building": "23к1А",
      "porch": "A",
      "sfloor": "1",
      "sflat": "1",
      "door_code": "169",
      "door_code_extra": "код на вход во двор #1234, код от апартаментов #4321",
      "doorbell_name": "Магидович",
      "comment": "Домофон не работает",
      "uri": "ymapsbm1://geo?ll=38.805%2C55.084",
      "description": "Санкт-Петербург, Россия"
    },
    "type": "source",
    "visit_order": 1,
    "visit_status": "pending",
    "skip_confirmation": false,
    "leave_under_door": true,
    "meet_outside": true,
    "no_door_call": true,
    "payment_on_delivery": {
      "payment_ref_id": "123e4567-e89b-12d3-a456-426614174000",
      "client_order_id": "100",
      "is_paid": false,
      "cost": "12.50",
      "customer": {
        "full_name": "Морти",
        "inn": "3664069397",
        "email": "example@yandex.ru",
        "phone": "79000000000"
      },
      "payment_method": "card",
      "invoice_link": "https://ofd.yandex.ru/vaucher/0005312316002718/9410/2604520024"
    },
    "external_order_id": "100",
    "external_order_cost": {
      "value": "100.0",
      "currency": "RUB",
      "currency_sign": "₽"
    },
    "expected_visit_interval": {
      "from": "2020-01-01T00:00:00+00:00",
      "to": "2020-01-02T00:00:00+00:00"
    },
    "pickup_code": "893422",
    "return_reasons": [
      "example"
    ],
    "return_comment": "example",
    "visited_at": {
      "expected": "2025-01-01T00:00:00Z",
      "expected_waiting_time_sec": 0,
      "actual": "2025-01-01T00:00:00Z"
    }
  }
]
```

### ClaimPointId <a id="entity-ClaimPointId"></a>

Целочисленный идентификатор точки (int64), генерируемый
на стороне Яндекс Доставки.
Содержится в поле route\_points\[\].id. Применимо к точкам с типом
source, destination, return.

**Type**: integer

### ClaimStatus <a id="entity-ClaimStatus"></a>

Статус заявки. Подробнее см. в разделе [Статусная модель](https://yandex.ru/support/delivery-profile/ru/api/express/claim-process)

**Type**: string

_Enum:_ `new`, `estimating`, `estimating_failed`, `ready_for_approval`, `accepted`, `performer_lookup`, `performer_draft`, `performer_found`, `performer_not_found`, `pickup_arrived`, `ready_for_pickup_confirmation`, `pickuped`, `delivery_arrived`, `ready_for_delivery_confirmation`, `delivered`, `delivered_finish`, `returning`, `return_arrived`, `ready_for_return_confirmation`, `returned`, `returned_finish`, `failed`, `cancelled`, `cancelled_with_payment`, `cancelled_by_taxi`, `cancelled_with_items_on_hands`

### HumanErrorMessage <a id="entity-HumanErrorMessage"></a>

Код и описание ошибки

|     |     |
| --- | --- |
| **Name** | **Description** |
| _code_ (required) | **Type**: string<br><br>Код ошибки<br><br>_Example:_ `some_error` |
| _message_ (required) | **Type**: string<br><br>Описание ошибки<br><br>_Example:_ `Some error` |

**Example**

```
{
  "code": "some_error",
  "message": "Some error"
}
```

### Eta <a id="entity-Eta"></a>

Расчетное время выполнения заказа в минутах (int64)

**Type**: integer

### TaxiOfferId <a id="entity-TaxiOfferId"></a>

Идентификатор предложения

**Type**: string

_Example:_ `28ae5f1d72364468be3f5e26cd6a66bf`

### TaxiOffer <a id="entity-TaxiOffer"></a>

Предложение от Яндекс Доставки (актуально в течение некоторого времени).

|     |     |
| --- | --- |
| **Name** | **Description** |
| _offer\_id_ (required) | **Type**: [TaxiOfferId](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-TaxiOfferId)<br><br>Идентификатор предложения<br><br>_Example:_ `28ae5f1d72364468be3f5e26cd6a66bf` |
| _price_ (required) | **Type**: [Money](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-Money)<br><br>Цена по предложению без НДС<br><br>Стоимость доставки в формате десятичной дроби Decimal(18, 4)<br><br>_Pattern:_ `^-?[0-9]{1,14}(\.[0-9]{0,4})?$`<br><br>_Example:_ `12.50` |
| _price\_with\_vat_ | **Type**: [Money](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-Money)<br><br>Стоимость доставки в формате десятичной дроби Decimal(18, 4)<br><br>_Pattern:_ `^-?[0-9]{1,14}(\.[0-9]{0,4})?$`<br><br>_Example:_ `12.50` |
| _valid\_until_ | **Type**: string<date-time><br><br>Время до которого действительно предложение на принятие заявки. Если значения нет, то ограничений по длительности предложения нет<br><br>_Example:_ `2020-01-01T00:00:00+00:00` |

**Example**

```
{
  "offer_id": "28ae5f1d72364468be3f5e26cd6a66bf",
  "price": "12.50",
  "valid_until": "2020-01-01T00:00:00+00:00",
  "price_with_vat": null
}
```

### CurrencyRules <a id="entity-CurrencyRules"></a>

Правила отображения валюты

|     |     |
| --- | --- |
| **Name** | **Description** |
| _code_ (required) | **Type**: [Currency](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-Currency)<br><br>Трехзначный код валюты, в которой ведется расчет<br><br>_Min length:_ `3`<br><br>_Max length:_ `3`<br><br>_Example:_ `RUB` |
| _template_ (required) | **Type**: string<br><br>Шаблон для отображения валюты<br><br>_Example:_ `$VALUE$ $SIGN$$CURRENCY$` |
| _text_ (required) | **Type**: string<br><br>Сокращенное наименование валюты<br><br>_Example:_ `руб.` |
| _sign_ | **Type**: string<br><br>Символ валюты<br><br>_Example:_ `₽` |

**Example**

```
{
  "code": "RUB",
  "text": "руб.",
  "template": "$VALUE$ $SIGN$$CURRENCY$",
  "sign": "₽"
}
```

### ClaimPricing <a id="entity-ClaimPricing"></a>

Информация о стоимости заказа

|     |     |
| --- | --- |
| **Name** | **Description** |
| _currency_ | **Type**: string<br><br>Трехзначный код валюты, в которой ведется расчет<br><br>_Example:_ `RUB` |
| _currency\_rules_ | **Type**: [CurrencyRules](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-CurrencyRules)<br><br>Правила отображения валюты<br><br>**Example**<br><br>```<br>{<br>  "code": "RUB",<br>  "text": "руб.",<br>  "template": "$VALUE$ $SIGN$$CURRENCY$",<br>  "sign": "₽"<br>}<br>``` |
| _final\_price_ | **Type**: [Money](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-Money)<br><br>Окончательная цена доставки с учетом НДС.  <br>Заполняется после окончания доставки/возврата.<br><br>Стоимость доставки в формате десятичной дроби Decimal(18, 4)<br><br>_Pattern:_ `^-?[0-9]{1,14}(\.[0-9]{0,4})?$`<br><br>_Example:_ `12.50` |
| _final\_pricing\_calc\_id_ | **Type**: string<br><br>Идентификатор расчета стоимости<br><br>_Example:_ `example` |
| _offer_ | **Type**: [TaxiOffer](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-TaxiOffer)<br><br>Предложение от Яндекс Доставки (актуально в течение некоторого времени).<br><br>**Example**<br><br>```<br>{<br>  "offer_id": "28ae5f1d72364468be3f5e26cd6a66bf",<br>  "price": "12.50",<br>  "valid_until": "2020-01-01T00:00:00+00:00",<br>  "price_with_vat": null<br>}<br>``` |

**Example**

```
{
  "offer": {
    "offer_id": "28ae5f1d72364468be3f5e26cd6a66bf",
    "price": "12.50",
    "valid_until": "2020-01-01T00:00:00+00:00",
    "price_with_vat": null
  },
  "currency": "RUB",
  "currency_rules": {
    "code": "RUB",
    "text": "руб.",
    "template": "$VALUE$ $SIGN$$CURRENCY$",
    "sign": "₽"
  },
  "final_pricing_calc_id": "example",
  "final_price": null
}
```

### MatchedCar <a id="entity-MatchedCar"></a>

|     |     |
| --- | --- |
| **Name** | **Description** |
| _taxi\_class_ (required) | **Type**: string<br><br>Тариф доставки. Возможные значения: courier, express, cargo<br><br>_Example:_ `express` |
| _cargo\_loaders_ | **Type**: integer<br><br>Требуемое число грузчиков (int64)<br><br>_Min value:_ `0` |
| _cargo\_type_ | **Type**: string<br><br>Тип кузова<br><br>_Example:_ `lcv_m` |
| _cargo\_type\_int_ | **Type**: integer<br><br>Тип кузова (int64) |
| _client\_taxi\_class_ | **Type**: string<br><br>Клиентский тариф<br><br>_Example:_ `cargo` |
| _door\_to\_door_ | **Type**: boolean<br><br>Опция "от двери до двери" для тарифа "Экспресс" |
| _pro\_courier_ | **Type**: boolean<br><br>Включить опцию "Профи" для тарифов "Экспресс" и "Курьер".  <br>Поиск исполнителя будет происходить только среди опытных курьеров. |

**Example**

```
{
  "taxi_class": "express",
  "client_taxi_class": "cargo",
  "cargo_type": "lcv_m",
  "cargo_type_int": "2 is equal to \"lcv_m\"",
  "cargo_loaders": 0,
  "door_to_door": false,
  "pro_courier": false
}
```

### ClaimWarningSourceApi <a id="entity-ClaimWarningSourceApi"></a>

Источник предупреждения:

-   client\_requirements - предупреждение связано с требованиями клиента;
-   route\_points - предупреждение связано
    с переданными адресами.

**Type**: string

_Example:_ `client_requirements`

### ClaimWarningCodeApi <a id="entity-ClaimWarningCodeApi"></a>

Тип предупреждения:

-   not\_fit\_in\_car - груз может не поместиться в транспортное средство;
-   requirement\_unavailable - указанное требование недоступно и было проигнорировано;
-   address\_not\_found - указанный адрес не найден в Яндекс Картах;
-   address\_too\_far - координаты из Яндекс Карт по указанному адресу находятся далеко от переданных координат.

**Type**: string

_Example:_ `not_fit_in_car`

### ClaimWarning <a id="entity-ClaimWarning"></a>

|     |     |
| --- | --- |
| **Name** | **Description** |
| _code_ (required) | **Type**: [ClaimWarningCodeApi](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-ClaimWarningCodeApi)<br><br>Тип предупреждения:<br><br>  <br>\- not\_fit\_in\_car - груз может не поместиться в транспортное средство;  <br>\- requirement\_unavailable - указанное требование недоступно и было проигнорировано;  <br>\- address\_not\_found - указанный адрес не найден в Яндекс Картах;  <br>\- address\_too\_far - координаты из Яндекс Карт по указанному адресу находятся далеко от переданных координат.<br><br>_Example:_ `not_fit_in_car` |
| _source_ (required) | **Type**: [ClaimWarningSourceApi](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate#entity-ClaimWarningSourceApi)<br><br>Источник предупреждения:<br><br>  <br>\- client\_requirements - предупреждение связано с требованиями клиента;  <br>\- route\_points - предупреждение связано  <br>с переданными адресами.<br><br>_Example:_ `client_requirements` |
| _message_ | **Type**: string<br><br>Описание предупреждения<br><br>_Example:_ `предупреждение` |

**Example**

```
{
  "source": "client_requirements",
  "code": "not_fit_in_car",
  "message": "предупреждение"
}
```

### CreatedPerformerInfo <a id="entity-CreatedPerformerInfo"></a>

Информация о курьере

|     |     |
| --- | --- |
| **Name** | **Description** |
| _courier\_name_ (required) | **Type**: string<br><br>Имя курьера, доставляющего заказ<br><br>_Example:_ `Личность` |
| _legal\_name_ (required) | **Type**: string<br><br>Данные о юридическом лице, которое осуществляет доставку<br><br>_Example:_ `ИП Птичья личность` |
| _car\_color_ | **Type**: string<br><br>Цвет машины<br><br>_Example:_ `красный` |
| _car\_color\_hex_ | **Type**: string<br><br>RGB-код цвета машины<br><br>_Example:_ `FF00000` |
| _car\_model_ | **Type**: string<br><br>Модель машины<br><br>_Example:_ `Hyundai Solaris` |
| _car\_number_ | **Type**: string<br><br>Номер машины<br><br>_Example:_ `А100РА100` |
| _transport\_type_ | **Type**: string<br><br>Тип транспорта исполнителя<br><br>_Example:_ `car` |

**Example**

```
{
  "courier_name": "Личность",
  "legal_name": "ИП Птичья личность",
  "car_model": "Hyundai Solaris",
  "car_number": "А100РА100",
  "car_color": "красный",
  "car_color_hex": "FF00000",
  "transport_type": "car"
}
```

## 400 Bad Request <a id="400-bad-request"></a>

Неверный запрос

### Body <a id="body2"></a>

**application/json**

```
{
  "code": "bad_request",
  "message": "Неправильное тело запроса"
}
```

|     |     |
| --- | --- |
| **Name** | **Description** |
| _code_ (required) | **Type**: string<br><br>Код ошибки<br><br>_Enum:_ `unknown_error`, `validation_error`, `sdd_items_without_parameters_forbidden`, `items_without_parameters_forbidden`, `address_too_far`, `address_not_found`, `bad_request`, `invalid_post_payment`, `sdd_client_requirements_forbidden`, `invalid_delivery_interval`, `wrong_pickup_code_format`, `wrong_pickup_code_usage`, `unknown_zone`, `invalid_time_intervals`, `unsupported_points_count`, `invalid_phone_incorrect_symbol`, `invalid_phone_must_start_plus_symbol`, `country_phone_code_not_supported`, `invalid_phone_size_incorrect`, `item_source_point_not_found`, `item_destination_point_not_found`, `invalid_destination_point`, `due_in_past`, `delay_too_long`, `external_order_id_not_allowed`, `address_outside_delivery_zone`, `invalid_buyout_point_type`, `payment_on_delivery_missed`, `payment_on_delivery_invalid_request`, `max_order_cost_exceeded`, `invalid_post_payment_payment_method`, `invalid_buyout_payment_method`, `invalid_source_point`, `invalid_point_phone`, `invalid_item_destination_point`, `invalid_item_source_point`, `different_cost_currencies`, `no_input_point`, `custom_context_in_bad_format` |
| _message_ (required) | **Type**: string<br><br>Сообщение об ошибке, понятное человеку<br><br>_Example:_ `Неправильное тело запроса` |

## 403 Forbidden <a id="403-forbidden"></a>

Ошибка идентификации или оплата при получении недоступна

### Body <a id="body3"></a>

**application/json**

```
{
  "code": "payment_on_delivery_disabled",
  "message": "Неправильное тело запроса"
}
```

|     |     |
| --- | --- |
| **Name** | **Description** |
| _code_ (required) | **Type**: string<br><br>Код ошибки<br><br>_Enum:_ `unknown_error`, `buyout_disabled`, `payment_on_delivery_disabled`, `forbidden_by_antifake` |
| _message_ (required) | **Type**: string<br><br>Сообщение об ошибке, понятное человеку<br><br>_Example:_ `Неправильное тело запроса` |

## 429 Too Many Requests <a id="429-too-many-requests"></a>

Слишком много созданных заявок за промежуток времени

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
