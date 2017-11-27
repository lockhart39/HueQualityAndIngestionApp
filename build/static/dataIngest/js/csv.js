$(document).ready(function(){
    $("#selDB").chosen();
    $("#selTable").chosen();
});

$body = $("body");

$(document).on({
    ajaxStart: function() { $body.addClass("loading");  },
    ajaxStop: function() { $body.removeClass("loading"); }    
});

document.getElementById("tnotExist").onchange = function(){
    if(document.getElementById("isHeader").checked == false && document.getElementById("isHeader").disabled == false && document.getElementById("isMetadata").checked == false){
        document.getElementById("dbTableForm").hidden=false;
    }
    document.getElementById("columns").style.visibility="hidden";
    document.getElementById("columnID").style.visibility="hidden";
    $("#selTable_chosen").hide();
    $("#newTable").show();
}

document.getElementById("tdoesExist").onchange = function(){
    document.getElementById("dbTableForm").hidden=true;
    document.getElementById("columns").style.visibility="visible";
    $("#columnNames").empty();
    $("#selTable_chosen").show();
    $("#newTable").hide();
    getTables();
}

document.getElementById("isHeader").onchange = function(){
    document.getElementById("dbTableForm").hidden=true;
}

document.getElementById("isNotHeader").onchange = function(){
    if(document.getElementById("tdoesExist").checked == false){
        document.getElementById("dbTableForm").hidden = false;
        document.getElementById("columns").style.visibility="hidden";
    }
}

document.getElementById("isMetadata").onchange = function(){
    document.getElementById("metadata").style.visibility="visible";
    document.getElementById("dbTableForm").hidden = true;
}

document.getElementById("noMetadata").onchange = function(){
    document.getElementById("metadata").style.visibility="hidden";
    document.getElementById("noMetaFile").style.visibility="hidden";
    if(document.getElementById("tnotExist").checked == true && document.getElementById("isNotHeader").checked == true){
        document.getElementById("dbTableForm").hidden = false;
    }
}

$("#selDB").change(function(){
    if(document.getElementById("tdoesExist").checked == true){
        getTables();
    }
})

$("#selTable").change(function(){
    getColumns();
})

$('#myForm').submit(function(event){
    validated = true;

    if ($('#my_file').get(0).files.length === 0) {
        validated = false;
        console.log("No files selected.");
        document.getElementById("noFile").hidden = false;
        // Or some div with image showing
    }

    if (validated != true) {
        event.preventDefault();
    }
});


$('#metaForm').submit(function(event){
    validated = true;

    if ($('#metaCSV').get(0).files.length === 0) {
        validated = false;
        console.log("No files selected.");
        $("#noMetaFile").css('visibility', 'visible');
        // Or some div with image showing
    }

    if (validated != true) {
        event.preventDefault();
    }
});


function getTables(){
    $.ajax({
        url : "/dataIngest/ajax/getHiveTables/?" + "db=" + $("#selDB").val(),
        type : 'GET',
        dataType:'json',
        beforeSend: function(){
            $(".loader > p").text("Fetching Tables");
        },
        complete: function(){
            $(".loader > p").text(""); 
        },
        success: function(data) {   
            tables = $("#selTable");
            tables.empty();
            tables.append($("<option>").text('--Select Table--'));

            $(data).each(function() {
                myValue = this.replace(/\x00/g, ""); // replace null character "\x00" with blank spaces 
                tables.append($("<option>").attr('value',myValue).text(myValue));
            });
            $('#selTable').trigger('chosen:updated');
        },
        failure: function(data,error,other)
        {
            alert("ERROR FETCHING TABLES");
        }
    });          
}

function getColumns(){
    $.ajax({
        url : "/dataIngest/hive_query/ajax/getColHive/?" + 
            "db=" + $("#selDB").val() + "&" +
            "t=" + $("#selTable").val(),
        type : 'GET',
        dataType:'json',
        beforeSend: function(){
            $(".loader > p").text("Fetching Columns");
        },
        complete: function(){
            $(".loader > p").text(""); 
        },
        success: function(data) {   
            columns = $("#columnNames");
            columns.empty();
            $("#columnID").css('visibility', 'visible');
            $(data).each(function() {
                myValue = this.replace(/\x00/g, ""); // replace null character "\x00" with blank spaces 
                columns.append(myValue + '<br>');
            });
        },
        failure: function(data,error,other)
        {
            alert("ERROR FETCHING TABLES");
        }
    });
}


var clicks = [1]
//Add Column Name/Type Field
document.getElementById("addCol").onclick = function() {
    var myDiv = document.getElementById("dbTableForm");
    var input = document.createElement("input");
    clicks.push(clicks[clicks.length - 1] + 1);
    var num = clicks[clicks.length - 1];
    //console.log(clicks[clicks.length - 1]);
    input.type = "text";
    input.id = "colName" + num.toString() ;
    input.value = "Column Name " + num.toString();
    input.name = input.value;
    input.onfocus = function() {inputFocus(this)}
    input.onblur = function() {inputBlur(this)}
    var textArray = ["Integer", "Float", "String", "Date", "Bool"];
    var valueArray = ["int", "float", "string", "datetime", "bool"];
    var selectList = document.createElement("select");
    selectList.id = "coltype" + num.toString();
    selectList.name = selectList.id;
    myDiv.appendChild(input);
    myDiv.appendChild(selectList);
    for (var i = 0; i < textArray.length; i++) {
        var option = document.createElement("option");
        option.value = valueArray[i];
        option.text = textArray[i];
        selectList.appendChild(option);
    }
    removeButton = document.createElement('input');
    removeButton.className = "btn btn-danger";
    removeButton.type = 'button'
    removeButton.id = 'rmCol' + num.toString();
    removeButton.value = 'Remove Column';
    removeButton.onclick = function() {rmclick(this)}
    myDiv.appendChild(removeButton);
    var br = document.createElement("br");
    br.id = "br" + num.toString();
    myDiv.appendChild(br);  
    var amt = document.getElementById("colAmt");
    amt.value = '';
    for(var i = 0; i < clicks.length; i++){
        amt.value += clicks[i].toString() + ',';
    }
}
// Remove Column Name/Type Field
function rmclick(obj){
    // var rmv = document.getElementById()
    var num = obj.id.slice(5,obj.id.length);
    // console.log(num);
    var textbox = "colName" + num;
    var dropdown = "coltype" + num;
    var brk = "br" + num;
    // console.log(textbox);
    var myDiv = document.getElementById("dbTableForm");
    var text = document.getElementById(textbox);
    var drop = document.getElementById(dropdown);
    var br = document.getElementById(brk)
    myDiv.removeChild(text);
    myDiv.removeChild(drop);
    myDiv.removeChild(obj);
    myDiv.removeChild(br);
    //clicks -= 1;
    var index = clicks.indexOf(parseInt(num));
    //console.log(num);
    if(index > -1){
        clicks.splice(index, 1);
    }
    var amt = document.getElementById("colAmt");
    amt.value = '';
    for(var i = 0; i < clicks.length; i++){
         amt.value += clicks[i].toString() + ',';
    }
}

function inputFocus(obj){
    if(obj.value == obj.name){
        obj.value = '';
    }
}

function inputBlur(obj){
    if(obj.value == ''){
        obj.value = obj.name;
    }
}


/*    -\-                                                     
    \-- \-                                                  
     \  - -\                                                
      \      \\                                             
       \       \                                            
        \       \\                                              
         \        \\                                            
         \          \\                                        
         \           \\\                                      
          \            \\                                                 
           \            \\                                              
           \. .          \\                                  
            \    .       \\                                 
             \      .    \\                                            
              \       .  \\                                 
              \         . \\                                           
              \            <=)                                         
              \            <==)                                         
              \            <=)                                           
               \           .\\                                           _-
               \         .   \\                                        _-//
               \       .     \\                                     _-_/ /
               \ . . .        \\                                 _--_/ _/
                \              \\                              _- _/ _/
                \               \\                      ___-(O) _/ _/ 
                \                \                  __--  __   /_ /   
                \                 \\          ____--__----  /    \_     
                 \                  \\       -------       /   \_  \_     
                  \                   \                  //   // \__ \_
                   \                   \\              //   //      \_ \_ 
                    \                   \\          ///   //          \__- 
                    \                -   \\/////////    //            
                    \            -         \_         //              
                    /        -                      //                
                   /     -                       ///                  
                  /   -                       //                      
             __--/                         ///
  __________/                            // |               
//-_________      ___                ////  |                
        ____\__--/                /////    |                
   -----______    -/---________////        |                
     _______/  --/    \                   |                 
   /_________-/       \                   |                 
  //                  \                   /                 
                       \.                 /                 
                       \     .            /                 
                        \       .        /                  
                       \\           .    /                  
                        \                /                  
                        \              __|                  
                        \              ==/                  
                        /              //                   
                        /          .  //                    
                        /   .  .    //                      
                       /.           /                       
                      /            //                       
                      /           /
                     /          //
                    /         //
                 --/         /
                /          //
            ////         //
         ///_________////*/