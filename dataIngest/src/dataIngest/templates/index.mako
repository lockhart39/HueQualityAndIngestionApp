<%!from desktop.views import commonheader, commonfooter %>
<%namespace name="shared" file="shared_components.mako" />

%if not is_embeddable:
${commonheader("dataIngest", "dataIngest", user, request) | n,unicode}
%endif

${shared.menubar(section='home')}

## Use double hashes for a mako template comment
## Main body
<div class="container-fluid">
  <div class="card">
    <h2 class="card-heading simple">Welcome to the dataIngest app!</h2>
    <div class="card-body">
      <p>Select the appropriate tab above to begin ingestion</p>
    </div>
  </div>
  <div id="raptor" style="visibility: hidden">
    <marquee behavior="scroll" direction="left">
        <img src="/static/dataIngest/art/raptor.jpeg" alt="HE DIED FOR YOUR SINS" style="width: 200px; height: 252px; display: block;margin: 0 auto;"><br><br>
        <strong style="font-size: 30px; color: red;">HE DIED FOR YOUR SINS!</strong>
    </marquee>
  </div>
</div>

<script src="/static/dataIngest/js//konami.js"></script>

%if not is_embeddable:
${commonfooter(request, messages) | n,unicode}
%endif%
