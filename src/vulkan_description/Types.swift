/// A Type tag contains information which can be used to generate C code
/// corresponding to the type. In many cases, this is simply legal C code,
/// with attributes or embedded tags denoting the type name and other types
/// used in defining this type. In some cases, additional attribute and
/// embedded type information is used to generate more complicated C types.
public struct `Type`: Equatable, Hashable {
  /// A type which indicates that this type contains a more complex structured
  /// definition. At present the only accepted categories are `basetype`,
  /// `bitmask`, `define`, `enum`, `funcpointer`, `group`, `handle`, `include`,
  /// `struct`, and `union`, as described below.
  public enum Category: Equatable, Hashable {
    case basetype
    case define
    case include
    case bitmask
    case `enum`
    case funcpointer
    case group
    /// - Parameter parent:
    ///   Notes another type with the `handle` category that acts as a parent
    ///   object for this type.
    /// - Parameter objtypeenum:
    ///   Specifies the name of a `VkObjectType` enumerant which
    ///   corresponds to this type. The enumerant must be defined.
    case handle(parent: String?, objtypeenum: String?) // FIXME: objtypeenum could be mandatory if we ignore aliases
    /// - Parameter returnedonly:
    ///   Notes that this struct/union is going to be filled in by the API,
    ///   rather than an application filling it out and passing it to the API.
    /// - Parameter structextends:
    ///   This is a comma-separated list of structures whose `pNext` can
    ///   include this type.
    ///   This should usually only list the top-level structure that is
    ///   extended, for all possible extending structures.
    ///   This will generate a validity statement on the top level structure
    ///   that validates the entire chain in one go, rather than each
    ///   extending structure repeating the list of valid structs.
    ///   There is no need to set the attr:noautovalidity attribute on
    ///   the `pNext` members of extending structures.
    /// - Parameter allowduplicate:
    ///    If `"true"`, then structures whose `pNext` chains include this
    ///    structure may include more than one instance of it.
    case `struct`(returnedOnly: Bool, structExtends: [String]?, allowDuplicate: Bool, members: [Member])

    /// - Parameter returnedonly:
    ///   Notes that this struct/union is going to be filled in by the API,
    ///   rather than an application filling it out and passing it to the API.
    /// - Parameter structextends:
    ///   This is a comma-separated list of structures whose `pNext` can
    ///   include this type.
    ///   This should usually only list the top-level structure that is
    ///   extended, for all possible extending structures.
    ///   This will generate a validity statement on the top level structure
    ///   that validates the entire chain in one go, rather than each
    ///   extending structure repeating the list of valid structs.
    ///   There is no need to set the attr:noautovalidity attribute on
    ///   the `pNext` members of extending structures.
    case union(returnedOnly: Bool, structExtends: [String]?, members: [Member])
  }

  /// This type describes how a value might be compared with the value of a
  /// member in order to check whether it fits the limit.
  public enum LimitType: String, Decodable, Equatable, Hashable {
    case min
    case max
    case bitmask
    case range
    case `struct`
    case noauto
    case exact
    case bits
    case minMul = "min,mul"
    case minPot = "min,pot"
    case maxPot = "max,pot"
  }

  /// The tag:member tag defines the type and name of a structure or union member.
  ///
  /// Example:
  ///
  /// ```xml
  /// <type category="struct"...>
  ///     <member><type>VkStructureType</type> <name>sType</name></member>
  ///     <member optional="true">struct <type>VkBaseOutStructure</type>* <name>pNext</name></member>
  /// </command>
  /// ```
  public struct Member: Decodable, Equatable, Hashable {
    /// Only valid on the `sType` member of a struct.
    /// This is a comma-separated list of enumerant values that are valid for
    /// the structure type; usually there is only a single value.
    let values: String?

    /// A list of enumerant values that are valid for the structure type.
    /// Usually there is only a single value.
    ///
    /// Example:
    /// ```xml
    /// <member values="VK_STRUCTURE_TYPE_APPLICATION_INFO"><type>VkStructureType</type> <name>sType</name></member>
    /// ```
    public var structureTypes: [String]? {
      values?.split(separator: ",").map(String.init)
    }

    /// If the member is an array, len may be one or more of the
    /// following things, separated by commas (one for each array indirection):
    /// another member of that struct; `"null-terminated"` for a string; `"1"`
    /// to indicate it is just a pointer (used for nested pointers); or an
    /// equation in math markup for incorporation in the specification (a LaTeX
    /// math expression delimited by `latexmath:[` and `]`.
    /// The only variables in the equation should be the names of members of the
    /// structure.
    public let len: String?

    /// If the attr:len attribute is specified, and contains a
    /// `latexmath:` equation, this attribute should be specified with an
    /// equivalent equation using only C builtin operators, C math library
    /// function names, and variables as allowed for attr:len.
    /// It must be a valid C99 expression whose result is equal to attr:len for
    /// all possible inputs.
    /// It is a comma separated list that has size equal to only the `latexmath`
    /// item count in attr:len list.
    /// This attribute is intended to support consumers of the XML who need to
    /// generate validation code from the allowed length.
    public let altlen: String?

    /// Denotes that the member should be externally
    /// synchronized when accessed by Vulkan
    public let externsync: String?

    /// A value of `"true"` or `"false"` determines whether this member can be
    /// omitted by providing `NULL` (for pointers), `VK_NULL_HANDLE` (for
    /// handles), or 0 (for other scalar types).
    /// If the member is a pointer to one of those types, multiple values may be
    /// provided, separated by commas - one for each pointer indirection.
    /// If not present, the value is assumed to be `"false"` (the member must
    /// not be omitted).
    /// Structure members with name `pNext` must always be specified with
    /// `optional="true"`, since there is no requirement that any member of a
    /// `pNext` chain have a following member in the chain.
    public let optional: String?

    /// Determines whether the member can be omitted.
    public var isOptional: Bool {
      optional == "true" || (optional?.hasPrefix("true,") ?? false)
    }

    /// If the member is a union, attr:selector identifies another member of the
    /// struct that is used to select which of that union's members are valid.
    public let selector: String?

    /// For a member of a union, attr:selection identifies a value of the
    /// attr:selector that indicates this member is valid.
    public let selection: String?

    /// Prevents automatic validity language being generated for the tagged item.
    /// Only suppresses item-specific validity - parenting issues etc.
    /// are still captured.
    /// It must also be used for structures that have no implicit validity when
    /// such structure has explicit validity.
    public let noautovalidity: String?

    /// only applicable for members of
    /// VkPhysicalDeviceProperties and VkPhysicalDeviceProperties2, their
    /// substrucutres, and extensions.
    /// Specifies the type of a device limit.
    /// This type describes how a value might be compared with the value of a
    /// member in order to check whether it fits the limit.
    /// Valid values:
    /// ** `"min"` and `"max"` denote minimum and maximum limits.
    ///    They may also apply to arrays and `VkExtent*D`.
    /// ** `"bitmask"` corresponds to bitmasks and `VkBool32`, where set bits
    ///    indicate the presence of a capability
    /// ** `"range"` specifies a [min, max] range
    /// ** `"struct"` means that the member's fields should be compared.
    /// ** `"noauto"` limits can't be trivially compared.
    ///    This is the default value, if unspecified.
    public let limittype: LimitType?

//    The text elements of a tag:member tag, with all other tags removed, is a
//    legal C declaration of a struct or union member.
//    In addition it may contain several semantic tags:

    /// It contains text which is a valid type name found in another tag:type
    /// tag, and indicates that this type must be previously defined for the
    /// definition of the command to succeed.
    /// Builtin C types should not be wrapped in tag:type tags.
    ///
    /// Example:
    ///
    /// ```xml
    /// <member><type>VkStructureType</type> <name>sType</name></member>
    /// ```
    public let type: String?

    /// Contains the struct/union member name being described.
    public let name: String

    /// It contains text which is a valid enumerant name found in another
    /// tag:type tag, and indicates that this enumerant must be previously
    /// defined for the definition of the command to succeed.
    /// Typically this is used to semantically tag static array lengths.
    ///
    /// Example:
    ///
    /// ```xml
    /// <member><type>VkPhysicalDevice</type>
    ///     <name>physicalDevices</name>[<enum>VK_MAX_DEVICE_GROUP_SIZE</enum>]
    /// </member>
    /// ```
    public let `enum`: String?

    /// Contains an arbitrary string (unused).
    public let comment: Comment?
  }

  /// Another type name this type requires to complete its definition.
  public let requires: String?

  /// Name of this type (if not defined in the tag body).
  /// 
  /// Name is by definition an optional attribute and optional in the body,
  /// but in either case it has to be defined - so it is mandatory here (as both
  /// gets evaluated on decoding).
  public let name: String

  /// Another type name which this type is an alias of.
  ///
  /// Must match the name of another type element. This is typically used
  /// when promoting a type defined by an extension to a new core version of
  /// the API. The old extension type is still defined, but as an alias of the
  /// new type.
  public let alias: String?

  /// API name for which this definition is specialized, so that different APIs
  /// may have different definitions for the same type.
  public let api: String?

  /// A string which indicates that this type contains a more complex
  /// structured definition.
  public let category: Category?

  /// Arbitrary string (unused).
  public let comment: Comment?
}

// MARK: - Conformance to Decodable
extension `Type`: Decodable {
  /// Coding keys for any type
  enum CodingKeys: String, CodingKey {
    case requires
    case name
    case alias
    case api
    case category
    case comment
  }
  /// Coding keys specific to handle types
  enum HandleCodingKeys: String, CodingKey {
    case parent
    case objtypeenum
  }
  /// Coding keys specific to struct types
  enum StructCodingKeys: String, CodingKey {
    case returnedonly
    case structextends
    case allowduplicate
    case member
  }
  /// Coding keys specific to union types
  enum UnionCodingKeys: String, CodingKey {
    case returnedonly
    case structextends
    case member
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    requires = try container.decodeIfPresent(String.self, forKey: .requires)
    name = try container.decode(String.self, forKey: .name)
    alias = try container.decodeIfPresent(String.self, forKey: .alias)
    api = try container.decodeIfPresent(String.self, forKey: .api)
    comment = try container.decodeIfPresent(String.self, forKey: .comment)

    let categoryString = try container.decodeIfPresent(String.self, forKey: .category)
    switch categoryString {
    case .none: category = nil // Category is optional
    case "basetype": category = .basetype
    case "define": category = .define
    case "include": category = .include
    case "bitmask": category = .bitmask
    case "enum": category = .enum
    case "funcpointer": category = .funcpointer
    case "group": category = .group
    case "handle":
      let container = try decoder.container(keyedBy: HandleCodingKeys.self)
      category = .handle(
        parent: try container.decodeIfPresent(String.self, forKey: .parent),
        objtypeenum: try container.decodeIfPresent(String.self, forKey: .objtypeenum)
      )
    case "struct":
      let container = try decoder.container(keyedBy: StructCodingKeys.self)
      category = .struct(
        returnedOnly: try container.decodeIfPresent(String.self, forKey: .returnedonly) == "true",
        structExtends: try container
          .decodeIfPresent(String.self, forKey: .structextends)?
          .split(separator: ",").map(String.init),
        allowDuplicate: try container.decodeIfPresent(String.self, forKey: .allowduplicate) == "true",
        members: try container.decode([Member].self, forKey: .member)
      )
    case "union":
      let container = try decoder.container(keyedBy: UnionCodingKeys.self)
      category = .union(
        returnedOnly: try container.decodeIfPresent(String.self, forKey: .returnedonly) == "true",
        structExtends: try container
          .decodeIfPresent(String.self, forKey: .structextends)?
          .split(separator: ",").map(String.init),
        members: try container.decode([Member].self, forKey: .member)
      )
    default:
      throw DecodingError.dataCorruptedError(
        forKey: .category,
        in: container,
        debugDescription: "Found invalid coding key: \(categoryString!)")
    }
  }
}

// MARK: - Conformance to CustomStringConvertible & CustomDebugStringConvertible
// FIXME: Implement!
