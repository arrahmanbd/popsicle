part of 'package:popsicle/popsicle.dart';

/// Exception thrown when a forbidden action is attempted
/// on a restricted or immutable Popsicle state.
///
/// For example, trying to call `shift` on a readonly state wrapper
/// will result in this exception being raised.
///
/// This helps enforce immutability or restricted lifecycles in
/// state management flows.
class PopsicleMelted implements Exception {
  /// The action that triggered this exception.
  final String action;

  /// Creates a [PopsicleMelted] exception with a descriptive action.
  PopsicleMelted(this.action);

  @override
  String toString() =>
      'PopsicleMelted: The action "$action" is not allowed on a restricted state.';
}
