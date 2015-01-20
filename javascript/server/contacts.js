var express = require('express');
var parser  = require('body-parser');
var contacts = require('./lib/contacts');
var logger   = require('morgan')

var app = express();

// set up the port for the server; default to 3000
app.set('port', process.env.PORT || 3000);

// set up the environment for the server; default to development
app.set('env', process.env.NODE_ENV || 'development')

app.use(parser.json());

app.use(logger('dev'));

if (app.get('env') === "test") {
  contacts.test_mode('true');
}

app.get('/api/1.0/reset', function(req, res) {
  contacts.reset();
  res.json({ status: true, data: [] });
});

app.get('/api/1.0/contacts', function(req, res) {
  res.json({ status: true, data: contacts.available_contacts()});
});

app.post('/api/1.0/contacts', function(req, res) {
  res.json({ status: true, data: contacts.create_contact(req.body)});
});

app.get('/api/1.0/contacts/:id', function(req, res) {
  id      = Number(req.params.id)
  contact = contacts.get_contact(id);
  if (contact !== undefined) {
    res.json({ status: true, data: contact});
  } else {
    res.json({ status: false, error: "Contact " + id + " not found"});
  }
});

app.delete('/api/1.0/contacts/:id', function(req, res) {
  id     = Number(req.params.id);
  status = contacts.delete_contact(id);
  if (status) {
    res.json({ status: true, data: []});
  } else {
    res.json({ status: false, error: "Contact " + id + " not found"});
  }
});

app.put('/api/1.0/contacts/:id', function(req, res) {
  id          = Number(req.params.id);

  expected    = req.body.expected;
  expected.id = id;

  updated     = req.body.updated;
  updated.id  = id;

  status = contacts.update(id, expected, updated);

  if (status) {
    res.json({status: true, data: updated });
  } else {
    res.json({status: false, error: "Expected information was stale."});
  }
});

app.get('/api/1.0/search', function(req, res) {
  res.json({ status: true, data: contacts.find(req.query.q)});
});

app.get('/api/1.0/upcomingbirthdays', function(req, res) {
  res.json({ status: true, data: contacts.birthdays()});
});

app.post('/api/1.0/upcomingbirthdays', function(req, res) {
  res.json({ status: true, data: contacts.birthdays(req.body.date)});
});

app.use(function(err, req, res, next) {
  console.error(err.stack);
  next();
});

app.listen(app.get('port'), function() {
  var message = 'Express started on http://localhost:';
  console.log(message + app.get('port'));
  message = 'Express is executing in the ';
  console.log(message + app.get('env') + ' environment.');
});
