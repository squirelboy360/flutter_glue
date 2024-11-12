import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../data/models/note.dart';

part 'note_state.dart';

class NoteCubit extends HydratedCubit<NoteState> {
  NoteCubit() : super(NoteInitial());

  @override
  NoteState? fromJson(Map<String, dynamic> json) {
    // TODO: implement fromJson
    throw UnimplementedError();
  }

  @override
  Map<String, dynamic>? toJson(NoteState state) {
    // TODO: implement toJson
    throw UnimplementedError();
  }
}
