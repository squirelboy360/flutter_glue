part of 'note_cubit.dart';


abstract class NoteState extends Equatable{}

class NoteInitial extends NoteState {
  @override
  List<Object?> get props => throw UnimplementedError();
}

class AddingNote extends NoteState {
  final List<Note> notes;

  AddingNote({required this.notes});

   @override
  List<Object?> get props => [notes];
}

class RemovingNote extends NoteState {
  final int id;

  RemovingNote({required this.id});

    @override
  List<Object?> get props => [id];
}


