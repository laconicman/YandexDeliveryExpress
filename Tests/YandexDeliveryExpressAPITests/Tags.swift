import Testing

extension Tag {
    /// Talks to the real Yandex API. Needs `AUTH_TOKEN`, may create a real claim.
    /// Command-line escape hatch: `swift test --skip "Live API"`.
    @Tag static var live: Self

    /// Pins a claim `openapi.yaml` makes about the API. A failure means either the document
    /// is wrong or Yandex changed — see the `SpecOwnership` article.
    @Tag static var specContract: Self

    /// Changes server-side state — creates a claim that a real account will see. Needs
    /// `YDE_ALLOW_MUTATING_LIVE_TESTS=1` **on top of** `AUTH_TOKEN`, so that pointing a
    /// token at this suite is never enough on its own.
    @Tag static var mutating: Self

    /// Asks the API what it actually sends, rather than asserting what we believe. These
    /// tests *record* — attachments and warnings — and fail only when the client breaks.
    /// They are how `WorkingWithYandex` gets written.
    @Tag static var exploration: Self

    /// Pins a bug that shipped. Deleting one of these needs a reason.
    @Tag static var regression: Self
}
