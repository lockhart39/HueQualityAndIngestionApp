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

${shared.menubar(section='H2H')}

## Use double hashes for a mako template comment
## Main body
<div class="container-fluid">
  <div class="card">
    <h2 class="card-heading simple">Hive to Hive Ingestion</h2>
    <div class="card-body">
      
  	<form action="." method="POST" style="text-align:left; padding-bottom: 10%">
	
  	${ csrf_token(request) | n,unicode }
  	<table>
  	%for field in form.fields:
##	<% print field %>
  	<tr><th align="center" bgcolor=#F1F1F1 width=250 height=20>${form[field].label}</th> 
	<td align="left"> <div>  ${form[field]|n,unicode} </div>   </td><td></td></tr>
  	%endfor
  	</table>
	<input class= "btn btn-success" type="submit" value="Submit">



	%for key in form.errors:
		%if key =="__all__":
			<h3>${ form.errors[key]|n,unicode}</h3>
		%endif
	%endfor


  	</form>
    </div>
  </div>
</div>
<div class="loader"><p></p></div>
%if not is_embeddable:
${commonfooter(None, messages) | n,unicode}
%endif%


<script>
$body = $("body");

$(document).on({
    ajaxStart: function() { $body.addClass("loading");  },
    ajaxStop: function() { $body.removeClass("loading"); }    
});
if(document.getElementById("id_datebtwn").checked === false){
	document.getElementById("id_datename").setAttribute("disabled",true);
	document.getElementById("id_startdate").setAttribute("disabled",true);
	document.getElementById("id_enddate").setAttribute("disabled",true);
	}
if(document.getElementById("id_colbtn").checked === false){
	document.getElementById("id_srccol").setAttribute("disabled",true);
	}
/*function selectStyleSetter(thing){
	thing.style = "width:187px;"
	}
selectStyleSetter(document.getElementById("id_srcdbase"))
selectStyleSetter(document.getElementById("id_srctable"))
selectStyleSetter(document.getElementById("id_dstdbase"))
selectStyleSetter(document.getElementById("id_dsttable"))
*/
document.getElementById("id_colbtn").onclick = function(){
	if (document.getElementById("id_colbtn").checked){	
	//make the col choices visible?
	msf=document.getElementById("id_srccol");
	msf.removeAttribute("disabled");
		}
	else{
        //make the col choices vanish?
	msf=document.getElementById("id_srccol");
	msf.setAttribute("disabled",true);
		}

	}

document.getElementById("id_datebtwn").onclick = function(){
	if (document.getElementById("id_datebtwn").checked){	
	//make the date text boxes enabled
		document.getElementById("id_datename").removeAttribute("disabled");
		document.getElementById("id_startdate").removeAttribute("disabled");
		document.getElementById("id_enddate").removeAttribute("disabled");		
	}
	else{
        //make the date text boxes disabled
		document.getElementById("id_datename").setAttribute("disabled",true);
		document.getElementById("id_startdate").setAttribute("disabled",true);
		document.getElementById("id_enddate").setAttribute("disabled",true);
		}

	}
//Initiating ajax requests
populateSelect(document.getElementById("id_srcdbase"),"ajax/getDatabasesHive/?",1);
populateSelect(document.getElementById("id_dstdbase"),"ajax/getDatabasesHive/?",2);
document.getElementById("id_srcdbase").onchange=function(){
	populateSelect(document.getElementById("id_srctable"),"ajax/getTablesHive/?",1);
	};
document.getElementById("id_dstdbase").onchange=function(){
	populateSelect(document.getElementById("id_dsttable"),"ajax/getTablesHive/?",2);
	};
document.getElementById("id_srctable").onchange = function(){ 
populateSelect(document.getElementById("id_srccol"), "ajax/getColHive/?",1) 
	};
       


function populateSelect(mySelect, url,dist) {
	    $body.addClass("loading");  
            var xmlhttp = new XMLHttpRequest();
            var select = mySelect;
	    var db =" "
            if(dist == 1){
            	db = "db=" + document.getElementById("id_srcdbase").value;
		}
	    else{
	    	db = "db=" + document.getElementById("id_dstdbase").value;	
		}
            var username = "u=jdbc:hive2://localhost:10000";
	    if(dist ==1){
            	var table = "t=" + document.getElementById("id_srctable").value;
		}
	    else{
		var table = "t=" + document.getElementById("id_dsttable").value;
		}
            var params = db + "&"+ username+"&" + table;

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
                        /*  console.log("AJAX ERROR: " + xmlhttp.statusText);
                        document.getElementById("txtMessage").innerHTML = "ERROR STATUS: " + xmlhttp.status + " --> " + xmlhttp.statusText;
                        document.getElementById("txtMessage").className = "error";
                        if (select.id == "selDB"){
                            document.getElementById("txtMessage").innerHTML += " --> Username/Password may be incorrect" */
                    } 
                }               
            }
            xmlhttp.open("GET", url + params, true);
            xmlhttp.send();
            document.getElementById("id_srcdbase").value = ""
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
