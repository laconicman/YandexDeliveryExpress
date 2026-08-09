# YandexDelivery (taxi) client library

Project is using [Swift OpenAPI Generator](https://github.com/apple/swift-openapi-generator), connected as plugin, so it semi-automatically regenerates the code to reflect changes made to OpenAPI specification in `openapi.yaml`.
Keep this in mind if you need to make changes to API related logic and feel free to propose pull requests.

> **Disclaimer:** This is unofficial project, build based on [the official doc](https://yandex.com/support/delivery-profile/ru/api/express/openapi/).
OpenAPI specification was as well build by the author of the project since no official one was provided even by requests.

## Overview

A library package that exposes generated (from OpenAPI specification) client as is. Allows to make all requests including cases where mutually exclusive parameters could be passed to endpoints.

Under the hood, the client uses the [URLSession](https://developer.apple.com/documentation/foundation/urlsession) API to perform the HTTP calls, wrapped in the [Swift OpenAPI URLSession Transport](https://github.com/apple/swift-openapi-urlsession).
For header mutation `HTTPTypes` is used.

## Regenerate code

Whenever the `openapi.yaml` document changes, rerun the code generation.
Open terminal at package folder and:
```console
% swift package generate-code-from-openapi
Plugin ‘OpenAPIGeneratorCommand’ wants permission to write to the package directory.
Stated reason: “To write the generated Swift files back into the source directory of the package.”.
Allow this plugin to write to the package directory? (yes/no) yes
...
✅ OpenAPI code generation for target 'CommandPluginInvocationClient' successfully completed.
```

## Usage

In another package or project, add this one as a package dependency.

Then, use the provided client API:

```swift
import YandexDeliveryExpressAPI

// TODO: provide example
```

For testing purposes you can use default `Credentials` `fromEnvironment` static var. In this case you need to set environment variables "APP_USERNAME" and "APP_PASSWORD". In Xcode you can set them with `Edit scheme` menu in Xcode.

## TODO:
 - Document main funcs

