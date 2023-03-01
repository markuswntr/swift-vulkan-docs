/// Constants contain individual `Constant`s describing each of the token names
/// used in the API. In some cases these correspond to a C `enum` or `bitmask`,
/// and in some cases they are simply compile time constants (e.g. `#define`).
///
/// Note:
/// -
/// The XML spec lists `Constants` as `enums` and `Constant` and `enum`.
/// However, the spec also mentiones that this is a historical hangover and
/// given that all compile time constants (even `#define`) are listed behind
/// these tags, `Constants` and `Constant` was chosen for this API.
///
/// Example:
/// -
///
/// ```xml
/// <enums>
///     <enum value="256" name="VK_MAX_EXTENSION_NAME"/>
///     <enum value="MAX_FLOAT"  name="VK_LOD_CLAMP_NONE"/>
/// </enums>
/// ```
///
/// When processed into a C header, and assuming all these tokens were
/// required, this results in
///
/// ```c
/// #define VK_MAX_EXTENSION_NAME   256
/// #define VK_LOD_CLAMP_NONE       MAX_FLOAT
/// ```
public struct Constants: Equatable, Hashable {
  /// The data type of the values of an enum
  public enum ConstantType: String, Decodable, Equatable, Hashable {
    // FIXME: Incorporate ConstantType into Constant(s) and strip unnecessary
    //        variables of each type
    case enumeration = "enum"
    case bitmask
  }

  /// Each Constant defines a single Vulkan (or other API) token.
  ///
  /// Note
  /// -
  /// In older versions of the schema, attr:type was described as allowing only
  /// the C integer suffix types `u` and `ull`, which is inconsistent with the
  /// current definition.
  /// However, attr:type was not actually used in the registry processing
  /// scripts or `vk.xml` at the time the current definition was introduced, so
  /// this is expected to be a benign change.
  public struct Constant: Decodable, Equatable, Hashable {
    /// Arbitrary string (unused).
    public let comment: Comment?

    /// Enumerant name, a legal C preprocessor token name.
    public let name: String

    /// A numeric value in the form of a legal C expression when
    /// evaluated at compile time in the generated header files.
    /// This is usually either a literal integer value or the name of an alias
    /// for a previously defined value, though more complex expressions are
    /// sometimes employed for <<compile-time-constants, compile time
    /// constants>>.
    public let value: String?

    /// A literal integer bit position in a bitmask.
    ///
    /// The bit position must be in the range [0,30] when used as a flag bit in
    /// a `Vk*FlagBits` data type.
    /// Bit positions 31 and up may be used for values that are not flag bits,
    /// or for <<adding-bitflags, flag bits used with 64-bit flag types>>.
    /// Exactly one of attr:value and attr:bitpos must be present in an tag:enum
    /// tag.
    public let bitpos: String?

    /// API names for which this definition is specialized, so that different
    /// APIs may have different values for the same token. This definition is
    /// only used if the requested API name matches the attribute.
    /// May be used to address subtle incompatibilities.
    public let api: String?

    /// May be used only when attr:value is specified.
    /// In this case, attr:type is optional except when defining a
    /// <<compile-time-constants, compile time constant>>, in which case it is
    /// required when using some output generator paths.
    /// If present the attribute must be a C scalar type corresponding to the
    /// type of attr:value, although only `uint32_t`, `uint64_t`, and `float`
    /// are currently meaningful.
    /// attr:type is used by some output generators to generate constant
    /// declarations, although the default behavior is to use C `#define` for
    /// compile-time constants.
    ///
    /// Public interface: constant(value:type:)
    public let type: String?

    /// Name of another enumerant this is an alias
    /// of, used where token names have been changed as a result of profile
    /// changes or for consistency purposes. An enumerant alias is simply a
    /// different attr:name for the exact same attr:value or attr:bitpos.
    public let alias: String?

    // FIXME: Not documented - but existing maybe?
    public let extends: String?

    /// An additional preprocessor token used to protect an enum definition.
    public let protect: String?
  }

  /// String naming the C `enum` type whose members are defined by this enum
  /// group. If present, this attribute should match the attr:name attribute of
  /// a corresponding tag:type tag.
  public let name: String?

  /// Describes the data type of the values of this group if it is a C enum.
  /// At present the only accepted categories are `enum` and `bitmask`. `nil`
  /// indicates a C `#define`.
  public let type: ConstantType?

  /// Integers defining the start and end of
  /// a reserved range of enumerants for a particular vendor or purpose.
  /// attr:start must be less than or equal to attr:end. These fields define
  /// formal enumerant allocations, and are made by the Khronos Registrar on
  /// request from implementers following the enum allocation policy.
  public let start: Int?, end: Int?

  /// String describing the vendor or purpose to whom a reserved range of
  /// enumerants is allocated.
  public let vendor: String?

  /// Arbitrary string (unused).
  public let comment: Comment?

  /// Bit width required for the generated enum value type.
  /// If omitted, a default value of 32 is used.
  public let bitwidth: Int?

  /// Zero or more `Constant`s in arbitrary order
  public let constants: [Constant]
}

// MARK: - Conformance to Decodable
extension Constants: Decodable {
  enum CodingKeys: String, CodingKey {
    case name
    case type
    case start
    case end
    case vendor
    case comment
    case bitwidth
    case constants = "enum" // See header comment
  }
}

// MARK: - Conformance to CustomStringConvertible & CustomDebugStringConvertible
// FIXME: Implement!
