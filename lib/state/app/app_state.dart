import 'package:crystal/state/error/error_state.dart';
import 'package:crystal/state/me/me_state.dart';
import 'package:meta/meta.dart';

@immutable
class AppState {
  final MeState me;
  final ErrorState error;

  AppState({MeState me, ErrorState error})
      : me = me ?? MeState(),
        error = error ?? ErrorState();

  AppState copyWith({MeState me}) {
    return AppState(me: me ?? this.me);
  }

  @override
  String toString() {
    return '''{
      me: $me,
      error: $error
    }''';
  }
}
