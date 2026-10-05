# Questions for Yandex Delivery support — 2026-10

Open questions the public API pages ([`yandex-docs/`](yandex-docs/README.md)) don't answer,
written for Yandex Delivery's support team. Each one states what the pages already say, so
the answer can be specific. The ledger at the end records each answer against the
tech-debt item it would settle: package `TD-n`, or YDelivery's `YD-n`.

How to use it:

1. Send the message below verbatim. It's in Russian, the language support works in.
2. Record each answer in the ledger with its date and channel (ticket number, chat).
3. Weigh an answer as testimony, not proof. Rule 11 in `CLAUDE.md` still applies: the wire
   behaviour that works is replicated, and a support answer that contradicts a live call
   is a new question, not a fix. An answer settles a TD item only with the live check
   its discharge names.

## The message

**Тема: API Express (B2B Cargo) v2 — классы доставки и создание заявки**

Мы интегрируемся с API Яндекс Доставки Express (v2: `offers/calculate`, `claims/create`,
`claims/accept`, `claims/info`, `claims/search`). Ниже вопросы, на которые не нашли ответа в
публичной документации API.

**А. Классы доставки (`taxi_class`)**

1. **`sdd_long`.** Что это за класс? На страницах API (`offers/calculate`, `claims/create`,
   `claims/info`, `claims/search`) его нет: там перечислены «courier, express, cargo,
   sdd_multislot». Присылает ли API это значение сейчас? Если да: какой транспорт,
   ограничения веса и габаритов, сроки, чем отличается от `cargo`?
2. **`sdd_multislot` («В течение дня»).** В описании `claims/create` сказано: «Тариф
   доставки в течение дня недоступен в России». В каких странах и городах он доступен?
   Может ли `offers/calculate` вернуть этот класс для аккаунта, зарегистрированного в
   России?
3. **`superexpress_d2d` («Быстрее»).** Мы видим его в новостях кабинета, но не в
   документации API. Когда он там появится? Какие у него ограничения веса и габаритов, в
   каких городах он доступен? Отличается ли создание заявки от `express`?
4. **Полный список значений.** Есть ли актуальный полный список `taxi_class` и способ
   узнавать о новых значениях заранее (changelog, рассылка для интеграторов)? Даёт ли метод
   `tariffs` полный список для точки? Новое значение без предупреждения ломает разбор ответа
   у клиентов со строгим перечнем значений.
5. **Ограничения по классам.** Опубликованные значения (courier до 10 кг, express до 20 кг,
   cargo 300–2000 кг) одинаковы во всех городах? Является ли `tariffs`
   (`supported_requirements`) авторитетным источником для конкретной точки?

**Б. Создание заявки по офферу**

6. **`offer_payload` и `client_requirements.taxi_class`.** Если в `claims/create` переданы
   оба и класс в них расходится, что применяется? Фиксирует ли payload класс, цену и
   интервалы? Нужно ли передавать `client_requirements` вместе с `offer_payload`, ведь
   `taxi_class` там обязателен?
7. **`same_day_data.delivery_interval`.** Откуда берётся интервал: из ответа
   `offers/calculate` (`pickup_interval` / `delivery_interval`), из отдельного метода
   (какого?) или его задаёт клиент? Применим ли `offer_payload` к заявке с `same_day_data`?
   Можно ли узнать цену такой доставки до создания заявки?
8. **Ответ на неверный путь.** Заявка «в течение дня», созданная с `client_requirements`,
   всегда получает `400 sdd_client_requirements_forbidden`? Или возможны другие ответы?

**В. Прочее**

9. **`description` оффера** (`express`, `express_30min_longer`, `2_hours_delivery`, …).
   Есть ли справочник значений и их смысла? Мы хотим показывать отправителю, чем
   отличаются офферы одного класса.
10. **Окно `due`.** В документации сказано: для `express` 30–240 минут вперёд, для `cargo`
    до пяти дней. Это актуально? Какие окна у `courier` и `superexpress_d2d`?
11. **Цена в `cancel-info`.** `price` / `price_with_vat` описаны как «Стоимость доставки».
    При платной отмене списывается эта сумма или отдельный штраф?

## Ledger

| # | Settles | Sent | Answer (date, channel) |
|---|---|---|---|
| 1 | YDelivery YD-36 | — | — |
| 2 | TD-25, YDelivery YD-37 | — | — |
| 3 | The `TaxiClass` row in [TechDebt](../Sources/YandexDeliveryExpressAPI/YandexDeliveryExpressAPI.docc/TechDebt.md)'s enum table | — | — |
| 4 | The `TaxiClass` row; the 2026-08-17 "enums stay closed" decision | — | — |
| 5 | [Roadmap](../Sources/YandexDeliveryExpressAPI/YandexDeliveryExpressAPI.docc/Roadmap.md) → `tariffs` (YDelivery's static limits) | — | — |
| 6 | The `TaxiClass` row's open question (send the raw spelling) | — | — |
| 7 | TD-25, YDelivery YD-37 | — | — |
| 8 | TD-25 | — | — |
| 9 | YDelivery YD-32 | — | — |
| 10 | TD-21 | — | — |
| 11 | TD-22 | — | — |
