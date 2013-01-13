MongoUpgrade
============

MongoUpgrade handles database upgrade scripts for [Mongo DB](http://www.mongodb.org/).
Scripts need to be put into the subdirectory __upgrades__.
The scripts are named by the database version. The first
upgrade scripts is called _1.coffee_.

## Usage

    mongo = require 'mongodb'

    # process.env.MONGOHQ_URL when used with Heroku
    dbConnection = process.env.MONGOHQ_URL or 'mongodb://localhost/<your_db_name>'

    mongo.Db.connect dbConnection, (err, db) ->
      assert.equal null, err
      mongoUpgrade = new MongoUpgrade db, "db_version", ->
        console.log "upgrades complete"

## Interface

The upgrade script
needs to implement a simple interface by implementing an
_upgrade_ function:

    exports.upgrade = (db, callback) ->

The upgrade function gets a reference to the database and
the callback function which needs to be invoked when the
upgrade is complete.