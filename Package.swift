// swift-tools-version: 5.7
import PackageDescription

let package = Package(
  name: "swift-vulkan-docs",
  products: [
    .library(name: "VulkanDescription", targets: ["VulkanDescription"])
  ],
  targets: [
    .target(name: "VulkanDescription", path: "src/vulkan_description"),
    .testTarget(name: "VulkanDescriptionTests", dependencies: ["VulkanDescription"])
  ]
)
