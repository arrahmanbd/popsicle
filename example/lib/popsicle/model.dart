class StateExample {
  final bool isLoading;
  final String message;

  StateExample({required this.isLoading, required this.message});

  // CopyWith method to modify only specific fields
  StateExample copyWith({bool? isLoading, String? message}) {
    return StateExample(
      isLoading: isLoading ?? this.isLoading,
      message: message ?? this.message,
    );
  }
}
