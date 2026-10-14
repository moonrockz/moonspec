///|
fn main {
  let argv = @env.args()
  let mut dist = "dist"
  let mut base = "/"
  let ignore : Array[String] = []
  let mut i = 1
  while i + 1 < argv.length() {
    match argv[i] {
      "--dist" => dist = argv[i + 1]
      "--base" => base = argv[i + 1]
      "--ignore" => ignore.push(argv[i + 1])
      flag => {
        println("linkcheck: unknown flag \{flag}")
        @sys.exit(2)
      }
    }
    i = i + 2
  }
  let problems = check(dist, base, ignore) catch {
    _ => {
      println("linkcheck: cannot read the build in \{dist}")
      @sys.exit(2)
      return
    }
  }
  if problems.is_empty() {
    println("linkcheck: \{dist} OK")
  } else {
    for p in problems {
      println("linkcheck: " + p)
    }
    @sys.exit(1)
  }
}
