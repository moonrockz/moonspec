"""Package graph checks must detect a reachable optional runtime."""
import copy
import unittest
from graph import reachable_sync, reject_async_runtime


class GraphTests(unittest.TestCase):
    def test_source_edge_to_async_is_rejected(self):
        graph = {"nodes": [{"module": "moonrockz/moonspec", "rel": ""},
                            {"module": "moonbitlang/async", "rel": ""}],
                 "edges": [{"from": 0, "to": 1, "kinds": ["blackbox-test"]}]}
        self.assertEqual(reachable_sync(graph), ["moonrockz/moonspec"])
        leaked = copy.deepcopy(graph)
        leaked["edges"][0]["kinds"] = ["source"]
        with self.assertRaises(AssertionError):
            reachable_sync(leaked)

    def test_async_output_symbol_is_rejected(self):
        reject_async_runtime('(import "moonbit" "print" (func))')
        for value in ('(func $moonbitlang/async/event_loop.loop)',
                      '(import "moonbitlang.async" "poll" (func))'):
            with self.assertRaises(AssertionError):
                reject_async_runtime(value)
