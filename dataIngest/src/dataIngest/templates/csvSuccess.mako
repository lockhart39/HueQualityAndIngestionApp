<%!from desktop.views import commonheader, commonfooter %>
<%namespace name="shared" file="shared_components.mako" />

${commonheader("dataIngest", "dataIngest", user, request) | n,unicode}

${shared.menubar(section='csv')}

## Use double hashes for a mako template comment
## Main body
<div class="container-fluid">
    <div class="card">
        <h2 class="card-heading simple"> CSV File Upload Success! </h2>
            % if dbexists == 'Yes':
                % if texists == 'Yes':
                    CSV uploaded to ${db} in ${table} in Hive.
                % else:
                    ${table} created with columns: <br>
                    <pre>${colInfo}</pre> <br>
                    created in ${db} and CSV was uploaded to Hive.
                % endif
            % else:
                ${db} and ${table} with columns: <br>
                    <pre>${colInfo}</pre><br>
                was created and CSV was loaded into Hive.
            % endif
            <br><br>
            Database: ${db}<br>
            Table: ${table}<br>
            Delimiter: ${delimiter}<br><br><br>
            ## ColumnNums: ${columnNums}
            <form action="/dataIngest/csv/">
                <input class="btn btn-primary" type="submit" value="Upload Another CSV">
            </form><br>
    </div>
</div>

${commonfooter(None, messages) | n,unicode}