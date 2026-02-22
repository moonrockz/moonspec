///|
fn make_test_pickle(
  name : String,
  tags? : Array[String] = [],
  uri? : String = "test://feature",
) -> @cucumber_messages.Pickle {
  let pickle_tags = tags.map(fn(t) {
    let tag : @cucumber_messages.PickleTag = { name: t, astNodeId: "t1" }
    tag
  })
  {
    id: "p-" + name,
    uri,
    name,
    language: "en",
    steps: [
      {
        id: "s1",
        text: "a step",
        astNodeIds: ["s1"],
        type_: None,
        argument: None,
      },
    ],
    tags: pickle_tags,
    astNodeIds: ["sc1"],
    location: None,
  }
}

///|
test "PickleFilter: no filters passes all" {
  let pickles = [make_test_pickle("S1"), make_test_pickle("S2")]
  let filter = PickleFilter::new()
  let result = filter.apply(pickles)
  assert_eq(result.length(), 2)
}

///|
test "PickleFilter: tag filter" {
  let pickles = [
    make_test_pickle("Smoke", tags=["@smoke"]),
    make_test_pickle("Slow", tags=["@slow"]),
  ]
  let filter = PickleFilter::new().with_tags("@smoke")
  let result = filter.apply(pickles)
  assert_eq(result.length(), 1)
  assert_eq(result[0].name, "Smoke")
}

///|
test "PickleFilter: name filter" {
  let pickles = [
    make_test_pickle("Login valid"),
    make_test_pickle("Login invalid"),
    make_test_pickle("Logout"),
  ]
  let filter = PickleFilter::new().with_names(["Login valid"])
  let result = filter.apply(pickles)
  assert_eq(result.length(), 1)
  assert_eq(result[0].name, "Login valid")
}

///|
test "PickleFilter: combined tag and name" {
  let pickles = [
    make_test_pickle("A", tags=["@smoke"]),
    make_test_pickle("B", tags=["@smoke"]),
    make_test_pickle("C", tags=["@slow"]),
  ]
  let filter = PickleFilter::new().with_tags("@smoke").with_names(["A"])
  let result = filter.apply(pickles)
  assert_eq(result.length(), 1)
  assert_eq(result[0].name, "A")
}
