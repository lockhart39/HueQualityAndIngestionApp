$(document).ready(function(){
    $("#selStgDB").chosen();
    $("#selDBName").chosen();
    $("#selTable").chosen();
    $("#selColumns").chosen();
    $("#selStgTable").chosen();
});

$body = $("body");

$(document).on({
    ajaxStart: function() { $body.addClass("loading");  },
    ajaxStop: function() { $body.removeClass("loading"); }    
});

$("#selDBName").change( function(){
    $.ajax({
        url : "/dataIngest/ajax/getTables/?" + 
            "db=" + $("#selDB").val() + "&" +
            "dbName=" + $("#selDBName").val() + "&" +
            "p=" + $("#txtPassword").val() + "&" +
            "u=" + $("#txtUsername").val(),
        type : 'GET',
        dataType:'json',
        beforeSend: function(){
            $(".loader > p").text("Fetching Tables");
        },
        complete: function(){
            $(".loader > p").text(""); 
        },
        success: function(data) {              
            $("[name=divTable]").empty();
            $("[name=divColumns]").empty();
            var lab = $("<label class='label label-default'>Table: </label>").appendTo($("[name=divTable]"));
            var sel = $('<select id="selTable" name="selTable">').appendTo($("[name=divTable]"));
            $(data).each(function() {
                sel.append($("<option>").attr('value',this).text(this));
            });
            sel.change(getColumns);
            if(!$("#selTable").is(':empty')){
                getColumns();
            } 
            $("#selTable").chosen();
        },
        failure: function(data,error,other)
        {
            alert("ERROR FETCHING TABLES");
        }
    });      
}); 

function getColumns(){
    $.ajax({
        url : "/dataIngest/ajax/getColumns/?" + 
            "db=" + $("#selDB").val() + "&" +
            "dbName=" + $("#selDBName").val() + "&" +
            "p=" + $("#txtPassword").val() + "&" +
            "t=" + $("#selTable").val() + "&" +
            "u=" + $("#txtUsername").val(),
        type : 'GET',
        dataType:'json',
        beforeSend: function(){
            $(".loader > p").text("Fetching Columns");
        },
        complete: function(){
            $(".loader > p").text(""); 
            $('#selColumns').bind('change', updateLeftColumns); 
        },
        success: function(data) {              
            $("[name=divColumns]").empty();
            var lab = $("<label class='label label-default'>Column(s): </label>").appendTo($("[name=divColumns]"));
            var sel = $('<select multiple id="selColumns" name="selColumns" class="chosen-select">').appendTo($("[name=divColumns]"));
            var selAll = $("<button type='button' class='btn btn-primary' style='width: 50%; float: left;'>Select All</button>").appendTo($("[name=divColumns]"));
            var removeAll = $("<button type='button' class='btn btn-danger' style='width: 50%;'>Remove All</button>").appendTo($("[name=divColumns]"));
            $('.btn-primary').click(function(){
                $('#selColumns > option').prop('selected', true);
                $('#selColumns').trigger('chosen:updated');
                updateLeftColumns();
            });
            $('.btn-danger').click(function(){
                $('#selColumns > option').prop('selected', false);
                $('#selColumns').trigger('chosen:updated');
                updateLeftColumns();
            });
            $("#leftTable > thead > tr").empty();
            $("#leftTable > tbody > tr").empty();
            $("#leftTable > caption").empty().append("<h3>" + $("#selTable").val() + "</h3>");
            $(data).each(function() {
                sel.append($("<option>").attr('value',this).text(this));
                $("#leftTable > thead > tr").append($("<th>" + this + "</th>"));
                $("#leftTable > tbody > tr").append($("<td class='td_" + this + "'>" + "Sample Data" + "</td>"));
                $("#leftTable > tbody > tr > td").hide();
                $("#leftTable > thead > tr > th").hide();
            });
            $("#txtSplitBy").val($(data)[0]);
            $("#selColumns").chosen();
            updateLeftColumns();
        },
        failure: function(data,error,other)
        {
            alert("ERROR FETCHING COLUMNS");
        }
    });      
} 

function updateLeftColumns(){
    var show = false;
    $("#selColumns > option").each(function() {
        if($(this).is(':selected')){
            $("#leftTable > thead > tr > th:contains('" + $(this).val() + "')").show();
            $(".td_" + $(this).val()).show();
            show = true;
        }
        else{
            $("#leftTable > thead > tr > th:contains('" + $(this).val() + "')").hide();
            $(".td_" + $(this).val()).hide();
        }
    });
    if(show){
        $("#leftTable").parent().show();
        if($("#rightTable").parent().is(":visible")){ $(".arrowDiv").show(); }
        else{ $(".arrowDiv").hide(); }
    }
    else{
        $("#leftTable").parent().hide();
        $(".arrowDiv").hide();
    }
}

function checkboxClicked(obj){
    if($(obj).prop('checked') == true){
        $("#txtStgTable").css('display', '');
        $("#selStgTable").prop('disabled', true).trigger("chosen:updated");
    }
    else{
        $("#txtStgTable").css('display', 'none').val("");
        $("#selStgTable").prop('disabled', false).trigger("chosen:updated");
    }
}

$("#selStgDB").change( function(){
    $("#selStgTable").prop('disabled', true).trigger("chosen:updated");
    $.ajax({
        url : "/dataIngest/ajax/getHiveTables/?" + "db=" + $("#selStgDB").val(),
        type : 'GET',
        dataType:'json',
        beforeSend: function(){
            $(".loader > p").text("Fetching Hive Tables");
        },
        complete: function(){
            $(".loader > p").text(""); 
            $('#selStgTable').bind('change', updateRightTable); 
            $("#rightTable > thead > tr").empty();
            $("#rightTable > tbody > tr").empty();
        },
        success: function(data) {              
            $("#divStgTable").empty();
            var lab = $("<label class='label label-default'>Table: </label>").appendTo($("#divStgTable"));
            var sel = $('<select id="selStgTable" name="selStgTable">').appendTo($("#divStgTable"));
            var chkbox = $("<label>Create New Table: <input type='checkbox' onclick='checkboxClicked(this)' /> </label>").appendTo("#divStgTable");
            var input = $("<input type='text' name='txtStgTable' id='txtStgTable' style='display: none;' placeholder='Enter New Table Name...'/>").appendTo($("#divStgTable"));
            sel.append($("<option>"));
            $(data).each(function() {
                myValue = this.replace(/\x00/g, ""); // replace null character "\x00" with blank spaces 
                sel.append($("<option>").attr('value',myValue).text(myValue));
            });
            $("#selStgTable").chosen();
            $("#rightTable").parent().hide();
            $(".arrowDiv").hide();
        },
        failure: function(data,error,other)
        {
            alert("ERROR FETCHING TABLES");
        }
    });      
}); 

function updateRightTable(){
    $.ajax({
        url : "/dataIngest/hive_query/ajax/getColHive/?" + "db=" + $("#selStgDB").val() + "&t=" + $("#selStgTable").val(),
        type : 'GET',
        dataType:'json',
        beforeSend: function(){
            $(".loader > p").text("Fetching Hive Columns");
        },
        complete: function(){
            $(".loader > p").text(""); 
        },
        success: function(data) {              
            $("#rightTable > thead > tr").empty();
            $("#rightTable > tbody > tr").empty();
            $("#rightTable > caption").empty().append("<h3>" + $("#selStgTable").val() + "</h3>");
            $(data).each(function() {
                $("#rightTable > thead > tr").append($("<th>" + this + "</th>"));
                $("#rightTable > tbody > tr").append($("<td>" + "Sample Data" + "</td>"));
            });
            if($("#leftTable").parent().is(":visible")){ $(".arrowDiv").show(); }
            $("#rightTable").parent().show();
        },
        failure: function(data,error,other)
        {
            alert("ERROR FETCHING COLUMNS");
        }
    });      
}

function submitClicked(){
    if( !$("#selDBName").val() ){ return alert("Select a source database"); }
    if( !$("#selTable").val() ){ return alert("Select a source table"); }
    if( !$("#selColumns").val() ){ return alert("Select column(s)"); }
    if( !$("#selStgDB").val() ){ return alert("Select a staging database"); }
    if( (!$("#selStgTable").val() || $("#selStgTable").prop('disabled')) && !$("#txtStgTable").val() ){ return alert("Select a staging table"); }
    $body.addClass("loading");
    $(".loader > p").text("Running Sqoop");
    $("#sqoopSubmit").click(); 
}
