<%!from desktop.views import commonheader, commonfooter %>
<%namespace name="shared" file="shared_components.mako" />

${commonheader("dataIngest", "dataIngest", user, request) | n,unicode}

<link href="/static/dataIngest/css/chosen.min.css" rel="stylesheet">
<script src="/static/dataIngest/js/chosen.jquery.min.js"></script>

<style>
    .container {
    width: 1500px;
    float: left;
    padding: 0;
    }

    .container select{
        width: 15%;
        clear: both;
    }
    
    .container input[type="text"]{
        width: 13.9%;
        clear: both;
    }
    .container label{
        width: 14.5%;
        margin-bottom: 0;
    }   
    
    .chosen-container:not(.chosen-container-multi){
        margin-bottom: 10px;
    }
    .loader {
        display:    none;
        position:   fixed;
        z-index:    1000;
        top:        50%;
        text-align: center;
        left:       0;
        height:     100%;
        width:      100%;
     }
    
    .loader::before {
        margin: auto;
        display:block ;
        text-align: center;
        content: url('/static/dataIngest/art/ajax-loader.gif');
    }
    
    /* When the body has the loading class, we turn
       the scrollbar off with overflow:hidden */
    body.loading {
        overflow: hidden;   
    }
    
    /* Anytime the body has the loading class, our
       loader element will be visible */
    body.loading .loader {
        display: block;
    }
</style>

${shared.menubar(section='csv')}

## Use double hashes for a mako template comment
## Main body
<div class="container-fluid">
    <div class="card">
        <h2 class="card-heading simple"> Insert CSV files into Tables </h2>
        <div class="alert alert-error" id="noFile" style="margin-bottom: 0;" hidden="true">
            <strong>NO DATA FILE SELECTED!</strong>
        </div>
        <div class="card-body row" style="margin-top: 0;">
            <form action="/dataIngest/csv/csvSuccess/" method="post" enctype="multipart/form-data" id='myForm' class="container column">
                ${ csrf_token(request) | n,unicode }
                <div class="divOptions" style="float:left; width:500px;">
                    % if metaInfo == '':
                        Is there a CSV containing the metadata?<br>
                        <input type="radio" name="metaExist" id="isMetadata" value="Yes" checked>Yes<br>
                        <input type="radio" name="metaExist" id="noMetadata" value="No">No<br>
                        <input type="radio" name="metaLoaded" value="yes" hidden="true">
                        Does the CSV contain a header for column names?<br>
                        <input type="radio" name="header" id="isHeader" value="Yes" checked>Yes<br>
                        <input type="radio" name="header" id="isNotHeader" value="No">No<br>
                    % else:
                        Is there a CSV containing the metadata?<br>
                        <input type="radio" name="metaExist" id="isMetadata" value="Yes" disabled="" checked>Yes<br>
                        <input type="radio" name="metaExist" id="noMetadata" value="No" disabled="">No<br>
                        <input type="radio" name="metaLoaded" value="yes" hidden="true" checked>
                        Does the CSV contain a header for column names?<br>
                        <input type="radio" name="header" id="isHeader" value="Yes" checked>Yes<br>
                        <input type="radio" name="header" id="isNotHeader" value="No">No<br>
                    % endif
                    CSV File:<br>
                    <input type="file" name="my_file" id="my_file"><br>
                    <label class="label label-default">Delimiter: </label><br>
                    <input type="text" name="delimiter" id="delimiter" placeholder="Delimiter">
                    <br>Target Location:<br>
                    Does the target table already exist?<br>
                    <input type="radio" name="texists" id="tdoesExist" value="Yes" checked>Yes<br>
                    <input type="radio" name="texists" id="tnotExist" value="No">No<br>
                    <div class="container" id="DBTableInfo">
                        <div class="database">
                            <label class="label label-default">Database</label><br>
                            <select name="selDB" id="selDB">
                                <option value="">--Select Database--</option>
                                % for dbName in dbNames:
                                    <option> ${dbName} </option>  
                                % endfor
                            </select>
                        </div>
                        <div style="display: inline;">
                            <label class="label label-default">Table</label><br>
                            <input type="text" id="newTable" name="table2" placeholder="Table Name" style="display: none;">
                            <select name="selTable" id="selTable">
                            </select>
                        </div>
                    </div>
                    <input type="hidden" name="colAmt" id="colAmt" value="1" hidden="true"><br>
                    <input style="clear: both" class="btn btn-success" type="submit" value="Submit">
                </div>
                <div class="newColumns" id="dbTableForm" style="float:right; width: 900px;" hidden="">
                    <h3> Column names and types for new table being created: </h3>
                    <br>
                    <input type="text" id="colName1" name="Column Name 1" value="Column Name 1" onfocus="if (this.value=='Column Name 1') this.value='';" onblur="if (this.value=='') this.value='Column Name 1';">
                    <select name="coltype1">
                        <option value="int">Integer</option>
                        <option value="float">Float</option>
                        <option value="string">String</option>
                        <option value="datetime">Datetime</option>
                        <option value="bool">Bool</option>
                    </select>
                    <input class="btn btn-primary" type="button" id="addCol" value="Add Column">
                    <br>
                </div>
            </form>
            % if metaInfo == '':
                <div name="metadata" id="metadata" style="width: 250px; visibility: visible; position: absolute; top: 195px; left: 370px">
                    <strong id="noMetaFile" style="color: rgb(165,73,83); visibility: hidden;">NO META INFORMATION FILE SELECTED!</strong>
                    <form action="" method="post" enctype="multipart/form-data" id="metaForm">
                        ${ csrf_token(request) | n,unicode }
                        Metadata CSV File:<br>
                        <input type="file" name="metaCSV" id="metaCSV">
                        <br><br>
                        <input class="btn btn-success" type="submit" value="Submit"><br>
                    </form>
                </div>
            % else:
                <div name="metadata" id="metadata" style="width: 250px; visibility: visible; position: absolute; top: 210px; left: 370px">
                    <pre>${metaInfo}</pre> <br>
                    <form action=''>
                        <input class="btn btn-danger" type="submit" value="Delete Metadata">
                    </form>
                </div>
            % endif
            <div id="columns" name="columns" style="position: absolute;top: 210px; left: 700px; align-content: left; width: 500px; height: 400px visibility: hidden">
                <h4 id = "columnID" style="visibility: hidden;"> Columns: </h4>
                <p name="columnNames" id="columnNames" style="font-size: 15px">
                </p>
            </div>
        </div>
    </div>
</div>

<div class="loader"><p></p></div>

    <script src="/static/dataIngest/js/csv.js"></script>
        
${commonfooter(None, messages) | n,unicode}

