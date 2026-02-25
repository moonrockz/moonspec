///|
pub(all) struct JUnitFormatter {
  priv mut buffer : String
  // uri -> feature name
  priv features : Map[String, String]
  // pickle id -> pickle data
  priv pickles : Map[String, JUnitPickleData]
  // test case id -> pickle id
  priv test_cases : Map[String, String]
  // test case started id -> test case id
  priv test_case_started : Map[String, String]
  // tcs id -> worst status string
  priv test_case_worst : Map[String, String]
  // tcs id -> failure message
  priv test_case_failure : Map[String, String]
  // accumulated results per feature uri
  priv feature_results : Map[String, Array[JUnitTestCaseData]]
}

///|
priv struct JUnitPickleData {
  name : String
  uri : String
}

///|
priv struct JUnitTestCaseData {
  name : String
  classname : String
  status : String
  failure_message : String?
}

///|
pub fn JUnitFormatter::new() -> JUnitFormatter {
  {
    buffer: "",
    features: {},
    pickles: {},
    test_cases: {},
    test_case_started: {},
    test_case_worst: {},
    test_case_failure: {},
    feature_results: {},
  }
}

///|
pub impl @core.MessageSink for JUnitFormatter with output(self) {
  self.buffer
}

///|
pub impl @core.MessageSink for JUnitFormatter with on_message(self, envelope) {
  match envelope {
    GherkinDocument(doc) => {
      let uri = match doc.uri {
        Some(u) => u
        None => ""
      }
      let feature_name = match doc.feature {
        Some(f) => f.name
        None => uri
      }
      self.features[uri] = feature_name
    }
    Pickle(pickle) =>
      self.pickles[pickle.id] = { name: pickle.name, uri: pickle.uri }
    TestCase(tc) => self.test_cases[tc.id] = tc.pickleId
    TestCaseStarted(tcs) => {
      self.test_case_started[tcs.id] = tcs.testCaseId
      self.test_case_worst[tcs.id] = "PASSED"
    }
    TestStepFinished(tsf) => {
      let tcs_id = tsf.testCaseStartedId
      let status = tsf.testStepResult.status
      match status {
        Failed => {
          self.test_case_worst[tcs_id] = "FAILED"
          let msg = match tsf.testStepResult.message {
            Some(m) => m
            None => "unknown failure"
          }
          self.test_case_failure[tcs_id] = msg
        }
        Undefined | Pending | Ambiguous => {
          // Only upgrade if not already FAILED
          let current = match self.test_case_worst.get(tcs_id) {
            Some(w) => w
            None => "PASSED"
          }
          if current != "FAILED" {
            self.test_case_worst[tcs_id] = "SKIPPED"
          }
        }
        Skipped => {
          let current = match self.test_case_worst.get(tcs_id) {
            Some(w) => w
            None => "PASSED"
          }
          if current == "PASSED" {
            self.test_case_worst[tcs_id] = "SKIPPED"
          }
        }
        _ => ()
      }
    }
    TestCaseFinished(tcf) => {
      let tcs_id = tcf.testCaseStartedId
      let tc_id = match self.test_case_started.get(tcs_id) {
        Some(id) => id
        None => return
      }
      let pickle_id = match self.test_cases.get(tc_id) {
        Some(id) => id
        None => return
      }
      let pickle = match self.pickles.get(pickle_id) {
        Some(p) => p
        None => return
      }
      let feature_name = match self.features.get(pickle.uri) {
        Some(n) => n
        None => pickle.uri
      }
      let status = match self.test_case_worst.get(tcs_id) {
        Some(s) => s
        None => "PASSED"
      }
      let failure_message = self.test_case_failure.get(tcs_id)
      let data : JUnitTestCaseData = {
        name: pickle.name,
        classname: feature_name,
        status,
        failure_message,
      }
      match self.feature_results.get(pickle.uri) {
        Some(arr) => arr.push(data)
        None => self.feature_results[pickle.uri] = [data]
      }
    }
    TestRunFinished(_) => {
      // Count totals
      let mut total_tests = 0
      let mut total_failures = 0
      self.feature_results.each(fn(_uri, cases) {
        for tc in cases {
          total_tests = total_tests + 1
          if tc.status == "FAILED" {
            total_failures = total_failures + 1
          }
        }
      })
      let writer = @xml.Writer::new()
      writer.start_element("testsuites", [
        ("tests", total_tests.to_string()),
        ("failures", total_failures.to_string()),
      ])
      // Iterate features in insertion order
      self.feature_results.each(fn(uri, cases) {
        let suite_name = match self.features.get(uri) {
          Some(n) => n
          None => uri
        }
        writer.start_element("testsuite", [
          ("name", suite_name),
          ("tests", cases.length().to_string()),
        ])
        for tc in cases {
          match tc.status {
            "FAILED" => {
              writer.start_element("testcase", [
                ("name", tc.name),
                ("classname", tc.classname),
              ])
              let msg = match tc.failure_message {
                Some(m) => m
                None => "unknown failure"
              }
              writer.empty_element("failure", [("message", msg)])
              writer.end_element("testcase")
            }
            "SKIPPED" => {
              writer.start_element("testcase", [
                ("name", tc.name),
                ("classname", tc.classname),
              ])
              writer.empty_element("skipped", [])
              writer.end_element("testcase")
            }
            _ => {
              // PASSED or other
              writer.start_element("testcase", [
                ("name", tc.name),
                ("classname", tc.classname),
              ])
              writer.end_element("testcase")
            }
          }
        }
        writer.end_element("testsuite")
      })
      writer.end_element("testsuites")
      self.buffer = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" +
        writer.to_string()
    }
    _ => ()
  }
}
