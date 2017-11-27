<%!from desktop.views import commonheader, commonfooter %>
<%!from datetime import datetime %>
<%namespace name="shared" file="shared_components.mako" />

%if not is_embeddable:
${commonheader("dataIngest", "dataIngest", user, request) | n,unicode}
%endif

${shared.menubar(section='tables')}

## Use double hashes for a mako template comment
## Main body
<div class="container-fluid">
    <div class="card">
        <h2 class="card-heading simple">Table Ingestion</h2>
        <div class="card-body">
            % if pageargs['loginFailed']:
                <div class="alert alert-error">
                    <strong>LOGIN FAILED!</strong> ${datetime.now().replace(microsecond=0)}
                </div>
            % endif
            <form method='post' action=''>
                ${ csrf_token(request) | n,unicode }
                <label for='selDB' style="display: inline;"> Database: </label>
                <select name='selDB' id='selDB' style="display: inline;">
                    <option value="mysql">MySQL</option>
                    <option value="postgres">PostgreSQL</option>
                </select>
                <label for='txtUsername'> Username:
                    <input type="text" name="txtUsername" id="txtUsername" value="root"/>
                </label> 
                <label for='txtPassword'> Password:
                    <input type="password" name="txtPassword" id="txtPassword" value="cloudera"/>
                </label> 
                <input type='submit' name='loginSubmit' id='loginSubmit' value='login' />
            </form>
        </div>
    </div>
</div>

%if not is_embeddable:
${commonfooter(None, messages) | n,unicode}
%endif
