///|
#moonspec.given("a todo list")
fn given_todo_list(world : TodoWorld) -> Unit {
  world.todos.clear()
}

///|
#moonspec.when("I add a todo {string}")
fn when_add_todo(world : TodoWorld, title : String) -> Unit {
  world.todos.push(TodoItem::{ title, completed: false })
}

///|
#moonspec.then("I should have {int} todos")
fn then_todo_count(world : TodoWorld, count : Int) -> Unit raise Error {
  assert_eq(world.todos.length(), count)
}

///|
#moonspec.when("I complete todo {string}")
fn when_complete_todo(world : TodoWorld, title : String) -> Unit {
  for todo in world.todos {
    if todo.title == title {
      todo.completed = true
    }
  }
}

///|
#moonspec.then("todo {string} should be completed")
fn then_todo_completed(world : TodoWorld, title : String) -> Unit raise Error {
  let found = world.todos.iter().find_first(fn(t) { t.title == title })
  match found {
    Some(todo) => assert_true(todo.completed)
    None => fail("todo not found: " + title)
  }
}

///|
#moonspec.when("I remove todo {string}")
fn when_remove_todo(world : TodoWorld, title : String) -> Unit {
  let filtered = world.todos.iter().filter(fn(t) { t.title != title }).collect()
  world.todos.clear()
  for item in filtered {
    world.todos.push(item)
  }
}

///|
#moonspec.given("I have {int} completed and {int} pending todos")
fn given_mixed_todos(world : TodoWorld, completed : Int, pending : Int) -> Unit {
  world.todos.clear()
  for i = 0; i < completed; i = i + 1 {
    world.todos.push(TodoItem::{ title: "completed-" + i.to_string(), completed: true })
  }
  for i = 0; i < pending; i = i + 1 {
    world.todos.push(TodoItem::{ title: "pending-" + i.to_string(), completed: false })
  }
}

///|
#moonspec.then("the pending count should be {int}")
fn then_pending_count(world : TodoWorld, count : Int) -> Unit raise Error {
  let pending = world.todos.iter().filter(fn(t) { not(t.completed) }).collect().length()
  assert_eq(pending, count)
}
