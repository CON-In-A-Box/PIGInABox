# PIGInABox
Simple Payment Integration Gateway. Proof of Concept. No Warranty

This simple Sinatra service does one thing -- accept a payment request and verify it against Authorize.net.

Any Ruby 2.x should suffice. You will also need `ngrok` to set up a tunnel if you're running this locally. Because Authorize.net is stupid, you must run this in such a way that you can call it via https, even if you're just running it locally. For testing purposes, use ngrok.io to set up a tunnel and hit the page that way.

To prepare:

```
bundle install
```

You must create a `.env` file based on `.env-example` with your Authorize.net keys. If running to test it, use your sandbox keys!

To run:
```
ngrok http 4567 # in a window by itself. Note the https URL it generates!
ruby pig_in_a_box.rb
```

Right now this responds to exactly two endpoints:

From a browser: `GET '/'` will give you a test form that will use `Accept.js` to validate the credit card and get you an ANet token. It will then post to the other endpoint to test it and return the results.

AJAX/XHR `POST /api/v1/payments` will send the requested payment to ANet and return a simplified result JSON:

Expects:
```json
{
  "opaqueData": {
    "dataDescriptor": "...",
    "dataValue": "..."
  },
  "amount": 42.42,
  "customerEmail": "them@there.dm",
  "orderDescription": "99 bottles of beer on the wall"
}
```

A successful charge returns:
```json
{
  "authCode": "...",
  "responseCode": "...",
  "messages": [ { "code": "...", "description": "..."}, ...]
}
```

Any error returns:
```json
{
  "errors": [ { "code": "...", "description": "..."}, ...]
}