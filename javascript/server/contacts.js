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
  id     = Number(req.params.id)
  status = contacts.delete_contact(id) 
  if (status) {
    res.json({ status: true, data: []});
  } else {
    res.json({ status: false, error: "Contact " + id + " not found"});
  }
});

app.listen(app.get('port'), function() {
  var message = 'Express started on http://localhost:';
  console.log(message + app.get('port'));
  message = 'Express is executing in the ';
  console.log(message + app.get('env') + ' environment.');
});