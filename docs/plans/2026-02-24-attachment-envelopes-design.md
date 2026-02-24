# Attachment Envelope Support

## Overview

Add the ability for step definitions and test case hooks to attach content (text, binary, URLs) to test results, emitted as `Attachment` and `ExternalAttachment` envelopes in the Cucumber Messages protocol.

Includes a breaking rename of `StepArg` to `Ctx` — the type has outgrown its name now that it serves as the full step execution context.

## Rename: StepArg → Ctx

`StepArg` is renamed to `Ctx` across the entire codebase. Clean break, no backwards compatibility shim. Moonspec is pre-1.0 and the rename is mechanical.

## Ctx API

Three methods for attaching content during step or hook execution:

```moonbit
// Attach text content (Identity encoding)
ctx.attach(body: String, media_type: String, file_name~: String? = None)

// Attach binary content (Base64 encoded by the framework)
ctx.attach_bytes(body: Bytes, media_type: String, file_name~: String? = None)

// Attach external URL (emits ExternalAttachment envelope)
ctx.attach_url(url: String, media_type: String)
```

## Internal Buffering

`Ctx` holds a mutable `Array[PendingAttachment]`:

```moonbit
priv enum PendingAttachment {
  Embedded(body: String, encoding: AttachmentContentEncoding, media_type: String, file_name: String?)
  External(url: String, media_type: String)
}
```

- `attach()` pushes `Embedded(..., Identity, ...)`
- `attach_bytes()` Base64-encodes the bytes, pushes `Embedded(..., Base64, ...)`
- `attach_url()` pushes `External(...)`

## Envelope Emission

After each step or hook finishes, the executor drains `ctx.attachments` and emits:

- `Envelope::Attachment(...)` for `Embedded` entries, with `testCaseStartedId` and `testStepId` set
- `Envelope::ExternalAttachment(...)` for `External` entries, with `testCaseStartedId` and `testStepId` set

For test case hooks, `testStepId` is omitted (only `testCaseStartedId` is set).

## Scope

| Context | testCaseStartedId | testStepId |
|---------|-------------------|------------|
| Step definitions | set | set |
| before/after_test_case hooks | set | omitted |
| before/after_test_run hooks | out of scope (moonspec-gdw) | N/A |

## Formatter Impact

- **MessagesFormatter**: No changes needed — already emits all envelopes as NDJSON.
- **PrettyFormatter**: Add match arm for `Attachment`/`ExternalAttachment` to print a summary line (e.g., file name and media type).
- **JUnitFormatter**: Ignore attachment envelopes (no standard JUnit XML representation).

## Testing

- Unit test: `Ctx` buffering — attach, attach_bytes, attach_url populate the pending array correctly
- Unit test: drain produces correct envelope structures with proper IDs
- E2E test: step attaches text content → verify `Attachment` envelope in message stream with correct `testCaseStartedId` and `testStepId`
- E2E test: `after_test_case` hook attaches on failure → verify `Attachment` with `testCaseStartedId` only
- E2E test: `attach_url` → verify `ExternalAttachment` envelope with correct URL and media type

## Dependencies

- `moonrockz/cucumber-messages` already defines `Attachment`, `ExternalAttachment`, `AttachmentContentEncoding` types and includes them in the `Envelope` enum
- MoonBit standard library provides `@encoding/base64` for binary encoding
