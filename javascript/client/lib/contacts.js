var rest = require('restler');

var base = 'http://localhost:3000';

var handle_success = function(data, callback, error) {
  // console.log("In handle_success: data     = " + data);
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

var handle_get_request = function(url, callback, error) {
  rest.get(base+url).on('success', function(data) {
    // console.log("In handle_get_request.success: " + url);
    handle_success(data, callback, error);
  }).on('fail', function(data) {
    // console.log("In handle_get_request.fail: " + url);
    error(data);
  }).on('error', function(info, response) {
    // console.log("In handle_get_request.error: " + url);
    handle_error(info, response, error);
  });
}

var handle_post_request = function(url, data, callback, error) {
  rest.postJson(base+url, data).on('success', function(data) {
    handle_success(data, callback, error);
  }).on('fail', function(data) {
    error(data);
  }).on('error', function(info, response) {
    handle_error(info, response, error);
  });
}

var reset = function(callback, error) {
  handle_get_request('/api/1.0/reset', callback, error);
}

var available_contacts = function(callback, error) {
  handle_get_request('/api/1.0/contacts', callback, error);
}

var create_contact = function(data, callback, error) {
  handle_post_request('/api/1.0/contacts', data, callback, error);
}

exports.reset              = reset
exports.available_contacts = available_contacts
exports.create_contact     = create_contact
