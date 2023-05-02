// FIXME: Split commands into aliases and implementations
/// A structured definition of a single API command (function).
///
/// Example:
///
/// ```xml
/// <command>
///     <proto><type>VkResult</type> <name>vkCreateInstance</name></proto>
///     <param>const <type>VkInstanceCreateInfo</type>* <name>pCreateInfo</name></param>
///     <param><type>VkInstance</type>* <name>pInstance</name></param>
/// </command>
/// ```
///
/// When processed into a C header, this results in
///
/// ```c
/// VkResult vkCreateInstance(
///     const VkInstanceCreateInfo* pCreateInfo,
///     VkInstance* pInstance);
/// ```
public struct Command: Equatable, Hashable {

//  There are two ways to define a command. The first uses a set of attributes
//  to the tag:command tag defining properties of the command used for
//  constructing automatic validation rules, and the contents of the tag:command
//  tag define the name, signature, and parameters of the command. In this case
//  the allowed attributes include:

  /// Arbitrary string (unused).
  public let comment: Comment?

  public enum Queue: String, Decodable, Equatable, Hashable {
    case compute
    case transfer
    case graphics
  }

  /// A string identifying the command queues this
  /// command can be placed on. The format of the string is one or more of
  /// the terms `"compute"`, `"transfer"`, and `"graphics"`, with multiple
  /// terms separated by commas (`","`).
  private let _queues: String?

  /// The command queues this command can be placed on
  public var queues: [Queue]? {
    _queues?.split(separator: ",").map {
      // This conversion must succeed, or runtime crash
      Queue(rawValue: String($0))!
    }
  }
  
  /// A string describing possible
  /// successful return codes from the command, as a comma-separated list
  /// of Vulkan result code names.
  private let _successcodes: String?

  /// Possible successful return codes from the command
  public var successCodes: [String]? {
    return _successcodes?.split(separator: ",").map(String.init)
  }

  /// A string describing possible error
  /// return codes from the command, as a comma-separated list of Vulkan
  /// result code names.
  private let _errorcodes: String?

  /// Possible error return codes from the command
  public var errorCodes: [String]? {
    return _errorcodes?.split(separator: ",").map(String.init)
  }

  public enum RenderPass: String, Decodable, Equatable, Hashable {
    case outside
    case inside
  }

  /// A string identifying whether the command
  /// can be issued only inside a render pass (`"inside"`), only outside a
  /// render pass (`"outside"`), or both (`"both"`).
  private let _renderpass: String?

  /// Whether the command can be issued only inside a render pass, only outside
  /// a render pass, or both.
  public var renderPass: [RenderPass]? {
    if _renderpass == "both" { return [.inside, .outside] }
    return _renderpass.flatMap(RenderPass.init).map {[$0]}
  }

  public enum BufferLevel: String, Decodable, Equatable, Hashable {
    case primary
    case secondary
  }

  /// A string identifying the command
  /// buffer levels that this command can be called by. The format of the
  /// string is one or more of the terms `"primary"` and `"secondary"`,
  /// with multiple terms separated by commas (`","`).
  private let _cmdbufferlevel: String?

  /// The command buffer levels that this command can be called by.
  public var commandBufferLevels: [BufferLevel]? {
    _cmdbufferlevel?.split(separator: ",").map {
      // This conversion must succeed, or runtime crash
      BufferLevel(rawValue: String($0))!
    }
  }

  public enum Pipeline: String, Decodable, Equatable, Hashable {
    case compute
    case transfer
    case graphics
  }

  /// The pipeline type that this command uses when executed
  public let pipeline: Pipeline?

//  The second way of defining a command is as an alias of another command. For
//  example when an extension is promoted from extension to core status, the
//  commands defined by that extensions become aliases of the corresponding new
//  core commands. In this case, only two attributes are allowed:

  /// Required. A string naming the command defined by the tag.
  public let name: String?
  /// Required. A string naming the command that `name` is an alias of.
  public let alias: String?

//  == Contents of tag:command tags

  /// The C function prototype of a command up to the function name and return
  /// type but not including function parameters.
  public let prototype: Prototype?
  /// Parameter elements for each command parameter, defining its name and type.
  /// If a command takes no arguments, it has no parameters.
  public let parameters: [Parameter]?

//  Following these elements, the remaining elements in a tag:command
//  tag are optional and may be in any order:
//
//    * tag:alias - optional. Has no attributes and contains a string which
//      is the name of another command this command is an alias of, used
//      when promoting a function from vendor to Khronos extension or
//      Khronos extension to core API status. A command alias describes the case
//      where there are two function names which implement the same behavior.
//    * tag:description - optional. Unused text.
//    * tag:implicitexternsyncparams - optional. Contains a list of tag:param
//      tags, each containing asciidoc source text describing an object which is
//      not a parameter of the command but is related to one, and which also
//      <<tag-command:param:attr,requires external synchronization>>. The text
//      is intended to be incorporated into the API specification.

  /// API name for which this definition is specialized, so that different APIs
  /// may have different definitions for the same command.
  public let api: String?
}

extension Command {
  /// A `Prototype` defines the return type and name of a command.
  public struct Prototype: Decodable, Equatable, Hashable {
    /// The tag:type tag is optional, and contains text which is a valid
    /// type name found in a tag:type tag. It indicates that this type must
    /// be previously defined for the definition of the command to succeed.
    /// Builtin C types, and any derived types which are expected to be
    /// found in other header files, should not be wrapped in tag:type tags.
    public let type: String?
    /// The tag:name tag is required, and contains the command name being
    /// described.
    public let name: String
  }
}

extension Command {
  /// A `Parameter` defines the type and name of a parameter.
  public struct Parameter: Decodable, Equatable, Hashable {

  // MARK: Attributes of tag:param tags

    /// if the param is an array, len may be one or more of the
    /// following things, separated by commas (one for each array
    /// indirection): another param of that command; `"null-terminated"` for
    /// a string; `"1"` to indicate it is just a pointer (used for nested
    /// pointers); or an equation in math markup for incorporation in the
    /// specification (a LaTeX math expression delimited by `latexmath:[` and
    /// `]`.
    public let len: String?

    /// if the attr:len attribute is specified, and
    /// contains a `latexmath:` equation, this attribute should
    /// be specified with an equivalent equation using only C builtin operators,
    /// C math library function names, and variables as allowed for attr:len.
    /// It must be a valid C99 expression whose result is equal to attr:len for
    /// all possible inputs.
    /// It is a comma separated list that has size equal to only the `latexmath`
    /// item count in attr:len list.
    /// This attribute is intended to support consumers of the XML who need to
    /// generate validation code from the allowed length.

    public let altlen: String?

    /// A value of `"true"` or `"false"` determines whether this parameter can
    /// be omitted by providing `NULL` (for pointers), `VK_NULL_HANDLE` (for
    /// handles), or 0 (for other scalar types).
    /// If the parameter is a pointer to one of those types, multiple values may
    /// be provided, separated by commas - one for each pointer indirection.
    /// If not present, the value is assumed to be `"false"` (the parameter must
    /// not be omitted).
    private let optional: String?

    /// A value determining whether this parameter can be omitted.
    public var isOptional: Bool {
      // FIXME: There exists optional definitions containing both values,
      //        i.e. `optional="false,true"` (yes,...). This is wrongly
      //        evaluated here - evaluate at another time if issues arose.
      optional == "true"
    }

    /// If the parameter is a union, attr:selector identifies another parameter
    /// of the command that is used to select which of that union's members are
    /// valid.
    public let selector: String?

    /// prevents automatic validity language being
    /// generated for the tagged item. Only suppresses item-specific
    /// validity - parenting issues etc. are still captured.
    public let noautovalidity: String?

    /// A value of `"true"` indicates that this
    /// parameter (e.g. the object a handle refers to, or the contents of an
    /// array a pointer refers to) is modified by the command, and is not
    /// protected against modification in multiple app threads. If only certain
    /// members of an object or elements of an array are modified, multiple
    /// strings may be provided, separated by commas. Each string describes a
    /// member which is modified. For example, the `vkQueueSubmit` command
    /// includes attr:externsync attributes for the `pSubmits` array indicating
    /// that only specific members of each element of the array are modified:
    private let externsync: String?

    /// Indicates that this parameter (e.g. the object a handle refers to, or
    /// the contents of an array a pointer refers to) is modified by the
    /// command, and is not protected against modification in multiple app
    /// threads.
    public var isExternSync: Bool {
      externsync == "true"
    }

 // MARK: Contents of tag:param tags

    /// The text of a valid type name found in `types` array of the registrys.
    public let type: String?
    /// The parameter name being described.
    public let name: String

    /// API name for which this definition is specialized, so that different APIs
    /// may have different definitions for the same command.
    public let api: String?
  }
}

// MARK: - Conformance to Decodable
extension Command: Decodable {
  private enum CodingKeys: String, CodingKey {
    case _queues = "queues"
    case _successcodes = "successcodes"
    case _errorcodes = "errorcodes"
    case _renderpass = "renderpass"
    case _cmdbufferlevel = "cmdbufferlevel"
    case pipeline
    case name
    case alias
    case prototype = "proto"
    case parameters = "param"
    case comment
    case api
  }
}

// MARK: - Conformance to CustomStringConvertible & CustomDebugStringConvertible
// FIXME: Implement!
