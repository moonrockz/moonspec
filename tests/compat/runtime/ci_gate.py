"""The aggregate passes only with positive success from every required job."""
import json
import os

REQUIRED = ("lint", "unit-tests", "core-tests", "examples", "site", "compatibility")


def validate(needs):
    assert isinstance(needs, dict), "needs must be a job-result object"
    assert set(needs) == set(REQUIRED), ("required job results missing or unexpected", sorted(needs), REQUIRED)
    failures = {name: needs[name].get("result") for name in REQUIRED
                if not isinstance(needs[name], dict) or needs[name].get("result") != "success"}
    assert not failures, ("required jobs did not succeed", failures)


def main():
    try:
        validate(json.loads(os.environ["NEEDS"]))
    except (AssertionError, KeyError, ValueError) as error:
        raise SystemExit("::error::" + str(error))
    print("Every required CI job succeeded.")


if __name__ == "__main__":
    main()
