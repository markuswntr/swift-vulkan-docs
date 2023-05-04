// FIXME: Extensions are not fully done yet - see commented vars in body

/// API extensions are described in individual extension tags. An
/// extension is the set of interfaces defined by a particular API extension
/// specification, such as `ARB_multitexture`. Extension is
/// similar to tag:feature, but instead of having attr:version and
/// attr:profile attributes, instead has a attr:supported attribute,
/// which describes the set of API names which the extension can potentially
/// be implemented against.
///
/// Example:
/// -
/// ```xml
/// <extension name="VK_KHR_display_swapchain" number="4" supported="vulkan">
///   <require>
///     <enum value="9" name="VK_KHR_DISPLAY_SWAPCHAIN_SPEC_VERSION"/>
///     <enum value="4" name="VK_KHR_DISPLAY_SWAPCHAIN_EXTENSION_NUMBER"/>
///     <enum value="&quot;VK_KHR_display_swapchain&quot;"
///           name="VK_KHR_DISPLAY_SWAPCHAIN_EXTENSION_NAME"/>
///     <type name="VkDisplayPresentInfoKHR"/>
///     <command name="vkCreateSharedSwapchainsKHR"/>
///   </require>
/// </extension>
/// ```
///
/// The supported attribute says that the extension is defined for the
/// default profile (`vulkan`). When processed into a C header for the
/// `vulkan` profile, this results in header contents something like
/// (assuming corresponding definitions of the specified tag:type and
/// tag:command elsewhere in the XML):
///
/// ```c
/// #define VK_KHR_display_swapchain 1
/// #define VK_KHR_DISPLAY_SWAPCHAIN_SPEC_VERSION 9
/// #define VK_KHR_DISPLAY_SWAPCHAIN_EXTENSION_NUMBER 4
/// #define VK_KHR_DISPLAY_SWAPCHAIN_EXTENSION_NAME "VK_KHR_display_swapchain"
///
/// typedef struct VkDisplayPresentInfoKHR {
///     VkStructureType                             sType;
///     const void*                                 pNext;
///     VkRect2D                                    srcRect;
///     VkRect2D                                    dstRect;
///     VkBool32                                    persistent;
/// } VkDisplayPresentInfoKHR;
///
/// typedef VkResult (VKAPI_PTR *PFN_vkCreateSharedSwapchainsKHR)(
///     VkDevice device, uint32_t swapchainCount,
///     const VkSwapchainCreateInfoKHR* pCreateInfos,
///     const VkAllocationCallbacks* pAllocator,
///     VkSwapchainKHR* pSwapchains);
///
/// #ifndef VK_NO_PROTOTYPES
/// VKAPI_ATTR VkResult VKAPI_CALL vkCreateSharedSwapchainsKHR(
///     VkDevice                                    device,
///     uint32_t                                    swapchainCount,
///     const VkSwapchainCreateInfoKHR*             pCreateInfos,
///     const VkAllocationCallbacks*                pAllocator,
///     VkSwapchainKHR*                             pSwapchains);
/// #endif
/// ```
public struct Extension: Equatable, Hashable {
  /// The vulkan(sc) type this extension targets (instance or device extension)
  public enum Target: String, Decodable, Equatable, Hashable {
    case instance
    case device
  }

  /// The interface this extension targets (vulkan or vulkansc)
  public enum API: Equatable, Hashable {
    /// Indicates a vulkan extension for the specified target
    case vulkan(target: Target?)
    /// Indicates a vulkan extension audited for safety-criticial systems
    case vulkansc(target: Target?)
  }

  /// The extension profile
  public enum Profile: Equatable, Hashable {
    /// Indicates an enabled extension, listing all supporting APIs
    case enabled(apis: [API])
    /// Indicates a disabled extension (not yet fully defined)
    case disabled
  }

  /// The definitions of the extension that are added to the API surface
  public struct Definitions: Equatable, Hashable {
    let _constants: [Constants.Constant]?
    /// Constants added to the API with this extension
    public var constants: [Constants.Constant] { _constants ?? [] }

    let _types: [Typedef]?
    /// Types added to the API with this extension
    public var types: [Typedef] { _types ?? [] }

    let _commands: [Command]?
    /// Commands added to the API with this extension
    public var commands: [Command] { _commands ?? [] }

    public let api: String?
  }

  /// Extension name, following the conventions in the Vulkan Specification.
  /// Example: `name="VK_VERSION_1_0"`.
  public let name: String

  /// A decimal number which is the registered, unique extension number.
  public let number: String

  /// A decimal number which specifies an order relative to other extension
  /// tags when calling output generators. Rarely used, for when ordering by
  /// number is insufficient. Defaults to `0`.
  public let sortOrder: String

  /// The author name, such as a full company name.
  /// This attribute is not used in processing the XML. It is just metadata.
  public let author: String?

  /// The contact who registered or is currently responsible for extensions and
  /// layers using the tag. If not present, this can be taken from the
  /// corresponding tag attribute just like `author`.
  public let contact: String?

  /// Indicates the extension profile, e.g. targets vulkan instances or devices,
  /// or if it is in disabled state indicating that it is not fully defined yet,
  /// or permanently disabled in favor of a successor extension.
  public let profile: Profile

  /// List of extension names this extension requires to be supported.
  public let requiredExtensions: [String]?

  /// Core version of Vulkan required by the extension, e.g. "1.1".
  /// Defaults to "1.0".
  public let requiresCore: String

  /// An additional preprocessor token used to protect an extension definition.
  /// Usually another feature or extension name. Rarely used, for odd
  /// circumstances where the definition of an extension requires another
  /// extension or a header file to be defined first.
  public let protect: String?

  /// Indicates that the extension is specific to the platform identified by
  /// the attribute value, and should be emitted conditional on that platform
  /// being available, in a platform-specific header, etc. The attribute value
  /// must be the same as one of the platform name attribute values.
  public let platform: String?

  //  * attr:promotedto - optional. A Vulkan version or a name of an extension
  //    that this extension was _promoted_ to. E.g. `"VK_VERSION_1_1"`, or
  //    `"VK_KHR_draw_indirect_count"`.
  //  * attr:deprecatedby - optional. A Vulkan version or a name of an extension
  //    that _deprecates_ this extension. It may be an empty string. E.g.
  //    `"VK_VERSION_1_1"`, or `"VK_EXT_debug_utils"`, or `""`.
  //  * attr:obsoletedby - optional. A Vulkan version or a name of an extension
  //    that _obsoletes_ this extension. It may be an empty string. E.g.
  //    `"VK_VERSION_1_1"`, or `"VK_KHR_maintenance1"`, or `""`.
  //  * attr:provisional - optional. 'true' if this extension is released
  //    provisionally.
  //  * attr:specialuse - optional. If present, must contain one or more tokens
  //    separated by commas, indicating a special purpose of the extension.
  //    Tokens may include:
  //  ** 'cadsupport' - for support of CAD software.
  //  ** 'd3demulation' - for support of Direct3D emulation layers or libraries,
  //     or applications porting from Direct3D.
  //  ** 'debugging' - for debugging an application.
  //  ** 'devtools' - for support of developer tools, such as capture-replay
  //     libraries.
  //  ** 'glemulation' - for support of OpenGL and/or OpenGL ES emulation layers
  //     or libraries, or applications porting from those APIs.

  /// Arbitrary string (unused).
  public let comment: Comment?

  /// The extension definitions that are added to the API surface
  public var require: [Definitions]?
}

// MARK: - Conformance to Decodable
extension Extension: Decodable {
  private enum CodingKeys: String, CodingKey {
    case name
    case number
    case sortorder
    case author
    case contact
    case type
    case requires
    case requiresCore
    case protect
    case platform
    case supported
    case comment
    case require // See Definitions
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    name = try container.decode(String.self, forKey: .name)
    number = try container.decode(String.self, forKey: .number)
    author = try container.decodeIfPresent(String.self, forKey: .author)
    contact = try container.decodeIfPresent(String.self, forKey: .contact)
    protect = try container.decodeIfPresent(String.self, forKey: .protect)
    platform = try container.decodeIfPresent(String.self, forKey: .platform)
    comment = try container.decodeIfPresent(String.self, forKey: .comment)
    require = try container.decodeIfPresent([Definitions].self, forKey: .require)

    // Properties with defaults
    sortOrder = try container
      .decodeIfPresent(String.self, forKey: .sortorder) ?? "0"
    requiresCore = try container
      .decodeIfPresent(String.self, forKey: .requiresCore) ?? "1.0"

    // Comma-seperated lists
    let requires = try container.decodeIfPresent(String.self, forKey: .requires)
    requiredExtensions = requires?.split(separator: ",").map(String.init)

    // Special coding cases
    let supported = try container.decode(String.self, forKey: .supported)
    if supported == "disabled" {
      profile = .disabled
    } else {
      let supported = supported.split(separator: ",")
      let target = try container.decodeIfPresent(Target.self, forKey: .type)
      var supportAPIs: [API] = []
      if supported.contains("vulkansc") {
        supportAPIs.append(.vulkansc(target: target))
      }
      if supported.contains("vulkan") {
        supportAPIs.append(.vulkan(target: target))
      }
      profile = .enabled(apis: supportAPIs)
    }
  }
}

extension Extension.Definitions: Decodable {
  private enum CodingKeys: String, CodingKey {
    case `enum`
    case type
    case command
    case api
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    _constants = try container
      .decodeIfPresent([Constants.Constant].self, forKey: .enum)
    _commands = try container
      .decodeIfPresent([Command].self, forKey: .command)
    _types = try container
      .decodeIfPresent([Typedef].self, forKey: .type)
    api = try container.decodeIfPresent(String.self, forKey: .api)
  }
}

// MARK: - Conformance to CustomStringConvertible & CustomDebugStringConvertible
// FIXME: Implement!
