---
Source: https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCancelInfo
Captured: 2026-09-29
Title: "5. Условия отмены - Базовые методы | Яндекс Доставка"
SHA-256: ceef438a9f1eda3d3c94c5a24771ad444453b2c31343bba504a17fc5d8fb2019
---

# Условия отмены

Метод возвращает информацию о возможности отмены.
Используйте этот метод для получения информации по заявке, созданной через [claims/create](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate).

## Request <a id="request"></a>

POST

```
b2b.taxi.yandex.net/b2b/cargo/integration/v2/claims/cancel-info
```

Адрес сервиса

### Query parameters <a id="query-parameters"></a>

|     |     |
| --- | --- |
| **Name** | **Description** |
| _claim\_id_ (required) | **Type**: string<br><br>ID заявки, полученный на этапе создания заявки<br><br>_Min length:_ `32`<br><br>_Max length:_ `64`<br><br>_Example:_ \`\` |

### Headers <a id="headers"></a>

|     |     |
| --- | --- |
| **Name** | **Description** |
| _Accept-Language_ (required) | **Type**: string<br><br>Предпочитаемый язык ответа<br><br>Например:  <br>`ru` — русский  <br>`en` — английский<br><br>_Example:_ `ru` |

## Responses <a id="responses"></a>

## 200 OK <a id="200-ok"></a>

OK

### Body <a id="body"></a>

**application/json**

```
{
  "cancel_state": "free",
  "price": "12.50",
  "price_with_vat": null,
  "currency": "RUB"
}
```

|     |     |
| --- | --- |
| **Name** | **Description** |
| _cancel\_state_ (required) | **Type**: [CancelInfoCancelState](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCancelInfo#entity-CancelInfoCancelState)<br><br>Условия отмены<br><br>_Enum:_ `free`, `paid`, `unavailable` |
| _currency_ | **Type**: string<br><br>Валюта, в которой ведется расчет<br><br>_Example:_ `RUB` |
| _price_ | **Type**: [Money](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCancelInfo#entity-Money)<br><br>Стоимость доставки в формате десятичной дроби Decimal(18, 4)<br><br>_Pattern:_ `^-?[0-9]{1,14}(\.[0-9]{0,4})?$`<br><br>_Example:_ `12.50` |
| _price\_with\_vat_ | **Type**: [Money](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCancelInfo#entity-Money)<br><br>Стоимость доставки в формате десятичной дроби Decimal(18, 4)<br><br>_Pattern:_ `^-?[0-9]{1,14}(\.[0-9]{0,4})?$`<br><br>_Example:_ `12.50` |

### CancelInfoCancelState <a id="entity-CancelInfoCancelState"></a>

Условия отмены

**Type**: string

_Enum:_ `free`, `paid`, `unavailable`

### Money <a id="entity-Money"></a>

Стоимость доставки в формате десятичной дроби Decimal(18, 4)

**Type**: string

_Pattern:_ `^-?[0-9]{1,14}(\.[0-9]{0,4})?$`

_Example:_ `12.50`

## 400 Bad Request <a id="400-bad-request"></a>

Некорректный запрос

### Body <a id="body1"></a>

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
| _code_ (required) | **Type**: string<br><br>Код ошибки<br><br>_Enum:_ `unknown_error`, `bad_request` |
| _message_ (required) | **Type**: string<br><br>Описание ошибки<br><br>_Example:_ `Неправильное тело запроса` |

## 404 Not Found <a id="404-not-found"></a>

Заявка не найдена

### Body <a id="body2"></a>

**application/json**

```
{
  "code": "not_found",
  "message": "Заявка не найдена"
}
```

|     |     |
| --- | --- |
| **Name** | **Description** |
| _code_ (required) | **Type**: string<br><br>Код ошибки<br><br>_Enum:_ `unknown_error`, `not_found` |
| _message_ (required) | **Type**: string<br><br>Описание ошибки<br><br>_Example:_ `Заявка не найдена` |
