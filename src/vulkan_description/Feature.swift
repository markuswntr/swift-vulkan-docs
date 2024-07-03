// FIXME:  Features are not fully done yet - see commented vars in body

/// API Features and Versions (tag:feature tag)
///
/// API features are described in individual tag:feature tags. A feature is
/// the set of interfaces (enumerants and commands) defined by a particular API
/// and version, such as Vulkan 1.0, and includes all profiles of that API and
/// version.
///
/// **Attributes:** api, name, number, sortorder, protect, comment
///
/// **Contents:** Zero or more `require, remove` tags, in arbitrary order.
/// Each tag describes a set of interfaces that is respectively required
/// for, or removed from, this feature, as described below.
///
/// Example:
/// -
///
/// ```xml
/// <feature api="vulkan" name="VK_VERSION_1_0" number="1.0">
///     <require comment="Header boilerplate">
///         <type name="vk_platform"/>
///     </require>
///     <require comment="API constants">
///         <enum name="VK_MAX_PHYSICAL_DEVICE_NAME"/>
///         <enum name="VK_LOD_CLAMP_NONE"/>
///     </require>
///     <require comment="Device initialization">
///         <command name="vkCreateInstance"/>
///     </require>
/// </feature>
/// ```
///
/// Note:
/// -
/// The `name` attribute used for Vulkan core versions, such as
/// `"VK_VERSION_1_0"`, is not an API construct.
/// It is used only as a preprocessor guard in the headers, and an asciidoctor
/// conditional in the specification sources.
/// The similar `"VK_API_VERSION_1_0"` symbols are part of the API and their
/// values are packed integers containing Vulkan core version numbers.
public struct Feature: Decodable, Equatable, Hashable {
  /// The API this feature targets (vulkan or vulkansc, or both)
  public enum API: String, CaseIterable, Hashable {
    /// Indicates a vulkansc feature
    case vulkansc
    /// Indicates a vulkan feature
    case vulkan
  }


  // MARK: Attributes

  /// Required API names this feature is defined for, such as `vulkan`.
  internal let api: String
  public var apis: [API] {
    api.split(separator: ",").map { API(rawValue: String($0))! }
  }

  /// Version name, used as the C preprocessor token under which the version's
  /// interfaces are protected against multiple inclusion.
  /// Example: `"VK_VERSION_1_0"`
  public let name: String

  /// Feature version number, usually a string intepreted as
  /// `majorNumber.minorNumber`. Example: `4.2`.
  public let number: String

  /// attr:comment - optional. Arbitrary string (unused).
  public var comment: String?

//  * attr:sortorder - optional. A decimal number which specifies an order
//    relative to other tag:feature tags when calling output generators.
//    Defaults to `0`. Rarely used, for when ordering by attr:name is
//    insufficient.
//  * attr:protect - optional. An additional preprocessor token used to
//    protect a feature definition. Usually another feature or extension
//    attr:name. Rarely used, for odd circumstances where the definition
//    of a feature or extension requires another to be defined first.

  // MARK: Contents

//  Zero or more <<tag-required,tag:require and tag:remove tags>>, in arbitrary
//  order. Each tag describes a set of interfaces that is respectively required
//  for, or removed from, this feature, as described below.

  /// The definitions that are added to the API surface through this extension
  public let require: [Extension.Definitions]?
}

// MARK: - Conformance to CustomStringConvertible & CustomDebugStringConvertible
// FIXME: Implement!

