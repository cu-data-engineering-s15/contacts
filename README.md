# Simple Service Example &mdash; Contacts

An introduction to implementing simple JSON-based web services.

## Introduction

This repository contains the source code for a simple JSON-based
web service that supports browsing, editing, and searching of a
set of contacts.

Each contact has a name, a birthdate, an e-mail address, a phone
number, and a Twitter handle. It supports a simple search interface
in which a query string is compared against a contact's attributes
and any contact that matches is returned. For example, the search
string `ken` would match a contact whose Twitter handle is `kenbod`
but also a contact whose e-mail address is `kent@example.com`.

Note: Birthdates must be formatted as "MM/DD/YYYY". For instance,
"06/05/1945" for June 5, 1945.

The service currently does not use a database. Instead, contacts are
persisted in a file called contacts.json.

The service is implemented in service.rb. It makes use of Sinatra
to handle HTTP-based calls on its API.

## API

`GET /api/1.0/contacts`

Retrieve a list of contact names plus their associated ids.

`POST /api/1.0/contacts`

Create a new contact with the supplied information. Returns the newly
created contact plus its id.

`GET /api/1.0/contacts/:id`

Retrieve the contact with the specified id.

`PUT /api/1.0/contacts/:id`

Replace the contact with the specified id. The client must pass what
it thinks the current value of the contact is plus the new value of
the contact. If the current value matches what the service has, then
the value of the contact is updated to the new value. The only
requirement is that the "new value" must have the same id as the old
value, any other field may change.

`DELETE /api/1.0/contacts/:id`

Delete the contact with the specified id.

`GET /api/1.0/search`

Returns contacts that match a given query string `q`. Matches are
treated as substrings to be found in the attributes of the contacts. The
query string `man` would find contact `Barry Manilow` as well as the
contact whose Twitter handle is `@thecheeseman`.

`GET /api/1.0/upcomingbirthdays`

Returns any contacts whose birthdays occur in the next three months.
