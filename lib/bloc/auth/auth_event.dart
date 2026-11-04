import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// Checks if a user was already logged in last time.
class AppStarted extends AuthEvent {}

class LoginPressed extends AuthEvent {
  final int userId;
  LoginPressed(this.userId);

  @override
  List<Object?> get props => [userId];
}

class LogoutPressed extends AuthEvent {}
