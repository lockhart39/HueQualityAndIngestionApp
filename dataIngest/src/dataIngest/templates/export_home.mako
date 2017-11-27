<%!from desktop.views import commonheader, commonfooter %>
<%namespace name="shared" file="shared_components.mako" />

%if not is_embeddable:
    ${commonheader("dataIngest", "dataIngest", user, request) | n,unicode}
%endif

${shared.menubar(section='Export')}

## Use double hashes for a mako template comment
## Main body
<div class="container-fluid">
    <div class="card">
        <h2 class="card-heading simple">Export</h2>
        <div class="card-body">
    
	<form method="POST" action="." >
	${ csrf_token(request) | n,unicode }
	Export Destination:
	<br>
	<select id="export_dest" name ="export_dest">
	<option value ="database">Database</option>
	<option value ="csv">CSV</option>
	</select>
	<br>
	<input type ="submit" id="continue" name="continue" value="next">	
	</form>

            </div>
              <style type="text/css">
                .exportDiv {float: left; text-align: right;}
		.exportButton {color: white; background-color: #2BB240; padding: 1% 8% 1% 8%;}
              </style>
        </div>
    </div>
</div>
%if not is_embeddable:
    ${commonfooter(None, messages) | n,unicode}
%endif%

