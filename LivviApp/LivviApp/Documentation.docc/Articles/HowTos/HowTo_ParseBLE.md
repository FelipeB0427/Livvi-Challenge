# How To: Parse BLE Events

Use `BLEEventParser` to convert the base64 encoded event payloads returned by the API into
readable `ParsedBLEEvent` objects.

Example

```swift
let parser = BLEEventParser()
let parsed = try parser.parse(base64String: apiEventPayload)
print(parsed.eventType)
print(parsed.payloadDetails)
```

Error handling

- `BLEParseError.invalidBase64` when the input cannot be base64-decoded.
- `BLEParseError.insufficientData` when the payload is shorter than expected.