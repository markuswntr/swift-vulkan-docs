/// A `Comment` contains an arbitrary string, and is unused.
///
/// Comment tags may appear in multiple places in the schema.
/// Comment tags are removed by output generators if they would otherwise appear
/// in generated headers, asciidoc include files, etc.
public typealias Comment = String
