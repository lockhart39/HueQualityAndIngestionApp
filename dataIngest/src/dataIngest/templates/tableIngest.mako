<%!from desktop.views import commonheader, commonfooter %>
<%!from datetime import datetime %>
<%namespace name="shared" file="shared_components.mako" />

%if not is_embeddable:
${commonheader("dataIngest", "dataIngest", user, request) | n,unicode}
%endif
<link href="/static/dataIngest/css/chosen.min.css" rel="stylesheet">
<link href="/static/dataIngest/css/tableIngest.css" rel="stylesheet">
<script src="/static/dataIngest/js/chosen.jquery.min.js"></script>

${shared.menubar(section='tables')}

## Use double hashes for a mako template comment
## Main body
<div class="container-fluid">
    <div class="card">
        <h2 class="card-heading simple">Table Ingestion (${db})</h2>
        <div class="card-body row">
            % if sqoopSuccess == False: 
                <div class="alert alert-error">
                    <strong>Sqoop Failed!</strong> ${ datetime.now().replace(microsecond=0) }
                </div>
            % elif sqoopSuccess == True:
                <div class="alert alert-success">
                    Success! <strong>${srcDB}.${srcTable}</strong> sqooped into <strong>${stgDB}.${stgTable}</strong> &nbsp;&nbsp; ${ datetime.now().replace(microsecond=0) }
                    <p><a href="/dataIngest/hive_query?db=${stgDB}&t=${stgTable}">Continue Ingestion</a></p>
                </div>        
            % endif
            <form method="POST" action="" class="container column">
                ${ csrf_token(request) | n,unicode }
                <input type="hidden" name="selDB" id="selDB" value="${db}"/>
                <input type="hidden" name="txtUsername" id="txtUsername" value="${username}"/>
                <input type="hidden" name="txtPassword" id="txtPassword" value="${password}"/>
                <input type="hidden" name="txtSplitBy" id="txtSplitBy" value="" />

                <label for="selDBName" class="label label-default">Source Database: </label>
                <select id="selDBName" name="selDBName">
                    <option value=""></option>
                    % for dbName in dbNames:
                        <option> ${dbName} </option>  
                    % endfor
                </select> 

                <div name='divTable'>
                    <label class="label label-default">Table: </label>
                    <select id="selTable" name="selTable">
                        <option></option>
                    </select>
                </div>

                <div name="divColumns">
                    <label class="label label-default">Column(s): </label>
                    <select multiple id="selColumns" name="selColumns" class="chosen-select">
                        <option></option>
                    </select>
                    <button type='button' class='btn btn-primary' style="width: 50%; float: left;">Select All</button>
                    <button type='button' class='btn btn-danger' style="width: 50%;">Remove All</button>
                </div>
                
                <div id="stagingInfo" style="margin-top: 20px;">
                	<label class="label label-default">Staging Database:</label> 
                    <select id="selStgDB" name="selStgDB">
                        <option value=""></option>
                        % for hiveDb in hiveDbNames:
                            <option> ${hiveDb} </option>
                        % endfor
                    </select>
                    <div name="divStgTable" id="divStgTable">
                        <label class="label label-default">Table: </label>
                        <select id="selStgTable" name="selStgTable">
                            <option></option>
                        </select>
                        <label>Create New Table: <input type='checkbox' onclick='checkboxClicked(this)' /> </label>
                        <input type='text' name='txtStgTable' id='txtStgTable' style='display: none;' placeholder='Enter New Table Name...'/>
                    </div>
                	<input type="submit" name="sqoopSubmit" id="sqoopSubmit" style="display: none;">
                    <div style="text-align: center; margin-top: 3em;">
                        <input type="button" class='btn btn-success' value="Sqoop" onclick="submitClicked()" style="width: 80%; height: 3em;"/>
                    </div>
                </div>
            </form>
            <div class='column tableDiv' hidden>
                <table class="table table-bordered" id="leftTable">
                    <caption></caption>
                    <thead>
                        <tr></tr>
                    </thead>
                    <tbody>
                        <tr></tr>
                        <tr></tr>
                        <tr></tr>
                    </tbody>
                </table>
            </div>
            <div class="column arrowDiv" hidden>
                <h2>---></h2>
            </div>
            <div class="column tableDiv" hidden>
                <table class="table table-bordered" id="rightTable">
                    <caption></caption>
                    <thead>
                        <tr></tr>
                    </thead>
                    <tbody>
                        <tr></tr>
                        <tr></tr>
                        <tr></tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>
<div class="loader"><p></p></div>

<script src="/static/dataIngest/js/tableIngest.js"></script>

%if not is_embeddable:
${commonfooter(None, messages) | n,unicode}
%endif
