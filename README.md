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

## Example

In my workflow I put initial data in upgrade scripts.
This way you can change the structure of your init data easily.

    assert = require 'assert'

    exports.upgrade = (db, callback) ->
      console.log "DB UPGRADE 1"

      db.collection 'users', (err, collection) ->
        assert.equal null, err
        userCol = collection
        userCol.remove()
        userCol.insert { name: "Sönke Rohde", twitter: "https://twitter.com/soenkerohde" }

        callback()

## Revoke Versions

Whenever you want to re-run all your upgrade scripts simply connect to your mongo console and delete the versions:

    $ mongo
    $ use <your_db_name>
    $ db.db_version.remove()