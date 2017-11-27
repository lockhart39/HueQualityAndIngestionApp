<%!from desktop.views import commonheader, commonfooter %>
<%namespace name="shared" file="shared_components.mako" />

${commonheader("dataIngest", "dataIngest", user, request) | n,unicode}

<link href="/static/dataIngest/css/chosen.min.css" rel="stylesheet">
<link href="/static/dataIngest/css/exportCSV.css" rel="stylesheet">
<script src="/static/dataIngest/js/chosen.jquery.min.js"></script>


${shared.menubar(section='Export')}

<div class="container-fluid">
    <div class="card">
        <h2 class="card-heading simple"> Export Table to CSV </h2>
        <div class="card-body row" style="margin-top: 0;">
            % if noPath == 'Yes':
                <div class="alert alert-error">
                    <strong> File Path Given Does Not Exist!</strong>
                </div>
            % elif exSuccess == 'Yes':
                <div class="alert alert-success">
                    <strong> CSV Exported From Hive Successfully!</strong>
                </div>
            % elif exFail == 'Yes':
                <div class="alert alert-error">
                    <strong> CSV Export Failed!</strong>
                </div>
            % endif
            <form action="" method="post" enctype="multipart/form-data" id='exportCSVForm' class=" container">
                ${ csrf_token(request) | n,unicode }
                <div id="source" class="source">
                    <h4>Source Data: </h4>
                    <div id="divDB">
                        <label class="label label-default">Database: </label><br>
                        <select name="exportDB" id="exportDB">
                            <option value=""></option>
                            % for dbName in dbNames:
                                <option> ${dbName} </option>  
                            % endfor
                        </select>
                    </div>
                    <div id="divTable">
                        <label class="label label-default">Table: </label><br>
                        <select name=exportTable id=exportTable>
                        </select>
                    </div>
                    <div id="divColumns">
                        <label class="label label-default">Column(s): </label><br>
                        <select multiple id="exportCols" name="exportCols" class="chosen-select">
                            <option></option>
                        </select>
                        <br>
                        <button type='button' id="selectAll" class='btn btn-primary' style="width: 49.7%; float: left;">Select All</button>
                        <button type='button' id="clearAll" class='btn btn-danger' style="width: 49.6%;">Remove All</button>
                    </div>
                </div>
                <div class="arrow">
                    <h2 style="text-align: center;">---></h2>
                </div>
                <div id="destination" class="destination">
                    <h4>Destination: </h4>
                    <label class="label label-default">File Name: </label>
                    <input type="text" name="fileName" id="fileName" placeholder="File Name">
                    <label class="label label-default">File Path: </label>
                    <input type="text" name="filePath" id="filePath" placeholder="File Destination">
                    <label class="label label-default">Delimiter: </label>
                    <input type="text" name="delimiter" id="delimiter" placeholder="Delimiter">
                     <br><br>
                    <input type="button" class='btn btn-success' value='Export' onclick="submitClicked()" style="width: 99.4%;">
                    <input type="submit" name="exportSubmit" id="exportSubmit" style="display: none;">
                </div>
            </form>
        </div>
    </div>
</div>

<div class="loader"><p></p></div>

<script src="/static/dataIngest/js/exportCSV.js"></script>


${commonfooter(None, messages) | n,unicode}