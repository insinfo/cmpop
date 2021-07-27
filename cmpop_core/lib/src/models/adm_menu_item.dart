class AdmMenuItem {
  /// The name used in headers and navigation panels.
  final String displayName;

  /// The navigation panel group.
  final String group;

  /// The router link for this example.
  final String link;

  /// A list of component names related to this example.
  final List<String> relatedComponents;
  const AdmMenuItem(this.link, this.displayName, {this.group = '', this.relatedComponents});
}
