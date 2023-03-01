/// A Tag contains information defining a single author ID.
public struct Tag: Decodable, Equatable, Hashable {
  /// The author ID, as registered with Khronos.
  ///
  /// A short, upper-case string, usually an abbreviation of an author,
  /// project or company name.
  public let name: String

  /// The author name, such as a full company or project name.
  public let author: String

  /// The contact who registered or is currently responsible for extensions
  /// and layers using the ID, including sufficient contact information to
  /// reach the contact such as individual name together with email address,
  /// Github username, or other contact information.
  public let contact: String
}

// MARK: - Conformance to CustomStringConvertible & CustomDebugStringConvertible
// FIXME: Implement!
