---
Source: https://yandex.ru/support/delivery-profile/ru/api/express/claim-process
Captured: 2026-09-29
Title: "Статусная модель | Яндекс Доставка"
SHA-256: de91077c0b956e977cd272e5e5f6dbecb68138dc72b3c1b8e2dadfb8ce6a9085
---

В данном разделе рассматриваются:

-   этапы, которые проходит заявка на доставку в процессе обработки;

-   методы АPI, доступные на конкретной стадии заказа и изменяющие его состояние.

## Схема выполнения заказа <a id="create"></a>

![Схема формирования заказа1](https://yastatic.net/s3/doc-binary/src/support/delivery-profile/ru/img/status-process.png)

## Описание статусов <a id="opisanie-statusov"></a>

|     |     |     |
| --- | --- | --- |
| **Статус** | **Описание** | **Основные методы** |
| `new` | Создана новая заявка. | [Создание заявки](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate) |
| `estimating` | Идет процедура оценки заявки: подбор типа автомобиля по параметрам товара и расчет стоимости.<br><br>Чтобы узнать результат оценки, выполните запрос [Получение информации по заявке](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsInfo). | [Получение информации по заявке](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsInfo) |
| `ready_for_approval` | Заявка успешно оценена и ожидает подтверждения.<br><br>Подтвердите заявку в течение 10 минут после присвоения заявке статуса `ready_for_approval`.  <br>Если вы не согласны со стоимостью и условиями доставки, попробуйте изменить параметры заявки. После редактирования заявка автоматически отправится на переоценку. | [Подтверждение заявки](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsAccept)<br><br>[Редактирование заявки](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsEdit) |
| `accepted` | Заявка подтверждена.<br><br>Если вы не успели подтвердить заявку по истечении 10 минут с момента присвоения заявке статуса `ready_for_approval`, в ответ на подтверждение заявки вернется статус `failed`. В таком случае создайте новую заявку. | [Подтверждение заявки](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsAccept)<br><br>[Создание заявки](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsCreate) |
| `performer_lookup` | После подтверждения заявки формируется заказ, которому присваивается `route_id`. Начинается поиск курьера. | [Получение информации по заявке](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsInfo) |
| `performer_draft` | Производится поиск курьера в соответствии с указанными в заявке требованиями. | [Получение информации по заявке](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsInfo) |
| `performer_found` | Курьер найден и едет к отправителю (точка **А**).<br><br>С этого момента и до завершения заказа вы можете запрашивать следующую информацию:<br><br>  <br>\- Данные о курьере и транспортном средстве (поле `performer_info` в ответе на запрос [Получение информации по заявке](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsInfo)).  <br>\- Номер телефона курьера. Если курьер будет заменен по какой-либо причине, перезапросите номер телефона.  <br>\- Координаты текущего местоположения курьера. | [Получение информации по заявке](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsInfo)<br><br>[Получение номера телефона курьера](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2DriverVoiceForwarding)<br><br>[Получение позиции исполнителя заявки](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsPerformerPosition) |
| `pickup_arrived` | Курьер приехал в точку **А**, чтобы забрать заказ. | [Получение информации по заявке](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsInfo) |
| `ready_for_pickup_confirmation` | Курьер ждет, когда отправитель назовет ему код подтверждения (статус актуален только при `skip_confirmation = false`).<br><br>Код генерируется автоматически после того, как курьер сообщит системе, что он прибыл к отправителю. Получить код можно в личном кабинете, по СМС или с помощью метода API. | [Получение кода подтверждения](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsConfirmationCode) |
| `pickuped` | Курьер вводит код подтверждения в систему. Передача товара курьеру подтверждена. Запрос [Получение информации по заявке](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsInfo) вернет информацию о посещении точки в поле `visit_status`. | [Получение информации по заявке](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsInfo) |
| `delivery_arrived` | Курьер приехал к получателю (точка **Б**).<br><br>Курьер пытается дозвониться до получателя в течение 10 минут. Если получатель не отвечает, товар будет возвращен отправителю. | —   |
| `ready_for_delivery_confirmation` | Курьер сообщает системе, что готов передать товар получателю. Автоматически генерируется код подтверждения и отправляется получателю по СМС. Получатель должен сообщить этот код курьеру. | —   |
| `pay_waiting` | Заказ ожидает оплаты (статус актуален, если в параметрах заказа выбрана оплата при получении). | —   |
| `delivered` | Курьер вводит код подтверждения в систему и передает товар получателю. Доставка подтверждена.<br><br>Если в заказе несколько точек, курьер отправляется к следующему получателю. | —   |
| `delivered_finish` | Заказ завершен, курьер доставил товары всем получателям в заказе. | —   |
| `returning` | Если хотя бы один товар в заказе невозможно передать получателю, курьер возвращает товар.<br><br>По умолчанию точка возврата совпадает с точкой **А**, при необходимости можно указать другой адрес возврата. | —   |
| `return_arrived` | Курьер приехал в точку возврата. | —   |
| `ready_for_return_confirmation` | Курьер ждет, когда отправитель в точке возврата назовет код подтверждения.<br><br>Код генерируется автоматически после того как курьер сообщит системе, что он прибыл на точку возврата. Получить этот код можно через личный кабинет, СМС или с помощью метода API. | [Получение кода подтверждения](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsConfirmationCode) |
| `returned` | Курьер ввел код подтверждения в систему и вернул товар отправителю. Возврат товара подтвержден. | —   |
| `returned_finish` | Заказ завершен с возвратом товара. | —   |

## Статусы при отмене заказа <a id="cancel"></a>

|     |     |
| --- | --- |
| `cancelled_by_taxi` | Заказ отменен курьером. Курьер может отменить заказ до момента, пока не получил товар от отправителя (статус `pickuped`). |
| `cancelled` | Заказ отменен бесплатно. |
| `cancelled_with_payment` | Заказ отменен платно с возвратом товара. |
| `cancelled_with_items_on_hands` | Заказ отменен платно без возврата товара (заявка была создана с флагом `optional_return`). |

## Статусы ошибок <a id="errors"></a>

|     |     |
| --- | --- |
| `failed` | При выполнении заказа произошла ошибка, дальнейшее выполнение невозможно. |
| `estimating_failed` | Не удалось оценить заявку. Узнать причину можно по запросу [Получение информации по заявке](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsInfo): причина будет указана в ответе в поле `error_messages`.<br><br>Отредактируйте заявку с помощью метода [Редактирование заявки](https://yandex.ru/support/delivery-profile/ru/api/express/openapi/IntegrationV2ClaimsEdit), и процесс оценки запустится снова. |
| `performer_not_found` | Не удалось найти курьера. Попробуйте создать новую заявку через некоторое время. |
