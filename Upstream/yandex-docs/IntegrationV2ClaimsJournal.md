---
Source: https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsJournal
Captured: 2026-09-29
Title: "6.3 Журнал изменений - 6. Информация по заявкам | Яндекс Доставка"
SHA-256: 7997de970d3979a53dd204e35b44e1d123fd497d25efa2e714146e3331cc7abc
---

# Журнал изменений

Метод возвращает историю изменения заявки. Вы можете узнать об изменении статусов и цены заказа. Для терминальных статусов возвращается поле resolution, возможные значения success, failed.

## Request <a id="request"></a>

POST

```
b2b.taxi.yandex.net/b2b/cargo/integration/v2/claims/journal
```

Адрес сервиса

### Query parameters <a id="query-parameters"></a>

|     |     |
| --- | --- |
| **Name** | **Description** |
| _limit_ | **Type**: integer<br><br>Максимальное количество возвращаемых записей<br><br>_Default:_ `1000`<br><br>_Min value:_ `1`<br><br>_Max value:_ `1000` |

### Body <a id="body"></a>

**application/json**

```
{
  "cursor": "example"
}
```

|     |     |
| --- | --- |
| **Name** | **Description** |
| _cursor_ | **Type**: string<br><br>Строка с идентификатором последнего  <br>изменения. Если cursor  <br>не передан, то будут выданы все изменения  <br>с некоторым лимитом<br><br>_Example:_ `example` |

## Responses <a id="responses"></a>

## 200 OK <a id="200-ok"></a>

OK

### Body <a id="body1"></a>

**application/json**

```
{
  "cursor": "example",
  "events": [
    {
      "operation_id": 1,
      "claim_id": "3b8d1af142664fde824626a7c19e2bd9",
      "change_type": "status_changed",
      "updated_ts": "2020-01-01T00:00:00+00:00",
      "new_status": "new",
      "new_price": "20.00",
      "new_currency": "RUB",
      "resolution": "success",
      "revision": 1,
      "client_id": "95d010b2471041499b8cb1bfa282692f",
      "current_point_id": 372036854775807
    }
  ]
}
```

|     |     |
| --- | --- |
| **Name** | **Description** |
| _cursor_ (required) | **Type**: string<br><br>Идентификатор последнего изменения<br><br>_Example:_ `example` |
| _events_ (required) | **Type**: [Event](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsJournal#entity-Event)\[\]<br><br>**Example**<br><br>```<br>[<br>  {<br>    "operation_id": 1,<br>    "claim_id": "3b8d1af142664fde824626a7c19e2bd9",<br>    "change_type": "status_changed",<br>    "updated_ts": "2020-01-01T00:00:00+00:00",<br>    "new_status": "new",<br>    "new_price": "20.00",<br>    "new_currency": "RUB",<br>    "resolution": "success",<br>    "revision": 1,<br>    "client_id": "95d010b2471041499b8cb1bfa282692f",<br>    "current_point_id": 372036854775807<br>  }<br>]<br>``` |

### ClaimStatus <a id="entity-ClaimStatus"></a>

Статус заявки. Подробнее см. в разделе [Статусная модель](https://yandex.ru/support/delivery-profile/ru/api/express/claim-process)

**Type**: string

_Enum:_ `new`, `estimating`, `estimating_failed`, `ready_for_approval`, `accepted`, `performer_lookup`, `performer_draft`, `performer_found`, `performer_not_found`, `pickup_arrived`, `ready_for_pickup_confirmation`, `pickuped`, `delivery_arrived`, `ready_for_delivery_confirmation`, `delivered`, `delivered_finish`, `returning`, `return_arrived`, `ready_for_return_confirmation`, `returned`, `returned_finish`, `failed`, `cancelled`, `cancelled_with_payment`, `cancelled_by_taxi`, `cancelled_with_items_on_hands`

### ClaimStatusResolution <a id="entity-ClaimStatusResolution"></a>

Резолюция терминального статуса

**Type**: string

_Enum:_ `success`, `failed`

### ClaimPointId <a id="entity-ClaimPointId"></a>

Целочисленный идентификатор точки (int64), генерируемый
на стороне Яндекс Доставки.
Содержится в поле route\_points\[\].id. Применимо к точкам с типом
source, destination, return.

**Type**: integer

### Event <a id="entity-Event"></a>

Информация об изменении заказа

|     |     |
| --- | --- |
| **Name** | **Description** |
| _change\_type_ (required) | **Type**: string<br><br>Тип изменения. Возможные значения:<br><br>  <br>\- status\_changed — изменение статуса;  <br>\- price\_changed — изменение цены.<br><br>_Example:_ `status_changed` |
| _claim\_id_ (required) | **Type**: string<br><br>Идентификатор заявки claim\_id<br><br>_Example:_ `3b8d1af142664fde824626a7c19e2bd9` |
| _operation\_id_ (required) | **Type**: integer<br><br>Идентификатор операции (int64) |
| _revision_ (required) | **Type**: integer<br><br>Версия изменения заявки (int64) |
| _updated\_ts_ (required) | **Type**: string<date-time><br><br>Время события в формате ISO 8601<br><br>_Example:_ `2020-01-01T00:00:00+00:00` |
| _client\_id_ | **Type**: string<br><br>Идентификатор клиента<br><br>_Example:_ `95d010b2471041499b8cb1bfa282692f` |
| _current\_point\_id_ | **Type**: [ClaimPointId](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsJournal#entity-ClaimPointId)<br><br>Целочисленный идентификатор точки (int64), генерируемый  <br>на стороне Яндекс Доставки.  <br>Содержится в поле route\_points\[\].id. Применимо к точкам с типом  <br>source, destination, return.<br><br>_Example:_ `372036854775807` |
| _new\_currency_ | **Type**: string<br><br>Код валюты заказа<br><br>_Example:_ `RUB` |
| _new\_price_ | **Type**: string<br><br>Цена заказа<br><br>_Example:_ `20.00` |
| _new\_status_ | **Type**: [ClaimStatus](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsJournal#entity-ClaimStatus)<br><br>Статус заявки. Подробнее см. в разделе [Статусная модель](https://yandex.ru/support/delivery-profile/ru/api/express/claim-process)<br><br>_Enum:_ `new`, `estimating`, `estimating_failed`, `ready_for_approval`, `accepted`, `performer_lookup`, `performer_draft`, `performer_found`, `performer_not_found`, `pickup_arrived`, `ready_for_pickup_confirmation`, `pickuped`, `delivery_arrived`, `ready_for_delivery_confirmation`, `delivered`, `delivered_finish`, `returning`, `return_arrived`, `ready_for_return_confirmation`, `returned`, `returned_finish`, `failed`, `cancelled`, `cancelled_with_payment`, `cancelled_by_taxi`, `cancelled_with_items_on_hands` |
| _resolution_ | **Type**: [ClaimStatusResolution](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsJournal#entity-ClaimStatusResolution)<br><br>Резолюция терминального статуса<br><br>_Enum:_ `success`, `failed` |

**Example**

```
{
  "operation_id": 1,
  "claim_id": "3b8d1af142664fde824626a7c19e2bd9",
  "change_type": "status_changed",
  "updated_ts": "2020-01-01T00:00:00+00:00",
  "new_status": "new",
  "new_price": "20.00",
  "new_currency": "RUB",
  "resolution": "success",
  "revision": 1,
  "client_id": "95d010b2471041499b8cb1bfa282692f",
  "current_point_id": 372036854775807
}
```

## 400 Bad Request <a id="400-bad-request"></a>

BAD REQUEST

### Body <a id="body2"></a>

**application/json**

```
{
  "code": "unknown_error",
  "message": "Неправильный формат cursor"
}
```

|     |     |
| --- | --- |
| **Name** | **Description** |
| _code_ (required) | **Type**: string<br><br>Код ошибки<br><br>_Enum:_ `unknown_error`, `invalid_cursor` |
| _message_ (required) | **Type**: string<br><br>Описание ошибки<br><br>_Example:_ `Неправильный формат cursor` |

## 429 Too Many Requests <a id="429-too-many-requests"></a>

TOO MANY REQUESTS

### Body <a id="body3"></a>

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
