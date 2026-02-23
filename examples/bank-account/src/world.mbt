///|
/// World struct holding per-scenario state for bank account tests.
struct BankWorld {
  mut balance : Int
  mut last_declined : Bool
} derive(Default)

///|
/// Step library for account setup and balance assertions.
struct AccountSteps {
  world : BankWorld
}

///|
fn AccountSteps::new(world : BankWorld) -> AccountSteps {
  { world, }
}

///|
impl @moonspec.StepLibrary for AccountSteps with steps(self) {
  let defs : Array[@moonspec.StepDef] = [
    @moonspec.StepDef::given(
      "a bank account with balance {int}",
      fn(args) {
        match args[0] {
          @moonspec.StepArg::IntArg(amount) => {
            self.world.balance = amount
            self.world.last_declined = false
          }
          _ => ()
        }
      },
    ),
    @moonspec.StepDef::then(
      "the balance should be {int}",
      fn(args) raise {
        match args[0] {
          @moonspec.StepArg::IntArg(expected) => assert_eq(self.world.balance, expected)
          _ => ()
        }
      },
    ),
  ]
  defs[:]
}

///|
/// Step library for deposit and withdrawal transactions.
struct TransactionSteps {
  world : BankWorld
}

///|
fn TransactionSteps::new(world : BankWorld) -> TransactionSteps {
  { world, }
}

///|
impl @moonspec.StepLibrary for TransactionSteps with steps(self) {
  let defs : Array[@moonspec.StepDef] = [
    @moonspec.StepDef::when(
      "I deposit {int}",
      fn(args) {
        match args[0] {
          @moonspec.StepArg::IntArg(amount) => self.world.balance = self.world.balance + amount
          _ => ()
        }
      },
    ),
    @moonspec.StepDef::when(
      "I withdraw {int}",
      fn(args) {
        match args[0] {
          @moonspec.StepArg::IntArg(amount) =>
            if amount > self.world.balance {
              self.world.last_declined = true
            } else {
              self.world.balance = self.world.balance - amount
            }
          _ => ()
        }
      },
    ),
    @moonspec.StepDef::then(
      "the withdrawal should be declined",
      fn(_args) raise {
        assert_true(self.world.last_declined)
      },
    ),
  ]
  defs[:]
}

///|
/// Compose step libraries into the world.
impl @moonspec.World for BankWorld with register_steps(self, s) {
  s.use_library(AccountSteps::new(self))
  s.use_library(TransactionSteps::new(self))
}
