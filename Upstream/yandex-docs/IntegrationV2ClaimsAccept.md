---
Source: https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsAccept
Captured: 2026-09-29
Title: "3. Подтверждение заявки - Базовые методы | Яндекс Доставка"
SHA-256: 8399470384520ad173dc14ca982781379cf20d68df243a503db21c6be07ac5d9
---

# Подтверждение заявки

Метод подтверждает заявку, если она успешно прошла оценку. После подтверждения заявка перейдет в статус accepted, и сервис запустит процесс поиска исполнителя.

Предложение pricing.offer действительно в течение ограниченного времени (10 минут).
По истечении этого времени, при попытке подтверждения заказ перейдет в статус failed.

## Request <a id="request"></a>

POST

```
b2b.taxi.yandex.net/b2b/cargo/integration/v2/claims/accept
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
  "version": 1
}
```

|     |     |
| --- | --- |
| **Name** | **Description** |
| _version_ (required) | **Type**: integer<br><br>Версия заявки. Изменяется после редактирования заявки (int64) |

## Responses <a id="responses"></a>

## 200 OK <a id="200-ok"></a>

Заявка подтверждена

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
| _id_ (required) | **Type**: [ClaimId](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsAccept#entity-ClaimId)<br><br>Идентификатор(ID) заявки, полученный на этапе создания заявки<br><br>_Min length:_ `32`<br><br>_Max length:_ `64`<br><br>_Example:_ `741cedf82cd464fa6fa16d87155c636` |
| _skip\_client\_notify_ (required) | **Type**: boolean |
| _status_ (required) | **Type**: [ClaimStatus](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsAccept#entity-ClaimStatus)<br><br>Статус заявки. Подробнее см. в разделе [Статусная модель](https://yandex.ru/support/delivery-profile/ru/api/express/claim-process)<br><br>_Enum:_ `new`, `estimating`, `estimating_failed`, `ready_for_approval`, `accepted`, `performer_lookup`, `performer_draft`, `performer_found`, `performer_not_found`, `pickup_arrived`, `ready_for_pickup_confirmation`, `pickuped`, `delivery_arrived`, `ready_for_delivery_confirmation`, `delivered`, `delivered_finish`, `returning`, `return_arrived`, `ready_for_return_confirmation`, `returned`, `returned_finish`, `failed`, `cancelled`, `cancelled_with_payment`, `cancelled_by_taxi`, `cancelled_with_items_on_hands` |
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

## 409 Conflict <a id="409-conflict"></a>

Попытка подтвердить заявку, которая не прошла оценку

### Body <a id="body3"></a>

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
| _code_ (required) | **Type**: string<br><br>Код ошибки<br><br>_Enum:_ `unknown_error`, `inappropriate_status`, `invalid_post_payment`, `old_version`, `offer_expired`, `state_mismatch`, `offer_already_used` |
| _message_ (required) | **Type**: string<br><br>Описание ошибки<br><br>_Example:_ `Недопустимое действие над заявкой` |

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
