## Licensed to Cloudera, Inc. under one
## or more contributor license agreements.  See the NOTICE file
## distributed with this work for additional information
## regarding copyright ownership.  Cloudera, Inc. licenses this file
## to you under the Apache License, Version 2.0 (the
## "License"); you may not use this file except in compliance
## with the License.  You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
<%!
  from desktop.views import commonheader, commonfooter, _ko
  from django.utils.translation import ugettext as _
%>

<%namespace name="assist" file="/assist.mako" />
<%namespace name="fileBrowser" file="/file_browser.mako" />
<%namespace name="tableStats" file="/table_stats.mako" />
<%namespace name="require" file="/require.mako" />

${ commonheader(_('Welcome Home'), "home", user) | n,unicode }

${ require.config() }

${ tableStats.tableStats() }
${ assist.assistPanel() }
${ fileBrowser.fileBrowser() }

<style type="text/css">
  html {
    height: 100%;
  }

  body {
    height:100%;
    margin: 0;
    padding: 0;
    background-color: #FFF;
  }

  .vertical-full {
    height:100%;
  }

  .main-content {
    height: auto;
    width: 100%;
    position: absolute;
    top: 82px;
    bottom: 0;
    background-color: #FFF;
  }

  .panel-container {
    position: relative;
  }

  .left-panel {
    position: absolute;
    height: 100%;
    overflow: hidden;
    outline: none !important;
  }

  .resizer {
    position: absolute;
    height: 100%;
    width: 4px;
    cursor: col-resize;
  }

  .resize-bar {
    position: absolute;
    height: 100%;
    width: 2px;
    background-color: #F1F1F1;
  }

  .right-panel {
    position: absolute;
    height: 100%;
    overflow: hidden;
    outline: none !important;
  }

  .show-assist {
    position: fixed;
    top: 80px;
    background-color: #FFF;
    width: 16px;
    height: 24px;
    line-height: 24px;
    margin-left: -2px;
    text-align: center;
    -webkit-border-top-right-radius: 3px;
    -webkit-border-bottom-right-radius: 3px;
    -moz-border-radius-topright: 3px;
    -moz-border-radius-bottomright: 3px;
    border-top-right-radius: 3px;
    border-bottom-right-radius: 3px;
    z-index: 1000;
    -webkit-transition: margin-left 0.2s linear;
    -moz-transition: margin-left 0.2s linear;
    -ms-transition: margin-left 0.2s linear;
    transition: margin-left 0.2s linear;
  }

  .show-assist:hover {
    margin-left: 0;
  }

  .hide-assist {
    position: absolute;
    top: 2px;
    right: 4px;
    z-index: 1000;
    color: #D1D1D1;
    font-size: 12px;
    -webkit-transition: margin-right 0.2s linear, color 0.5s ease;
    -moz-transition: margin-right 0.2s linear, color 0.5s ease;
    -ms-transition: margin-right 0.2s linear, color 0.5s ease;
    transition: margin-right 0.2s linear, color 0.5s ease;
  }

  .hide-assist:hover {
    margin-right: 2px;
    color: #338bb8;
  }

  .home-container {
    height: 100%;
  }

  .tab-content {
    min-height: 200px;
  }

  .step-icon {
    color: #DDDDDD;
    font-size: 116px;
    margin: 10px;
    margin-right: 20px;
    width: 130px;
  }

  .nav-tabs > li.active {
    padding: 0;
  }
</style>

<div class="navbar navbar-inverse navbar-fixed-top nokids">
  <div class="navbar-inner">
    <div class="container-fluid">
      <div class="nav-collapse">
        <ul class="nav">
          <li class="currentApp">
            <a href="${ url('desktop.views.home2') }">
              <img src="${ static('desktop/art/home.png') }" class="app-icon" />
              ${ _('My documents') }
            </a>
           </li>
        </ul>
      </div>
    </div>
  </div>
</div>

<div id="documentList" class="main-content">
##   Uncomment to enable the assist panel
##   <a title="${_('Toggle Assist')}" class="pointer show-assist" data-bind="visible: !$root.isLeftPanelVisible(), click: function() { $root.isLeftPanelVisible(true); }" style="display:none;">
##     <i class="fa fa-chevron-right"></i>
##   </a>

  <div class="vertical-full container-fluid" data-bind="style: { 'padding-left' : $root.isLeftPanelVisible() ? '0' : '20px' }">
    <div class="vertical-full row-fluid panel-container">
      <div class="assist-container left-panel" data-bind="visible: $root.isLeftPanelVisible" style="display: none;">
        <a title="${_('Toggle Assist')}" class="pointer hide-assist" data-bind="click: function() { $root.isLeftPanelVisible(false) }">
          <i class="fa fa-chevron-left"></i>
        </a>
        <div class="assist" data-bind="component: {
          name: 'assist-panel',
          params: {
            user: '${user.username}',
            sql: {
              sourceTypes: [{
                name: 'hive',
                type: 'hive'
              }],
              navigationSettings: {
                openItem: false,
                showStats: true
              },
            },
            visibleAssistPanels: ['documents']
          }
        }"></div>
      </div>
      <div class="resizer" data-bind="visible: $root.isLeftPanelVisible, splitDraggable : { appName: 'notebook', leftPanelVisible: $root.isLeftPanelVisible }" style="display:none;"><div class="resize-bar">&nbsp;</div></div>
      <div class="right-panel home-container" data-bind="style: { 'padding-left' : $root.isLeftPanelVisible() ? '8px' : '0' }">
        <div class="file-browser" data-bind="component: {
          name: 'file-browser',
          params: {
            activeEntry: activeEntry
          }
        }"></div>
      </div>
    </div>
  </div>
</div>

<script type="text/html" id="document-template">
  <tr>
    <td style="width: 26px"></td>
    <td><a data-bind="attr: { href: absoluteUrl }, html: name"></a></td>
    <td data-bind="text: ko.mapping.toJSON($data)"></td>
  </tr>
</script>

<script type="text/javascript" charset="utf-8">
  require([
    'knockout',
    'desktop/js/home2.vm',
    'assistPanel',
    'tableStats',
    'fileBrowser',
    'knockout-mapping',
    'knockout-sortable',
    'ko.hue-bindings'
  ], function (ko, HomeViewModel, ShareViewModel) {

    ko.options.deferUpdates = true;

    var userGroups = [];
    % for group in user.groups.all():
      userGroups.push('${ group }');
    % endfor

    $(document).ready(function () {
      var options = {
        user: '${ user.username }',
        userGroups: userGroups,
        superuser: '${ user.is_superuser }' === 'True',
        i18n: {
          errorFetchingTableDetails: '${_('An error occurred fetching the table details. Please try again.')}',
          errorFetchingTableFields: '${_('An error occurred fetching the table fields. Please try again.')}',
          errorFetchingTableSample: '${_('An error occurred fetching the table sample. Please try again.')}',
          errorRefreshingTableStats: '${_('An error occurred refreshing the table stats. Please try again.')}',
          errorLoadingDatabases: '${ _('There was a problem loading the databases. Please try again.') }',
          errorLoadingTablePreview: '${ _('There was a problem loading the table preview. Please try again.') }'
        }
      };

      var viewModel = new HomeViewModel(options);

      var loadUrlParam = function () {
        if (location.getParameter('uuid')) {
          viewModel.openUuid(location.getParameter('uuid'));
        } else if (location.getParameter('path')) {
          viewModel.openPath(location.getParameter('path'));
        } else if (viewModel.activeEntry() && viewModel.activeEntry().loaded()) {
          var rootEntry = viewModel.activeEntry();
          while (rootEntry && ! rootEntry.isRoot()) {
            rootEntry = rootEntry.parent;
          }
          viewModel.activeEntry(rootEntry);
        } else {
          viewModel.activeEntry().load(function () {
            if (viewModel.activeEntry().entries().length === 1 && viewModel.activeEntry().definition().type === 'directory') {
              viewModel.activeEntry(viewModel.activeEntry().entries()[0]);
              viewModel.activeEntry().load();
            }
          });
        }
      };
      window.onpopstate = loadUrlParam;
      loadUrlParam();

      viewModel.activeEntry.subscribe(function (newEntry) {
        if (typeof newEntry !== 'undefined' && newEntry.definition().uuid && ! newEntry.isRoot()) {
          hueUtils.changeURL('/home?uuid=' + newEntry.definition().uuid);
        } else if (typeof newEntry === 'undefined' || newEntry.isRoot()) {
          hueUtils.changeURL('/home');
        }
      });

      ko.applyBindings(viewModel, $('#documentList')[0]);

      huePubSub.publish('init.tour');

    });
  });

  huePubSub.subscribe('init.tour', function(){
    if ($.totalStorage("jHueTourHideModal") == null || $.totalStorage("jHueTourHideModal") == false) {
      $("#jHueTourModal").modal();
      $.totalStorage("jHueTourHideModal", true);
      $("#jHueTourModalChk").attr("checked", "checked");
      $("#jHueTourModalChk").on("change", function () {
        $.totalStorage("jHueTourHideModal", $(this).is(":checked"));
      });
      $("#jHueTourModalClose").on("click", function () {
        $("#jHueTourFlag").click();
        $("#jHueTourModal").modal("hide");
      });
    }
  });
</script>

<div id="jHueTourModal" class="modal hide fade" tabindex="-1">
  <div class="modal-header">
    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
    <h3>${_('Did you know?')}</h3>
  </div>
  <div class="modal-body">
    <ul class="nav nav-tabs" style="margin-bottom: 0">
      <li class="active"><a href="#tourStep1" data-toggle="tab">${ _('Step 1:') } ${ _('Add data') }</a></li>
      <li><a href="#tourStep2" data-toggle="tab">${ _('Step 2:') }  ${ _('Query data') }</a></li>
      <li><a href="#tourStep3" data-toggle="tab">${ _('Step 3:') } ${_('Do more!') }</a></li>
    </ul>

    <div class="tab-content">
      <div id="tourStep1" class="tab-pane active">
        <div class="pull-left step-icon"><i class="fa fa-download"></i></div>
        <div style="margin: 40px">
          <p>
            ${ _('With') }  <span class="badge badge-info"><i class="fa fa-file"></i> File Browser</span>
            ${ _('and the apps in the') }  <span class="badge badge-info">Data Browsers <b class="caret"></b></span> ${ _('section, upload, view your data and create tables.') }
          </p>
          <p>
            ${ _('Pre-installed samples are also already there.') }
          </p>
        </div>
      </div>

      <div id="tourStep2" class="tab-pane">
          <div class="pull-left step-icon"><i class="fa fa-search"></i></div>
          <div style="margin: 40px">
            <p>
              ${ _('Then query and visualize the data with the') } <span class="badge badge-info">Query Editors <b class="caret"></b></span>
               ${ _('and') }  <span class="badge badge-info">Search <b class="caret"></b></span>
            </p>
          </div>
      </div>

      <div id="tourStep3" class="tab-pane">
        <div class="pull-left step-icon"><i class="fa fa-flag-checkered"></i></div>
        <div style="margin: 40px">
          % if tours_and_tutorials:
          <p>
            ${ _('Tours were created to guide you around.') }
            ${ _('You can see the list of tours by clicking on the checkered flag icon') } <span class="badge badge-info"><i class="fa fa-flag-checkered"></i></span>
            ${ ('at the top right of this page.') }
          </p>
          % endif
          <p>
            ${ _('Additional documentation is available at') } <a href="http://learn.gethue.com">learn.gethue.com</a>.
          </p>
        </div>
      </div>
    </div>
  </div>
  <div class="modal-footer">
    <label class="checkbox" style="float:left"><input id="jHueTourModalChk" type="checkbox" />${_('Do not show this dialog again')}</label>
    <a id="jHueTourModalClose" href="#" class="btn btn-primary disable-feedback">${_('Got it!')}</a>
  </div>
</div>

${ commonfooter(request, messages) | n,unicode }
