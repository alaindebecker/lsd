<%@ page import="java.sql.*" %>
<%@ page import="java.text.*" %>




<%  // Paramerters 
    int StragtegicFrameWork = 1; 
    int Utils = 14; 

    String now = dateFormat(new java.util.Date());
    String trans = request.getParameter("trans"); 
    String date  = request.getParameter("date");

    int limit = 12;
    if(request.getParameter("limit")!=null)
      limit = Integer.parseInt(request.getParameter("limit"));

    String mode = request.getParameter("mode");
      if( mode==null) mode = "Refresh";
%>




<%  // Data source
    Class.forName("net.sourceforge.jtds.jdbc.Driver");
    Statement db = DriverManager.getConnection("jdbc:jtds:sqlserver://SQL2012CLUSTER:1433/PentahoRepo", "pentaho", "Ba3VQcM1qoU6VmVc").createStatement();

    String source = "SELECT DISTINCT directory_name+'/'+transname   AS Transformation \n"
                  + "      , CONVERT(CHAR(19), replaydate, 120)     AS Date \n"
                  + "      , Status                                 AS Status \n"
                  + "      , CAST(logdate-replaydate as time(0))    AS Duration \n"
                  + "      , lines_output+lines_updated             AS Output \n"
                  + "      , errors                                 AS Errors \n"
                  + "   FROM log_transformation \n"
                  + "   JOIN r_transformation ON r_transformation.name=transname \n"
                  + "   JOIN r_directory ON r_directory.id_directory = r_transformation.id_directory \n"
                  + "  WHERE id_directory_parent="+StragtegicFrameWork+" \n"
                  + "     OR r_transformation.id_directory="+Utils+" \n"
                  + "   ORDER BY 1, 2 desc \n" ;
%>


<html>
    <head>
        <title>Data Control</title>
        <meta charset="utf-8">

    
    <style>
        * { font-family: Calibri,Segoe,Arial,sans-serif; }
        html { width: 100%; background: white; }
        body { width: 80%;  background: whitesmoke; margin: auto; padding: 1em; float: auto; ;}

        h1 span {float: right; }

        table { width: 100%;  border-collapse: collapse; }
        th, td { width: 10%; text-align: center; }
        th:nth-child(2), td:nth-child(2) { width: 25%;  }
        th:nth-last-child(1), td:nth-last-child(1) { text-align: right;  }
        th:nth-last-child(2),td:nth-last-child(2) { text-align: right;  }
        th:first-child, td:first-child { width: 35%; text-align: left;}

        textarea { width: 100%; height: 100%;}

        td:first-child { padding-left: 2em; }
        .dir { text-align: left; padding-left: 0 !important;} 
        .warning { color: red; font-weight: bold; }
        [onclick]:hover, [onclick]:hover * { background: grey; color: white; cursor: default; }
    </style></head>



    <body>
        <h1>Pentaho Data Load <span style="font-weight: normal"><%= now%></span></h1>

        <h2 style="display: flex;">
            <span style="flex-grow: 1;" onclick="refresh()" >Last loads</span>
            <select id="mode" onchange="refresh()">
                <option <% if(mode.equalsIgnoreCase("freeze"))  out.print("selected"); %> >Freeze</option>
                <option <% if(!mode.equalsIgnoreCase("freeze")) out.print("selected"); %> >Refresh</option>
            </select>
        </h2>



    <table><% // ETL runs
        ResultSet rs = db.executeQuery(source);
        int columnCount = rs.getMetaData().getColumnCount();

        out.println("<tr>");
        for(int i=1; i<=columnCount; i++)
            out.print("<th>"+rs.getMetaData().getColumnLabel(i)+"</th>");
        out.println("</tr>");

        String key = null;
        String dir = null;
        while(rs.next()){
            if(!rs.getString(1).equals(key)){
                int p = rs.getString(1).lastIndexOf("/");
                if(!rs.getString(1).substring(0,p).equals(dir))
                    out.println("<tr><td class='dir'>"+rs.getString(1).substring(0,p)+"</td><td></td></tr>");
                dir = rs.getString(1).substring(0,p);

                out.print("<tr onclick='refresh(getElementsByTagName(\"TD\")[0].innerHTML)'>");
                for(int i=1; i<=columnCount; i++){
                    out.print( "<td ");
                    if(i==2 && !lastNight(rs.getString(i)))
                        out.print( "class='warning'");
                    if(i==3 && !rs.getString(3).equals("end"))
                        out.print( "class='warning'");
                    if(i==5 && rs.getInt(5)==0)
                        out.print( "class='warning'");
                    if(i==5 && rs.getInt(6)>0)
                        out.print( "class='warning'");
                    out.print(">"+rs.getString(i).substring(p+1)+"</td>");
                    p = -1;
                    }
                out.println("</tr>");
            }
            key = rs.getString(1);
        }
    %></table>




    <% if(trans!=null) { // Run history
        %> <h2 style="display: flex;">
            <span style="flex-grow: 1;" onclick="refresh('<%= trans%>')">Previous runs of <%= trans %></span>
            <span style="float: right; ">
                Limit: <input type="Number" id="limit" onchange="refresh('<%= trans%>')" value="<%= limit%>">
            </span>
        </h2>

        <table><%
            rs = db.executeQuery(source);
            columnCount = rs.getMetaData().getColumnCount();

            out.println("<tr>");
            for(int i=1; i<=columnCount; i++)
                out.print("<th>"+rs.getMetaData().getColumnLabel(i)+"</th>");
            out.println("</tr>");

            int n = 0;
            while(rs.next() && n<limit){
                int p = rs.getString(1).lastIndexOf("/");
                String name = rs.getString(1).substring(p+1);

                if(name.equals(trans)){
                    out.print("<tr onclick='refresh(getElementsByTagName(\"TD\")[0].innerHTML, getElementsByTagName(\"TD\")[1].innerHTML)'>");
                    out.print( "<td class='dir'>"+name+"</td>" );
                    for(int i=2; i<=columnCount; i++)
                        out.print( "<td>"+rs.getString(i)+"</td>" );
                    out.println("</tr>");
                    n++;
                }
            }
        %></table>
    <% } %>


    <% if(date!=null) { // Log text
        %><h2>Loggin Details of <%= trans %> on <%= date %></h2>
            <textarea><%
                rs = db.executeQuery(
                             "SELECT log_field "
                            +"  FROM log_transformation "
                            +" WHERE transname like '%"+trans+"' "
                            +"   AND CONVERT(CHAR(19), replaydate, 120) = '"+date+"' ");
                while(rs.next())
                out.println(rs.getString(1));
        %></textarea>
    <% } 

    // Close connection, wait and reload
    db.getConnection().close();
    %>








    <script>
        function refresh(trans, date){
            var url = '<%= request.getRequestURL() %>';
            url += '?mode='+document.getElementById("mode").value;
            if(trans) {
                url += '&trans='+trans;
                if(date) 
                    url += '&date='+date;
                if(document.getElementById("limit"))
                    url += "&limit="+document.getElementById("limit").value;
            }
            window.location = url;
        }

        onload = function(){
            document.body.scrollTop = sessionStorage.getItem('kettleLogScroll');
            if(<%= mode.equals("Refresh") %>)
                setTimeout(function() { location=''}, 2*1000);
        }
        document.body.onscroll = function(){
            sessionStorage.setItem('kettleLogScroll', document.body.scrollTop);
        }

    <%!
        String dateFormat(java.util.Date d){
          return new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(d);
        }

        java.util.Date dateParse(String s){
            String format = "yyyy-MM-dd HH:mm:ss";
            if(s.length()<20)
                format = format.substring(0, s.length());
            try {
                return new SimpleDateFormat(format).parse(s);
            } catch(ParseException err){
                return null;
            }
        }

        boolean lastNight(String date){
            long time = new java.util.Date().getTime();
            Date now = new Date(time - time% (24*60*60*1000) -4*60*60*1000 );
            return dateParse(date).after(now);
        }
    %>




    </script></body>
</html>