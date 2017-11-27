$(document).ready(function(){
    $("#exportDB").chosen();
    $("#exportTable").chosen();
    $("#exportCols").chosen();
});

$body = $("body");

$(document).on({
    ajaxStart: function() { $body.addClass("loading");  },
    ajaxStop: function() { $body.removeClass("loading"); }    
});

$("#exportDB").change(function(){
    getHiveTables();
})

$("#exportTable").change(function(){
    getHiveColumns();
})

// $("#exportCols").change(function(){
//     if(){
        
//     }
// })

$('#selectAll').click(function(){
    $('#exportCols > option').prop('selected', true);
    $('#exportCols').trigger('chosen:updated');
    //updateLeftColumns();
});
$('#clearAll').click(function(){
    $('#exportCols > option').prop('selected', false);
    $('#exportCols').trigger('chosen:updated');
    //updateLeftColumns();
});

function getHiveTables(){
    $.ajax({
        url : "/dataIngest/ajax/getHiveTables/?" + "db=" + $("#exportDB").val(),
        type : 'GET',
        dataType:'json',
        beforeSend: function(){
            $(".loader > p").text("Fetching Tables");
        },
        complete: function(){
            $(".loader > p").text(""); 
        },
        success: function(data) {   
            tables = $("#exportTable");
            tables.empty();
            tables.append($("<option>").text(''));

            $(data).each(function() {
                myValue = this.replace(/\x00/g, ""); // replace null character "\x00" with blank spaces 
                tables.append($("<option>").attr('value',myValue).text(myValue));
            });
            $('#exportTable').trigger('chosen:updated');
        },
        failure: function(data,error,other)
        {
            alert("ERROR FETCHING TABLES");
        }
    });          
}

function getHiveColumns(){
    $.ajax({
        url : "/dataIngest/hive_query/ajax/getColHive/?" + 
            "db=" + $("#exportDB").val() + "&" +
            "t=" + $("#exportTable").val(),
        type : 'GET',
        dataType:'json',
        beforeSend: function(){
            $(".loader > p").text("Fetching Columns");
        },
        complete: function(){
            $(".loader > p").text(""); 
        },
        success: function(data) {   
            columns = $("#exportCols");
            columns.empty();
            $(data).each(function() {
                myValue = this.replace(/\x00/g, ""); // replace null character "\x00" with blank spaces 
                columns.append($("<option>").attr('value', myValue).text(myValue));
            });
            $('#exportCols').trigger('chosen:updated');
        },
        failure: function(data,error,other)
        {
            alert("ERROR FETCHING TABLES");
        }
    });
}

function submitClicked(){
    if( !$('#exportDB').val() ){ return alert("Select a Source Database"); }
    if( !$('#exportTable').val() ){ return alert("Select a Source Table"); }
    if( !$('#exportCols').val() ){ return alert("Select Column(s)"); }
    if( !$('#fileName').val() ){ return alert("Input a File Name"); }
    if( !$('#filePath').val() ){ return alert("Input a File Path"); }
    if( !$('#delimiter').val() ){ return alert("Input a Delimiter"); }
    $body.addClass("loading");
    $(".loader > p").text("Running Export");
    $("#exportSubmit").click();
}