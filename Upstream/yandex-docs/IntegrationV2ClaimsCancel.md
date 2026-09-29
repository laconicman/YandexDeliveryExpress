---
Source: https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCancel
Captured: 2026-09-29
Title: "6. Отмена заявки - Базовые методы | Яндекс Доставка"
SHA-256: 875047eba4a0fcddf643bffca748b40acba04a6b1b87fdcf6ce08b472da92b7e
---

# Отмена заявки

Метод отменяет подтвержденную заявку. Отменить заявку с использованием этого метода можно до передачи товара курьеру. Далее отмена заказа возможна только через службу поддержки.

Отмена заявки может быть платной и бесплатной. Бесплатная отмена доступна до прибытия курьера на точку отправления, платная отмена доступна до начала движения по получению груза курьером. Чтобы узнать тип отмены, используйте операцию получения информации по заявке [claims/cancel-info](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCancelInfo) (поле cancel\_state).

В случае бесплатной отмены заявка перейдет в статус cancelled, в случае платной отмены - в статус cancelled\_with\_payment.

## Request <a id="request"></a>

POST

```
b2b.taxi.yandex.net/b2b/cargo/integration/v2/claims/cancel
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

### Body <a id="body"></a>

**application/json**

```
{
  "version": 1,
  "cancel_state": "free"
}
```

|     |     |
| --- | --- |
| **Name** | **Description** |
| _cancel\_state_ (required) | **Type**: [CancelState](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCancel#entity-CancelState)<br><br>Статус отмены (платная или бесплатная)<br><br>_Enum:_ `free`, `paid` |
| _version_ (required) | **Type**: integer<br><br>Версия отменяемой заявки (int64) |

### CancelState <a id="entity-CancelState"></a>

Статус отмены (платная или бесплатная)

**Type**: string

_Enum:_ `free`, `paid`

## Responses <a id="responses"></a>

## 200 OK <a id="200-ok"></a>

Заявка отменена

### Body <a id="body1"></a>

**application/json**

```
{
  "id": "741cedf82cd464fa6fa16d87155c636",
  "status": "new",
  "version": 1,
  "user_request_revision": "example",
  "skip_client_notify": true
}
```

|     |     |
| --- | --- |
| **Name** | **Description** |
| _id_ (required) | **Type**: [ClaimId](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCancel#entity-ClaimId)<br><br>Идентификатор(ID) заявки, полученный на этапе создания заявки<br><br>_Min length:_ `32`<br><br>_Max length:_ `64`<br><br>_Example:_ `741cedf82cd464fa6fa16d87155c636` |
| _skip\_client\_notify_ (required) | **Type**: boolean |
| _status_ (required) | **Type**: [ClaimStatus](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCancel#entity-ClaimStatus)<br><br>Статус заявки. Подробнее см. в разделе [Статусная модель](https://yandex.ru/support/delivery-profile/ru/api/express/claim-process)<br><br>_Enum:_ `new`, `estimating`, `estimating_failed`, `ready_for_approval`, `accepted`, `performer_lookup`, `performer_draft`, `performer_found`, `performer_not_found`, `pickup_arrived`, `ready_for_pickup_confirmation`, `pickuped`, `delivery_arrived`, `ready_for_delivery_confirmation`, `delivered`, `delivered_finish`, `returning`, `return_arrived`, `ready_for_return_confirmation`, `returned`, `returned_finish`, `failed`, `cancelled`, `cancelled_with_payment`, `cancelled_by_taxi`, `cancelled_with_items_on_hands` |
| _user\_request\_revision_ (required) | **Type**: string<br><br>Текущая версия изменений в заявке, переданная пользователем<br><br>_Example:_ `example` |
| _version_ (required) | **Type**: integer<br><br>Версия заявки из запроса (int64) |

### ClaimId <a id="entity-ClaimId"></a>

Идентификатор(ID) заявки, полученный на этапе создания заявки

**Type**: string

_Min length:_ `32`

_Max length:_ `64`

_Example:_ `741cedf82cd464fa6fa16d87155c636`

### ClaimStatus <a id="entity-ClaimStatus"></a>

Статус заявки. Подробнее см. в разделе [Статусная модель](https://yandex.ru/support/delivery-profile/ru/api/express/claim-process)

**Type**: string

_Enum:_ `new`, `estimating`, `estimating_failed`, `ready_for_approval`, `accepted`, `performer_lookup`, `performer_draft`, `performer_found`, `performer_not_found`, `pickup_arrived`, `ready_for_pickup_confirmation`, `pickuped`, `delivery_arrived`, `ready_for_delivery_confirmation`, `delivered`, `delivered_finish`, `returning`, `return_arrived`, `ready_for_return_confirmation`, `returned`, `returned_finish`, `failed`, `cancelled`, `cancelled_with_payment`, `cancelled_by_taxi`, `cancelled_with_items_on_hands`

## 400 Bad Request <a id="400-bad-request"></a>

Некорректный запрос

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
| _code_ (required) | **Type**: string<br><br>Код ошибки<br><br>_Enum:_ `unknown_error`, `bad_request` |
| _message_ (required) | **Type**: string<br><br>Описание ошибки<br><br>_Example:_ `Неправильное тело запроса` |

## 404 Not Found <a id="404-not-found"></a>

Заявка не найдена

### Body <a id="body3"></a>

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

## 409 Conflict <a id="409-conflict"></a>

Попытка отменить неактуальную версию заявки

### Body <a id="body4"></a>

**application/json**

```
{
  "code": "inappropriate_status",
  "message": "Недопустимое действие над заявкой"
}
```

|     |     |
| --- | --- |
| **Name** | **Description** |
| _code_ (required) | **Type**: string<br><br>Код ошибки<br><br>_Enum:_ `unknown_error`, `inappropriate_status`, `free_cancel_is_unavailable`, `state_mismatch` |
| _message_ (required) | **Type**: string<br><br>Описание ошибки<br><br>_Example:_ `Недопустимое действие над заявкой` |
