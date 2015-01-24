var contacts = require('../lib/contacts');
var expect   = require('chai').expect;

describe('Contacts API Tests', function() {

  afterEach('reset test data', function(done) {
    contacts.reset(function(data) {
      done();
    });
  });

  it('should list available contacts', function(done) {
    contacts.available_contacts(function (data) {
      expect(data).to.be.an.instanceof(Array);
      expect(data).to.have.length(2);
      expect(data[0]).to.be.an.instanceof(Object);
      expect(data[0]).to.have.keys(['id', 'name']);
      expect(data[0]).to.have.property('id', 0);
      expect(data[0]).to.have.property('name', 'Roy G. Biv');
      done();
    }, function (error) {
      console.log(error);
      done();
    });
  });

  it('should create a new contact', function(done) {
    var new_contact = {
      name:      "Ken Anderson",
      birthdate: "06/10/1905",
      email:     "ken.anderson@colorado.edu",
      phone:     "+1 303-492-6003",
      twitter:   "@kenbod"
    }

    contacts.available_contacts(function (data) {
      expect(data).to.be.an.instanceof(Array);
      expect(data).to.have.length(2);
      contacts.create_contact(new_contact, function(data) {
        expect(data).to.be.an.instanceof(Object);
        expect(data).to.have.property('name', 'Ken Anderson');
        contacts.available_contacts(function (data) {
          expect(data).to.be.an.instanceof(Array);
          expect(data).to.have.length(3);
          done();
        });
      });
    });
  });

});
