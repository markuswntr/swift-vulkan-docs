/// A Platform describes a single platform name.
///
/// Example:
/// -
/// ```xml
/// <platform
///     name="xlib"
///     protect="VK_USE_PLATFORM_XLIB_KHR"
///     comment="X Window System, Xlib client library"/>
/// ```
public struct Platform: Decodable, Equatable, Hashable {
  /// The platform name.
  ///
  /// This must be a short alphanumeric string corresponding to the platform
  /// name, valid as part of a C99 identifier. Lower-case is preferred.
  ///
  /// In some cases, it may be desirable to distinguish a subset of platform
  /// functionality from the entire platform.
  /// In these cases, the platform name should begin with the entire platform
  /// name, followed by `_` and the subset name.
  public let name: String

  /// This must be a C99 preprocessor token beginning with `VK_USE_PLATFORM_`
  /// followed by the platform name, converted to upper case, followed by `_`
  /// and the extension suffix of the corresponding window system-specific
  /// extension supporting the platform.
  public let protect: String

  /// Arbitrary string (unused).
  public let comment: Comment?
}

// MARK: - Conformance to CustomStringConvertible & CustomDebugStringConvertible
// FIXME: Implement!
