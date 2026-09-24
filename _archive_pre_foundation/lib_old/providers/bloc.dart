import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// App-wide state block
class AppBlocBloc Bloc<BaseBlocState> implements StateNotifier<State> {
  final _bloc = BlocBuilder<BaseBlocState>(_bloc);

  @override
  State<State> get state => _bloc;
  late List<BaseBlocState> list;
  late int count;
  late int index;
  late int? selected;

  // TODO: Implement bloc pattern
}

/// Main bloc pattern for app state management
class AppBlocBloc<State> implements Bloc<State> {
  final State state;
  late List<State> list;
  late int count;
  late int index;
  late int? selected;

  // TODO: Implement actual bloc pattern
}

/// Main bloc state
class AppBlocState {
  final bool isLoading;
  final bool isError;
  final String error;
  final String title;
  final int selectedIndex;
  final String searchQuery;
  final bool isLive;

  AppBlocState({
    this.isLoading = false,
    this.isError = false,
    this.error = '',
    this.title = '',
    this.selectedIndex = 0,
    this.searchQuery = '',
    this.isLive = false,
  });

  factory AppBlocState.initial() {
    return AppBlocState();
  }
}
