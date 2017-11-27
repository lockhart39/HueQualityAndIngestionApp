<%!from desktop.views import commonheader, commonfooter %>
<%namespace name="shared" file="shared_components.mako" />

%if not is_embeddable:
    ${commonheader("dataIngest", "dataIngest", user, request) | n,unicode}
%endif

${shared.menubar(section='Export')}

## Use double hashes for a mako template comment
## Main body
<div class="container-fluid" style="align: left;>
    <div class="card">
        <h2 class="card-heading simple">Database Export</h2>
        <div class="card-body">
	<form method="post" class="container">
            ${ csrf_token(request) | n,unicode }
	<div style="display: inline-block; vertical-align:top;" align="left">
	<h3>Hive Source</h3>
	<label class = "label label-default">Database:</label><br>
	<select name="hiveDbase" id="hiveDbase">
	 <option></option>
         </select><br>
	<label class = "label label-default">Table:</label><br>
	<select name="hiveTable" id ="hiveTable">
	 <option></option>
        </select><br>
	</div>
	


	<div style="display: inline-block; padding-right: 30px; padding-left: 30px;vertical-align:top; horizontal-align:left; ">
	<br><br><br><br><br><br><br><br><br>
	<h2 > ---></h2>

	</div>


	<div style="display: inline-block;" align="left">
	<h3>Destination</h3>
	<label class = "label label-default">Username:</label><br>
	<input type="text" name="username" id="username"><br>
	<label class = "label label-default">Password:</label><br>
	<input type="password" name="password" id="password"><br>
	<label class = "label label-default">Database:</label><br>
	<select name="sqlDbase" id="sqlDbase">
	 	<option></option>
        </select><br>
	<label class = "label label-default">Table:</label><br>
	<select name="sqlTable" id="sqlTable">
	 	<option></option>
        </select>

	</div>
	<br>
	<input type="submit" value="Export" class="exportButton">
</form>


              <style type="text/css">
                .exportDiv {float: left; text-align: right;}
		.exportButton {color: white; background-color: #2BB240; padding: 1% 8% 1% 8%;}
		.container label {width: 96.5%; margin-bottom: 0px;}
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
/* When the body has the loading class, we turn the scrollbar off with overflow:hidden */
		body.loading {
    				overflow: hidden;   
			     }

/* Anytime the body has the loading class, our loader element will be visible */
		body.loading .loader {
   				 display: block;
			     }
              </style>
        </div>
    </div>
</div>
<div class="loader"><p></p></div>
%if not is_embeddable:
    ${commonfooter(None, messages) | n,unicode}
%endif%

<script>
$body = $("body");
populateSelect(document.getElementById("hiveDbase"),"ajax/getDatabasesHive/?",2);

document.getElementById("hiveDbase").onchange=function(){
	populateSelect(document.getElementById("hiveTable"),"ajax/getTablesHive/?",2);
	};

document.getElementById("sqlDbase").onchange=function(){
	populateSelect(document.getElementById("sqlTable"),"ajax/getTablesSql/?",1);
	};

document.getElementById("password").onblur =function(){
	populateSelect(document.getElementById("sqlDbase"),"ajax/getDatabasesSql/?",1);
	};





function populateSelect(mySelect, url,dist) {
	    $body.addClass("loading");  
            var xmlhttp = new XMLHttpRequest();
            var select = mySelect;
	    var db =" "
            if(dist == 1){
            	db = "db=" + document.getElementById("sqlDbase").value;
		}
	    else{
	    	db = "db=" + document.getElementById("hiveDbase").value;	
		}
            var username = ""
	    var password =""
	    if(dist==1){
			username = "u="+ document.getElementById("username").value;
			password = "p="+ document.getElementById("password").value;
			}
	    else{
		 username= "u=jdbc:hive2://localhost:10000";
		 password= "p=filler"
		} 
	    if(dist ==1){
            	var table = "t=" + document.getElementById("sqlTable").value;
		}
	    else{
		var table = "t=" + document.getElementById("hiveTable").value;
		}
            var params = db + "&"+ username+"&" + table+"&"+password;

            xmlhttp.onreadystatechange = function() {
                if (xmlhttp.readyState == XMLHttpRequest.DONE ) {
			        if (xmlhttp.status == 200) {
                        
                        var json = JSON.parse(xmlhttp.responseText);
                        var count = Object.keys(json).length;
                        removeOptions(select);
			
			
                        for(var i = 0; i < count; i++) {
			               
                            var opt = json[i];
                            var el = document.createElement("option");
                            el.textContent = opt;
                            el.value = opt;
                            select.appendChild(el);
		            $body.removeClass("loading");
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
            ##document.getElementById("id_srcdbase").value = ""
        }

    function removeOptions(selectbox)
    {	
        var i;
        for(i = selectbox.options.length - 1 ; i >= 0 ; i--)
        { 
            selectbox.remove(i);
        }
	
}











</script>
