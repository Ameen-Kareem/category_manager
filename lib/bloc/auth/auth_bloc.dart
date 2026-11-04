import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/api_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiService apiService;

  AuthBloc(this.apiService) : super(const AuthState()) {
    on<AppStarted>(_onAppStarted);
    on<LoginPressed>(_onLoginPressed);
    on<LogoutPressed>(_onLogoutPressed);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getInt('user_id');

    if (savedId == null) {
      emit(const AuthState(status: AuthStatus.unauthenticated));
      return;
    }

    // always load the profile from the API again
    try {
      final user = await apiService.fetchUser(savedId);
      emit(AuthState(status: AuthStatus.authenticated, user: user));
    } catch (e) {
      emit(AuthState(status: AuthStatus.unauthenticated, error: e.toString()));
    }
  }

  Future<void> _onLoginPressed(
      LoginPressed event, Emitter<AuthState> emit) async {
    emit(const AuthState(status: AuthStatus.loading));
    try {
      final user = await apiService.fetchUser(event.userId);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_id', event.userId);
      emit(AuthState(status: AuthStatus.authenticated, user: user));
    } catch (e) {
      emit(AuthState(status: AuthStatus.unauthenticated, error: e.toString()));
    }
  }

  Future<void> _onLogoutPressed(
      LogoutPressed event, Emitter<AuthState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}
