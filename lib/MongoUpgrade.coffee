# Copyright (c) 2013 Sönke Rohde https://twitter.com/soenkerohde
# 
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the 'Software'), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.

assert = require 'assert'

# MongoUpgrade handles database upgrade scripts.
# Scripts need to be put into the subdirectory `upgrades`.
# The scripts are named by the database version. The first
# upgrade scripts is called `1.coffee`. The upgrade script
# needs to implement a simple interface by implementing an
# _upgrade_ function:
#    
#    exports.upgrade = (db, callback) ->
#
# The upgrade function gets a reference to the database and
# the callback function which needs to be invoked when the
# upgrade is complete.
class MongoUpgrade

  # `db` Reference to the database  
  # `collName` Collection name containing the db version
  # `callback` Optional callback function invoked when upgrades are complete
  constructor: (@db, collName, @callback) ->

    db.collection collName, (err, collection) =>
      assert.equal null, err
      @dbVersionCol = collection

      @dbVersionCol.findOne {_id: 1}, (err, result) =>
        console.log "Found: " + JSON.stringify(result)
        if result is null
          @dbVersionCol.insert {_id: 1, version: 0}, (err, result) =>
            @_upgrade 0
        else
          version = result.version
          console.log "Found db version #{result.version}"
          @_upgrade version

  # _private_ Upgrade method  
  # `version` Current DB version
  _upgrade: (version) ->
    upgradeVersion = version += 1
    console.log "db upgrade #{upgradeVersion}"

    try
      dbUpgrade = require "./upgrades/#{upgradeVersion}"
      dbUpgrade.upgrade @db, (done) =>
        console.log "update to #{upgradeVersion} complete"
        @dbVersionCol.update {_id: 1}, { $set: {version: upgradeVersion}}, (err, result) =>
          @_upgrade upgradeVersion
      console.log "update to #{upgradeVersion}"
    catch e
      console.log "No version #{upgradeVersion} found: (#{JSON.stringify(e)}). Upgrade complete... "
      @callback?()

module.exports = MongoUpgrade