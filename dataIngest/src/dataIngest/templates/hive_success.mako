<%!from desktop.views import commonheader, commonfooter %>
<%namespace name="shared" file="shared_components.mako" />

%if not is_embeddable:
${commonheader("dataIngest", "dataIngest", user, request) | n,unicode}
%endif
<style>
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
${shared.menubar(section='Hive2Hive')}

## Use double hashes for a mako template comment
## Main body

<div class="container-fluid">
  <div class="card">
    <h2 class="card-heading simple">Hive to Hive Ingestion</h2>
    <div class="card-body">
      
	<h3 style="font-size:200%"><strong>Generated Query:</strong></h3>
	<textarea name="query" id="query" rows="8" style="width:50%; height:30%;" disabled = true>${s} </textarea><br>
	<input class="btn btn-info" type = "submit" id="modify" Value ="Modify Query"><br><br>
<form action="." method="POST" style="text-align:left; padding-bottom: 10%">
<input class="btn btn-success"type="submit" value="Submit" id="submit">
	<h3 style="font-size:200%"><strong>Sample Data:</strong></h3>	
  	
	<textarea name="sample" id="sample" rows="15" style="width:100%; height:30%;" disabled= true>${qs}</textarea><br>
  		${ csrf_token(request) | n,unicode }
		
		<br><input class="btn btn-primary" type ="submit" value="Return" id="return" name="return">
		<input type="hidden" id="hidden" name="hidden">	 
	</form>
<div class="loader"><p></p></div>	 		  			
</body>
</head>
    </div>
  </div>
</div>

%if not is_embeddable:
${commonfooter(None, messages) | n,unicode}
%endif%

<script>
$body = $("body");

$(document).on({
    ajaxStart: function() { $body.addClass("loading");  },
    ajaxStop: function() { $body.removeClass("loading"); }    
});

if(document.getElementById("sample").value == "Query returned error or no data, please check your syntax."){
		document.getElementById("submit").setAttribute("disabled",true);	
		}
document.getElementById("hidden").value = document.getElementById("query").value



document.getElementById("modify").onclick = function(){
	if(document.getElementById("modify").value ==="Modify Query"){
	document.getElementById("query").removeAttribute("disabled");
	document.getElementById("modify").value ="Save Query";
	document.getElementById("submit").setAttribute("disabled",true);

		}
	else{
	$("#modify").attr('value','Modify Query');
	document.getElementById("query").setAttribute("disabled",true);
	populateText(document.getElementById("query"),"ajax/getSample/?")
	document.getElementById("hidden").value = document.getElementById("query").value
	
		}
	}









function populateText(myTextArea, url) {
	    $body.addClass("loading");
            var xmlhttp = new XMLHttpRequest();
            var text = myTextArea;
	    var fix = document.getElementById("query").value
	    fix = fix.replace(/\r?\n/g, " ");
	    var query = "query="+fix;
            var params = query;

            xmlhttp.onreadystatechange = function() {
                if (xmlhttp.readyState == XMLHttpRequest.DONE ) {
			        if (xmlhttp.status == 200) {
                        var json = JSON.parse(xmlhttp.responseText);
       			document.getElementById("sample").value = json
			$body.removeClass("loading");
                        if(document.getElementById("sample").value == "Query returned error or no data, please check your syntax."){
		document.getElementById("submit").setAttribute("disabled",true);	
		}
	else{
		document.getElementById("submit").removeAttribute("disabled");
	}
			
			
                       
                    }
                    else {
				    $body.removeClass("loading");
			            alert("It broke");
                    } 
                }               
            }
            xmlhttp.open("GET", url + params, true);
            xmlhttp.send();
        }





</script>
