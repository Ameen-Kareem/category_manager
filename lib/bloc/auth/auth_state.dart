import 'package:equatable/equatable.dart';

import '../../models/user.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated }

class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final String? error;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.error,
  });

  @override
  List<Object?> get props => [status, user, error];
}
