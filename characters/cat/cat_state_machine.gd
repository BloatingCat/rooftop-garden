class_name CatStateMachine
extends Node

enum State {
	IDLE,
	WALK,
}

var current: State = State.IDLE

func transition(new_state: State):
	if current == new_state:
		return
	current = new_state
	state_changed.emit(new_state)

signal state_changed(new_state: State)
