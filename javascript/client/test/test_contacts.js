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

  it('should delete a contact', function(done) {
    contacts.available_contacts(function (data) {
      expect(data).to.be.an.instanceof(Array);
      expect(data).to.have.length(2);
      contacts.delete_contact(0, function(data) {
        contacts.available_contacts(function (data) {
          expect(data).to.be.an.instanceof(Array);
          expect(data).to.have.length(1);
          done();
        });
      });
    });
  });

  it('should fail to delete a contact', function(done) {
    contacts.delete_contact(20, function(data) {
      // Note: this function should not be called
      // If it is, then something is wrong!
      expect(true).to.equal(false);
      done();
    }, function(error_message) {
      expect(error_message).to.equal("Contact 20 not found");
      done();
    });
  });

  it('should get a contact', function(done) {
    contacts.get_contact(0, function(data) {
      expect(data).to.be.an.instanceof(Object);
      expect(data).to.have.property('name', 'Roy G. Biv');
      done();
    });
  });

  it('should fail to get a non-existent contact', function(done) {
    contacts.get_contact(20, function(data) {
      // Note: this function should not be called
      // If it is, then something is wrong!
      expect(true).to.equal(false);
      done();
    }, function(error_message) {
      expect(error_message).to.equal("Contact 20 not found");
      done();
    });
  });

  it('should update a contact', function(done) {
    var updated_contact = {
      name:      "Roy Green Biv",
      birthdate: "01/01/2001",
      email:     "roy@gbiv.com",
      phone:     "+1 303-555-5555",
      twitter:   "@roygbiv"
    }
    contacts.get_contact(0, function(data) {
      var existing_contact = data;
      contacts.update_contact(0, existing_contact, updated_contact, function(data) {
        contacts.get_contact(0, function(data) {
          expect(data).to.be.an.instanceof(Object);
          expect(data).to.have.property('name', 'Roy Green Biv');
          expect(data).to.have.property('twitter', '@roygbiv');
          done();
        });
      });
    });
  });

});
