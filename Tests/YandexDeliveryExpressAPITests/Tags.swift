import Testing

extension Tag {
    /// Talks to the real Yandex API. Needs `AUTH_TOKEN`, may create a real claim.
    /// Command-line escape hatch: `swift test --skip "Live API"`.
    @Tag static var live: Self

    /// Pins a claim `openapi.yaml` makes about the API. A failure means either the document
    /// is wrong or Yandex changed — see the `SpecOwnership` article.
    @Tag static var specContract: Self

    /// Pins a bug that shipped. Deleting one of these needs a reason.
    @Tag static var regression: Self
}
