// Licensed to Cloudera, Inc. under one
// or more contributor license agreements.  See the NOTICE file
// distributed with this work for additional information
// regarding copyright ownership.  Cloudera, Inc. licenses this file
// to you under the Apache License, Version 2.0 (the
// 'License'); you may not use this file except in compliance
// with the License.  You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an 'AS IS' BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
define([
  'knockout',
  'desktop/js/autocomplete/sql',
  'desktop/spec/autocompleterTestUtils'
], function(ko, sql, testUtils) {

  describe('sql.js ANALYZE statements', function() {

    beforeAll(function () {
      sql.yy.parseError = function (msg) {
        throw Error(msg);
      };
      jasmine.addMatchers(testUtils.testDefinitionMatcher);
    });

    var assertAutoComplete = testUtils.assertAutocomplete;

    describe('ANALYZE TABLE', function () {
      it('should handle "ANALYZE TABLE boo.baa PARTITION (bla=1, boo=\'baa\') COMPUTE STATISTICS FOR COLUMNS CACHE METADATA NOSCAN;|"', function() {
        assertAutoComplete({
          beforeCursor: 'ANALYZE TABLE boo.baa PARTITION (bla=1, boo=\'baa\') COMPUTE STATISTICS FOR COLUMNS CACHE METADATA NOSCAN;',
          afterCursor: '',
          dialect: 'hive',
          noErrors:true,
          containsKeywords: ['SELECT'],
          hasLocations: true,
          expectedResult: {
            lowerCase: false
          }
        });
      });

      it('should suggest keywords for "|"', function() {
        assertAutoComplete({
          beforeCursor: '',
          afterCursor: '',
          dialect: 'hive',
          noErrors:true,
          containsKeywords: ['ANALYZE'],
          expectedResult: {
            lowerCase: false
          }
        });
      });

      it('should suggest keywords for "analyze |"', function() {
        assertAutoComplete({
          beforeCursor: 'analyze ',
          afterCursor: '',
          dialect: 'hive',
          noErrors:true,
          expectedResult: {
            lowerCase: true,
            suggestKeywords: ['TABLE']
          }
        });
      });

      it('should suggest tables for "ANALYZE TABLE |"', function() {
        assertAutoComplete({
          beforeCursor: 'ANALYZE TABLE ',
          afterCursor: '',
          dialect: 'hive',
          noErrors:true,
          expectedResult: {
            lowerCase: false,
            suggestTables: { onlyTables: true },
            suggestDatabases: { appendDot: true }
          }
        });
      });

      it('should suggest tables for "ANALYZE TABLE boo.|"', function() {
        assertAutoComplete({
          beforeCursor: 'ANALYZE TABLE boo.',
          afterCursor: '',
          dialect: 'hive',
          noErrors:true,
          expectedResult: {
            lowerCase: false,
            suggestTables: { database: 'boo', onlyTables: true }
          }
        });
      });

      it('should suggest keywords for "ANALYZE TABLE boo |"', function() {
        assertAutoComplete({
          beforeCursor: 'ANALYZE TABLE boo ',
          afterCursor: '',
          dialect: 'hive',
          noErrors:true,
          hasLocations: true,
          expectedResult: {
            lowerCase: false,
            suggestKeywords: ['PARTITION', 'COMPUTE STATISTICS']
          }
        });
      });

      it('should suggest keywords for "ANALYZE TABLE boo PARTITION (baa = 1) |"', function() {
        assertAutoComplete({
          beforeCursor: 'ANALYZE TABLE boo PARTITION (baa = 1) ',
          afterCursor: '',
          dialect: 'hive',
          noErrors:true,
          hasLocations: true,
          expectedResult: {
            lowerCase: false,
            suggestKeywords: ['COMPUTE STATISTICS']
          }
        });
      });

      it('should suggest keywords for "ANALYZE TABLE boo PARTITION (baa = 1) COMPUTE |"', function() {
        assertAutoComplete({
          beforeCursor: 'ANALYZE TABLE boo PARTITION (baa = 1) COMPUTE ',
          afterCursor: '',
          dialect: 'hive',
          noErrors:true,
          hasLocations: true,
          expectedResult: {
            lowerCase: false,
            suggestKeywords: ['STATISTICS']
          }
        });
      });

      it('should suggest keywords for "ANALYZE TABLE baa.boo COMPUTE STATISTICS |"', function() {
        assertAutoComplete({
          beforeCursor: 'ANALYZE TABLE baa.boo COMPUTE STATISTICS ',
          afterCursor: '',
          dialect: 'hive',
          noErrors:true,
          hasLocations: true,
          expectedResult: {
            lowerCase: false,
            suggestKeywords: ['FOR COLUMNS', 'CACHE METADATA', 'NOSCAN']
          }
        });
      });

      it('should suggest keywords for "ANALYZE TABLE baa.boo COMPUTE STATISTICS FOR |"', function() {
        assertAutoComplete({
          beforeCursor: 'ANALYZE TABLE baa.boo COMPUTE STATISTICS FOR ',
          afterCursor: '',
          dialect: 'hive',
          noErrors:true,
          hasLocations: true,
          expectedResult: {
            lowerCase: false,
            suggestKeywords: ['COLUMNS']
          }
        });
      });

      it('should suggest keywords for "ANALYZE TABLE baa.boo COMPUTE STATISTICS FOR COLUMNS |"', function() {
        assertAutoComplete({
          beforeCursor: 'ANALYZE TABLE baa.boo COMPUTE STATISTICS FOR COLUMNS ',
          afterCursor: '',
          dialect: 'hive',
          noErrors:true,
          hasLocations: true,
          expectedResult: {
            lowerCase: false,
            suggestKeywords: ['CACHE METADATA', 'NOSCAN']
          }
        });
      });

      it('should suggest keywords for "ANALYZE TABLE baa.boo COMPUTE STATISTICS FOR COLUMNS CACHE |"', function() {
        assertAutoComplete({
          beforeCursor: 'ANALYZE TABLE baa.boo COMPUTE STATISTICS FOR COLUMNS CACHE ',
          afterCursor: '',
          dialect: 'hive',
          noErrors:true,
          hasLocations: true,
          expectedResult: {
            lowerCase: false,
            suggestKeywords: ['METADATA']
          }
        });
      });

      it('should suggest keywords for "ANALYZE TABLE baa.boo COMPUTE STATISTICS FOR COLUMNS CACHE METADATA |"', function() {
        assertAutoComplete({
          beforeCursor: 'ANALYZE TABLE baa.boo COMPUTE STATISTICS FOR COLUMNS CACHE METADATA ',
          afterCursor: '',
          dialect: 'hive',
          noErrors:true,
          hasLocations: true,
          expectedResult: {
            lowerCase: false,
            suggestKeywords: ['NOSCAN']
          }
        });
      });

      it('should suggest keywords for "ANALYZE TABLE baa.boo COMPUTE STATISTICS | NOSCAN"', function() {
        assertAutoComplete({
          beforeCursor: 'ANALYZE TABLE baa.boo COMPUTE STATISTICS ',
          afterCursor: ' NOSCAN',
          dialect: 'hive',
          noErrors:true,
          hasLocations: true,
          expectedResult: {
            lowerCase: false,
            suggestKeywords: ['FOR COLUMNS', 'CACHE METADATA']
          }
        });
      });

      it('should suggest keywords for "ANALYZE TABLE baa.boo COMPUTE STATISTICS CACHE | NOSCAN"', function() {
        assertAutoComplete({
          beforeCursor: 'ANALYZE TABLE baa.boo COMPUTE STATISTICS CACHE ',
          afterCursor: ' NOSCAN',
          dialect: 'hive',
          noErrors:true,
          hasLocations: true,
          expectedResult: {
            lowerCase: false,
            suggestKeywords: ['METADATA']
          }
        });
      });

      it('should suggest keywords for "ANALYZE TABLE baa.boo COMPUTE STATISTICS FOR COLUMNS | NOSCAN"', function() {
        assertAutoComplete({
          beforeCursor: 'ANALYZE TABLE baa.boo COMPUTE STATISTICS FOR COLUMNS ',
          afterCursor: ' NOSCAN',
          dialect: 'hive',
          noErrors:true,
          hasLocations: true,
          expectedResult: {
            lowerCase: false,
            suggestKeywords: ['CACHE METADATA']
          }
        });
      });
    });
  });
});