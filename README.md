# Simple Service Example &mdash; Contacts

An introduction to implementing simple JSON-based web services.

## Introduction

This repository contains the source code for a simple JSON-based web service that supports browsing, editing, and searching of a set of contacts.

Each contact has a name, a birthdate, an e-mail address, a phone number, and a Twitter handle. It supports a simple search interface in which a query string is compared against a contact's attributes and any contact that matches is returned. For example, the search string `ken` would match a contact whose Twitter handle is `@ken365` but also a contact whose e-mail address is `<kent@example.com>`.

Note: Birthdates must be formatted as `MM/DD/YYYY`. For instance, `06/05/1945` for June 5, 1945.

The service currently does not use a database. Instead, contacts are persisted in a file called `contacts.json`.

The service is implemented in `service.rb`. It makes use of Sinatra to handle HTTP-based calls on its API.

## Uniform Response

All endpoints return a response object with a similar structure. In particular, the response will always be a JSON dictionary with two keys. For successful operations, the keys are `status` and `data`. For unsuccessful operations, the keys are `status` and `error`.

For successful operations, the `data` attribute of the response object will contain a JSON structure that represents the information returned by the endpoint. For instance:

```json
{ "status": true, "data": [{"name": "Kilroy Pendragon", "id": 0}]}
```

For unsuccessful operations, the `error` attribute of the response object will contain a JSON string that explains the error condition. For instance:

```json
{ "status": false, "error": "Contact 20 not found" }
```

## API

### `GET /api/1.0/contacts`

Return a list of contact names plus their associated ids.

```json
{"status":true,"data":[{"id":0,"name":"Roy G. Biv"},{"id":1,"name":"Luke Skywalker"}]}
```

### `POST /api/1.0/contacts`

Create a new contact with the supplied information. Returns the newly created contact plus its id.

Example request object:

```json
{
  :name      => "Shimmer",
  :birthdate => "02/05/1960",
  :email     => "shimmer@crimsonguard.com",
  :phone     => "303-555-5525",
  :twitter   => "@shimmer"
}
```

Example response:

```json
{"status":true,"data":{"id":2,"name":"Shimmer","birthdate":"02/05/1960","email":"shimmer@crimsonguard.com","phone":"303-555-5525","twitter":"@shimmer"}}
```

### `GET /api/1.0/contacts/:id`

Retrieve the contact with the specified id.

Example successful response:

```json
{"status":true,"data":{"id":0,"name":"Roy G. Biv","birthdate":"01/01/1901","email":"roy.g.biv@biv.com","phone":"+1 303-555-5500","twitter":"@rainbow"}}
```

Example failure response:

```json
{ "status": false, "error": "Contact 20 not found" }
```

### `PUT /api/1.0/contacts/:id`

Update the contact with the specified id with new information. The client must pass what it thinks the current value of the contact is plus the new value of the contact. If the current value matches what the service has, then the value of the contact is updated to the new value. The only requirement is that the "new value" must have the same id as the old value, any other field may change.

Example request object:

```json
{"expected": {"name":"Heidi Klum","birthdate":"06/19/1985","email":"heidi@klum.net","phone":"+1 303-555-5502","twitter":"@projectrunway"}, "updated": {"name":"Heidi Klum","birthdate":"06/01/1973","email":"heidi.klum@fashion.com"    ,"phone":"+1 303-555-5505","twitter":"@agt"}}
```

Example successful response:

```json
{"status":true,"data":{"id”:2,”name":"Heidi Klum","birthdate":"06/01/1973","email":"heidi.klum@fashion.com","phone":"+1 303-555-5505","twitter”:”@agt”}}
```

Example failure response:

```json
{"status": false, "error": "Expected information was stale."}
```

### `DELETE /api/1.0/contacts/:id`

Delete the contact with the specified id.

Example response:

```json
{"status":true,"data":[]}
```

### `GET /api/1.0/search`

Returns contacts that match a given query string `q`. Matches are treated as substrings to be found in the attributes of the contacts. The query string `man` would find contact `Barry Manilow` as well as the contact whose Twitter handle is `@thecheeseman`.

Example Response:

```json
{"status":true,"data”:[{“id":0,"name":"Roy G. Biv","birthdate":"01/01/1901","email":"roy.g.biv@biv.com","phone":"+1 303-555-5500","twitter":"@rainbow”}]}
```

### `GET /api/1.0/upcomingbirthdays`

Returns contacts whose birthdays occur in the next three months.

Example Response:

```json
{"status":true,"data”:[{“id":0,"name":"Roy G. Biv","birthdate":"01/01/1901","email":"roy.g.biv@biv.com","phone":"+1 303-555-5500","twitter":"@rainbow”}]}
```
