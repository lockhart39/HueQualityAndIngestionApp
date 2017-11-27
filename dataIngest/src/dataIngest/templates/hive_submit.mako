<%!from desktop.views import commonheader, commonfooter %>
<%namespace name="shared" file="shared_components.mako" />

%if not is_embeddable:
${commonheader("dataIngest", "dataIngest", user, request) | n,unicode}
%endif

${shared.menubar(section='Hive2Hive')}

## Use double hashes for a mako template comment
## Main body

<div class="container-fluid">
  <div class="card">
    <h2 class="card-heading simple">Hive to Hive Ingestion</h2>
    <div class="card-body">
      
	<h3 style="font-size:200%">${results}</strong></h3>
  	<form action="." method="POST" style="text-align:left; padding-bottom: 10%">
  		${ csrf_token(request) | n,unicode }
		<br><input class="btn btn-primary" type ="submit" value="Return" id="return" name="return">
	</form>   		  			
</body>
</head>
    </div>
  </div>
</div>
%if not is_embeddable:
${commonfooter(None, messages) | n,unicode}
%endif%




