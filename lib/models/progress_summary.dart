/// # Progress Summary Model
/// A data class to hold the calculated progress metrics for the user.
///
/// This model separates the calculated data from the raw `MurojaahRecord` data,
/// making it easy to pass around the UI.
class ProgressSummary {
  /// The number of consecutive days the user has completed their murojaah.
  final int currentStreak;

  /// The percentage of days the user completed their murojaah in the last 7 days.
  final double weeklyCompletionRate;

  ProgressSummary({
    required this.currentStreak,
    required this.weeklyCompletionRate,
  });
}
