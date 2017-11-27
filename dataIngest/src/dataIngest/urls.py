#!/usr/bin/env python
# Licensed to Cloudera, Inc. under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  Cloudera, Inc. licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

from django.conf.urls import url
from . import views, utils

app_name = 'dataIngest'
urlpatterns = [
        url(r'^$', views.index, name="index"),
        url(r'^export/database/$', views.exportDatabase, name="exportDatabase"),
        url(r'^export/$', views.exportHome, name="exportHome"),
        url(r'^export/csv/$', views.exportCSV, name="exportCSV"),
        url(r'^quality/$', views.quality, name="quality"),
        url(r'^csv/$', views.csv, name="csv"),
        url(r'^csv/csvSuccess/$', views.csvSuccess, name="csvSuccess"),
        url(r'^tables/$', views.tables, name="tables"),
        url(r'^ajax/getTables', utils.getTables, name="getTables"),
        url(r'^ajax/getColumns', utils.getColumns, name="getColumns"),
        url(r'^ajax/getHiveTables', utils.getHiveTables, name="getHiveTables"),
        url(r'^ajax/ajaxHiveDatabaseNames', utils.ajaxHiveDatabaseNames, name="ajaxHiveDatabaseNames"),
        url(r'^hive_query/$', views.hive_query, name='hive_query'),
        url(r'^hive_success/$', views.hive_success, name='hive_success'),
        url(r'^hive_query/ajax/getDatabasesHive/$', utils.getDatabasesHive, name='getDatabasesHive'),
        url(r'^hive_query/ajax/getTablesHive/$', utils.getTablesHive, name='getTablesHive'),
        url(r'^hive_query/ajax/getColHive/$', utils.getColHive, name='getColHive'),
	url(r'^hive_submit/$', views.hive_submit, name='hive_submit'),
	url(r'^hive_success/ajax/getSample/$',utils.getSample, name='getSample'),
	url(r'^export/database/ajax/getDatabasesHive/$', utils.getDatabasesHive, name='getDatabasesHiveExport'),
        url(r'^export/database/ajax/getTablesHive/$', utils.getTablesHive, name='getTablesHiveExport'),
	url(r'^export/database/ajax/getDatabasesSql/$', utils.getDatabasesSql, name='getDatabasesHiveExport'),
        url(r'^export/database/ajax/getTablesSql/$', utils.getTablesSql, name='getTablesHiveExport'),
]
