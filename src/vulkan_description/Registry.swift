/// The Registry contains the entire definition of one or more related APIs.
public struct Registry: Equatable, Hashable {
  /// Contains arbitrary text, such as a copyright statement.
  public let comments: [Comment]

  /// Platforms are wrapped inside a node that has only a comment as attribute.
  /// This comment is stripped from the public API surface and only the actual
  /// `platforms` are exposed - see below. It is stored and decoded however, so
  /// the information is not lost when the registry is used for encoding.
  fileprivate let _platforms: Platforms

  /// Platform names corresponding to platform-specific API extensions.
  public var platforms: [Platform] { _platforms.platform }

  /// Tags are wrapped inside a node that has only a comment as attribute.
  /// This comment is stripped from the public API surface and only the actual
  /// `tags` are exposed - see below. It is stored and decoded however, so
  /// the information is not lost when the registry is used for encoding.
  fileprivate let _tags: Tags

  /// Author IDs used for extensions and layers.
  ///
  /// Author IDs are described in detail in the "`Layers & Extensions`" section
  /// of the "`Vulkan Documentation and Extensions: Procedures and Conventions`"
  /// document.
  public var tags: [Tag] { _tags.tag }

  /// Types are wrapped inside a node that has only a comment as attribute.
  /// This comment is stripped from the public API surface and only the actual
  /// `types` are exposed - see below. It is stored and decoded however, so
  /// the information is not lost when the registry is used for encoding.
  fileprivate let _types: Types

  /// API types.
  ///
  /// Usually only one tag is used.
  public var types: [Typedef] { _types.type }

  /// API token names and values.
  ///
  /// Usually multiple tags are used. Related groups may be tagged as an
  /// enumerated type corresponding to a `Type`, and resulting in a C
  /// `enum` declaration. This ability is heavily used in the Vulkan API.
  public let constants: [Constants]

  /// Commands are wrapped inside a node that has only a comment as attribute.
  /// This comment is stripped from the public API surface and only the actual
  /// `commands` are exposed - see below. It is stored and decoded however, so
  /// the information is not lost when the registry is used for encoding.
  fileprivate let _commands: Commands

  /// API commands (functions).
  ///
  /// Usually only one tag is used.
  public var commands: [Command] { _commands.command }

  /// API feature interfaces (API versions, more or less).
  ///
  /// One tag per feature set.
  public let features: [Feature]

  /// Extensions are wrapped inside a node that has only a comment as attribute.
  /// This comment is stripped from the public API surface and only the actual
  /// `extensions` are exposed - see below. It is stored and decoded however, so
  /// the information is not lost when the registry is used for encoding.
  fileprivate let _extensions: Extensions

  /// API extension interfaces.
  ///
  /// Usually only one tag is used, wrapping many extensions.
  public var extensions: [Extension] { _extensions.extension }
}

// MARK: - Conformance to Decodable
extension Registry: Decodable {
  // The coding path of the registry internally preserves the structure
  // of the actual XML, altough a lot of it does look different on the
  // actual public API surface. This guarantees that, when put back into,
  // an encoder, it does not change to layout while it gives the API
  // consumer a nice Swift interface to work with.
  private enum CodingKeys: String, CodingKey {
    case comments = "comment"
    case _platforms = "platforms"
    case _tags = "tags"
    case _types = "types"
    case constants = "enums" // See `Constants` header documentation
    case _commands = "commands"
    case features = "feature"
    case _extensions = "extensions"
  }

  // MARK: (Hidden) Nested Structs

  /// Platform Name Blocks (tag:platforms tag)
  ///
  /// A tag:platforms contains descriptions of platform IDs for platforms
  /// supported by window system-specific extensions to Vulkan.
  ///
  /// == Attributes of tag:platforms tags
  ///
  ///   * attr:comment - optional. Arbitrary string (unused).
  ///
  /// == Contents of tag:platforms tags
  ///
  /// Zero or more tag:platform tags, in arbitrary order (though they are
  /// typically ordered by sorting on the platform name).
  fileprivate struct Platforms: Decodable, Equatable, Hashable {
    let comment: Comment?
    let platform: [Platform]
  }

  /// = Author ID Blocks (tag:tags tag)
  ///
  /// A tag:tags tag contains tag:authorid tags describing reserved author IDs
  /// used by extension and layer authors.
  ///
  /// == Attributes of tag:tags tags
  ///
  ///   * attr:comment - optional. Arbitrary string (unused).
  ///
  /// == Contents of tag:tags tags
  ///
  /// Zero or more tag:tag tags, in arbitrary order (though they are typically
  /// ordered by sorting on the author ID).
  fileprivate struct Tags: Decodable, Equatable, Hashable {
    let comment: Comment?
    let tag: [Tag]
  }

  /// = API Type Blocks (tag:types tag)
  ///
  /// A tag:types tag contains definitions of derived types used in the API.
  ///
  /// == Attributes of tag:types tags
  ///
  ///   * attr:comment - optional. Arbitrary string (unused).
  ///
  /// == Contents of tag:types tags
  ///
  /// Zero or more tag:type and tag:comment tags, in arbitrary order (though
  /// they are typically ordered by putting dependencies of other types earlier
  /// in the list).
  /// The tag:comment tags are used mostly to indicate grouping of related types
  fileprivate struct Types: Decodable, Equatable, Hashable {
    let comment: Comment?
    let type: [Typedef]
  }

  /// = Command Blocks (tag:commands tag)
  ///
  /// The tag:commands tag contains definitions of each of the functions
  /// (commands) used in the API.
  ///
  /// == Attributes of tag:commands tags
  ///
  ///   * attr:comment - optional. Arbitrary string (unused).
  ///
  /// == Contents of tag:commands tags
  ///
  /// Each tag:commands block contains zero or more tag:command tags, in
  /// arbitrary order (although they are typically ordered by sorting on the
  /// command name, to improve human readability).
  fileprivate struct Commands: Decodable, Equatable, Hashable {
    let comment: Comment?
    let command: [Command]
  }

  /// = Extension Blocks (tag:extensions tag)
  ///
  /// The tag:extensions tag contains definitions of each of the extenions
  /// which are defined for the API.
  ///
  /// == Attributes of tag:extensions tags
  ///
  ///   * attr:comment - optional. Arbitrary string (unused).
  ///
  /// == Contents of tag:extensions tags
  ///
  /// Each tag:extensions block contains zero or more tag:extension tags,
  /// each describing an API extension, in arbitrary order (although they are
  /// typically ordered by sorting on the extension name, to improve human
  /// readability).
  fileprivate struct Extensions: Decodable, Equatable, Hashable {
    let comment: Comment?
    let `extension`: [Extension]
  }
}

// MARK: - Conformance to CustomStringConvertible & CustomDebugStringConvertible
// FIXME: Implement!
