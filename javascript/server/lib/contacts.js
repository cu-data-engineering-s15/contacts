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

var contacts_are_equal = function(a, b) {
  if (a.id !== b.id) {
    return false
  }
  if (a.name !== b.name) {
    return false
  }
  if (a.phone !== b.phone) {
    return false
  }
  if (a.email !== b.email) {
    return false
  }
  if (a.twitter !== b.twitter) {
    return false
  }
  if (a.phone !== b.phone) {
    return false
  }
  return true;
}

var update = function(id, expected, updated) {
  var actual = contacts[id];
  if (contacts_are_equal(actual, expected)) {
    contacts[id] = updated;
    return true;
  }
  return false;
}

var contains = function(contact, query) {
  var q = query.toLowerCase();
  return Object.keys(contact).some(function (key) {
    if (key !== "id") {
      var value = contact[key].toLowerCase();
      return value.indexOf(q) !== -1;
    }
  });
}

var find = function(query) {
  return contacts.filter(function(contact) {
    return contains(contact, query);
  });
}

var upcoming_birthday = function(contact, current_date) {
  if (current_date === undefined) {
    current_date = new Date();
  } else {
    current_date = new Date(current_date);
  }
  month = current_date.getMonth() + 1;
  next_months = [month, month+1, month+2]
  next_months = next_months.map(function(element) {
    return element >= 13 ? element - 12 : element;
  });
  is_there_a_match = next_months.filter(
    function(month) {
      var bday      = new Date(contact.birthdate);
      var bdaymonth = bday.getMonth() + 1;
      return (bdaymonth === month);
    }
  );
  return is_there_a_match.length == 1
}

var birthdays = function(date) {
  var items = contacts.filter(function(contact) {
    return upcoming_birthday(contact, date);
  });
  return items;
}

exports.test_mode          = test_mode;
exports.available_contacts = available_contacts;
exports.create_contact     = create_contact;
exports.delete_contact     = delete_contact;
exports.get_contact        = get_contact;
exports.find               = find;
exports.update             = update;
exports.birthdays          = birthdays;
exports.reset              = reset;
