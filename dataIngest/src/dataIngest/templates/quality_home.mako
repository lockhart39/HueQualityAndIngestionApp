<%!from desktop.views import commonheader, commonfooter %>
<%namespace name="shared" file="shared_components.mako" />

%if not is_embeddable:
    ${commonheader("dataIngest", "dataIngest", user, request) | n,unicode}
%endif

${shared.menubar(section='hive')}

## Use double hashes for a mako template comment
## Main body
## Data Quality Templates made by Okama Gamesphere
<div class="container-fluid">
    <div class="card">
        <h2 class="card-heading simple">Quality</h2>
        <div class="card-body">
        <form method="post" style="text-align:center;">
            ${ csrf_token(request) | n,unicode }
            <p>Idk what to do from here. Honestly I was hoping I wouldn't get this far today considering it is Monday and we really don't have much to do.</p>

            </form>
              <style type="text/css">
                .createDBArea {border-style: solid solid none solid; width:60%; padding:10px;}
                .createArea {border-style:solid solid none solid; width:60%; padding:10px;}
                .createQueryArea {border-style:solid solid solid solid; width:60%; padding:10px;}
                .myLinkClass:hover {border-style:solid; text-align:left;}
                .myLinkClass {background-color:none;}
                .myLinkClass {color:black; margin:0;}
                .myLinkClass {font-weight:800; padding:0 15px; text-decoration:none;}
                .fontEdits {color: black; font-weight:800; text-align:center;}
                .resultHead {font-weight:800; position:absolute; top:100px; right:200px;}
                .resultsOutput {background-color: #FFFDF7; margin:50px 0; position:absolute; top:100px; right:0px; left: 1400px; height:50%;}
              </style>
            
            <div>
            </div>
        </div>
    </div>
</div>
%if not is_embeddable:
    ${commonfooter(None, messages) | n,unicode}
%endif%
