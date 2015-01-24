var rest = require('restler');

var base = 'http://localhost:3000';

var handle_success = function(data, callback, error) {
  // console.log("In handle_success: data     = " + JSON.stringify(data));
  // console.log("Type of Data                = " + typeof data);
  // console.log("In handle_success: callback = " + callback);
  // console.log("In handle_success: error    = " + error);
  if (data['status']) {
    // console.log("data['status'] === true");
    callback(data['data'])
  } else {
    // console.log("data['status'] === false");
    error(data['error']);
  }
}

var handle_error = function(info, response, callback) {
  if (info.code === 'ECONNREFUSED') {
    callback("Could not connect to service.")
  } else {
    console.log(info);
    callback(info);
  }
}

var handle_request = function(method, url, input, callback, error) {
  options = {
    method: method,
    data: JSON.stringify(input),
    headers: {
      'Content-Type': 'application/json'
    },
    parser: rest.parsers.json
  };
  rest.request(base+url, options).on('success', function(data) {
    // console.log("In handle_request.success: " + url);
    handle_success(data, callback, error);
  }).on('fail', function(data) {
    // console.log("In handle_request.fail: " + url);
    error(data);
  }).on('error', function(info, response) {
    // console.log("In handle_request.error: " + url);
    handle_error(info, response, error);
  });
}

var reset = function(callback, error) {
  handle_request('get', '/api/1.0/reset', [], callback, error);
}

var available_contacts = function(callback, error) {
  handle_request('get', '/api/1.0/contacts', [], callback, error);
}

var create_contact = function(data, callback, error) {
  handle_request('post', '/api/1.0/contacts', data, callback, error);
  // handle_post_request('/api/1.0/contacts', data, callback, error);
}

var delete_contact = function(id, callback, error) {
  handle_request('delete', '/api/1.0/contacts/' + id, [], callback, error);
}

var get_contact = function(id, callback, error) {
  handle_request('get', '/api/1.0/contacts/' + id, [], callback, error);
}

var update_contact = function(id, existing, updated, callback, error) {
  var info = {
    expected: existing,
    updated: updated
  };
  handle_request('put', '/api/1.0/contacts/' + id, info, callback, error);
}

exports.reset              = reset;
exports.available_contacts = available_contacts;
exports.create_contact     = create_contact;
exports.delete_contact     = delete_contact;
exports.get_contact        = get_contact;
exports.update_contact     = update_contact;
