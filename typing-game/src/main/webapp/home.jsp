<%@ page import="java.sql.*, com.typinggame.util.DBConnection" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page session="true" %>
<%
    if (session.getAttribute("username") == null)
    {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Home</title>
    <style>
        body
        {
            font-family: Arial;
            margin: 20px;
        }

        table
        {
            border-collapse: collapse;
            width: 100%;
            margin-top: 20px;
        }

        th, td
        {
            border: 1px solid black;
            padding: 6px;
            text-align: left;
        }

        th
        {
            background-color: #f0f0f0;
        }

        a
        {
            margin-right: 10px;
            text-decoration: none;
            color: blue;
        }
    </style>
</head>
<body>
    <h2>Welcome, <%= session.getAttribute("username") %></h2>
    <a href="game.jsp">Start Typing Test</a>
    <a href="logout.jsp">Logout</a>

    <h3>Top 20 Typing Scores</h3>
    <table>
        <tr>
            <th>Rank</th>
            <th>Username</th>
            <th>Quote</th>
            <th>WPM</th>
            <th>Accuracy (%)</th>
            <th>Time (s)</th>
            <th>Played At</th>
        </tr>
        <%
            try (Connection conn = DBConnection.get_connection();
                 PreparedStatement ps = conn.prepareStatement(
                     "SELECT s.*, u.username, q.quote " +
                     "FROM scores s " +
                     "JOIN users u ON s.user_id = u.id " +
                     "JOIN quotes q ON s.quote_id = q.id " +
                     "ORDER BY s.wpm DESC, s.accuracy DESC " +
                     "LIMIT 20"
                 );
                 ResultSet rs = ps.executeQuery())
            {
                int rank = 1;
                while (rs.next())
                {
        %>
        <tr>
            <td><%= rank++ %></td>
            <td><%= rs.getString("username") %></td>
            <td><%= rs.getString("quote") %></td>
            <td><%= rs.getDouble("wpm") %></td>
            <td><%= rs.getDouble("accuracy") %></td>
            <td><%= rs.getDouble("time_taken") %></td>
            <td><%= rs.getTimestamp("played_at") %></td>
        </tr>
        <%
                }
            }
            catch (Exception e)
            {
                e.printStackTrace();
            }
        %>
    </table>
</body>
</html>
