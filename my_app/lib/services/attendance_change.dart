class AttendanceChange {
  final int count, revision;
  final bool changed;
  const AttendanceChange(this.count, this.revision, this.changed);
  factory AttendanceChange.calculate({
    required int capacity,
    required int count,
    required int revision,
    required bool alreadyJoined,
    required bool joining,
    required bool cancelled,
  }) {
    if (cancelled) throw StateError('This event has been cancelled.');
    if (alreadyJoined == joining) {
      return AttendanceChange(count, revision, false);
    }
    if (joining && count >= capacity) throw StateError('This event is full.');
    if (!joining && count <= 0) {
      throw StateError(
        'Attendance data needs to be migrated. Ask the host to update the app setup.',
      );
    }
    return AttendanceChange(count + (joining ? 1 : -1), revision + 1, true);
  }
}
