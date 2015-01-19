var pristine = [
  { id: 0, name: "Roy G. Biv", birthdate: "01/01/1901",
    email: "roy.g.biv@biv.com", phone: "+1 303-555-5500",
    twitter: "@rainbow"
  },
  { id: 1, name: "Luke Skywalker", birthdate: "02/02/2001",
    email: "luke@skywalker.org", phone: "+1 303-555-5501",
    twitter: "@jedi"
  }
];

var next_id  = 0;
var contacts = [];
var TESTING  = false;

var load_test_data = function() {
  contacts = [];
  pristine.forEach(function(contact) {
    var new_contact = new Object();
    Object.keys(contact).forEach(function (att) {
      new_contact[att] = contact[att];
    });
    contacts.push(new_contact);
  });
  next_id = 2;
}

var test_mode = function(status) {
  TESTING = status;
  if (TESTING) {
    load_test_data();
  }
}

var reset = function() {
  if (TESTING) {
    load_test_data();
  }
}

var available_contacts = function() {
  results = [];
  contacts.forEach(function(contact) {
    if (contact !== undefined) {
      results.push({name: contact.name, id: contact.id});
    }
  });
  return results;
}

var create_contact = function(new_contact) {
  new_contact.id = next_id;
  contacts[next_id] = new_contact;
  next_id++;
  return new_contact;
}

var delete_contact = function(index) {
  if (contacts[index] === undefined) {
    return false;
  } else {
    contacts[index] = undefined;
    return true;
  }
}

var get_contact = function(index) {
  if (contacts[index] === undefined) {
    return undefined;
  } else {
    return contacts[index];
  }
}

exports.test_mode          = test_mode;
exports.available_contacts = available_contacts;
exports.create_contact     = create_contact;
exports.delete_contact     = delete_contact;
exports.get_contact        = get_contact;
exports.reset              = reset;
