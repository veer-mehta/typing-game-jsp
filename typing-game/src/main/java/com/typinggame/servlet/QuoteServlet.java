package com.typinggame.servlet;

import com.typinggame.util.DBConnection;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import org.json.JSONObject;

@WebServlet("/TextServlet")
public class QuoteServlet extends HttpServlet
{
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
    {
        response.setContentType("application/json");
        JSONObject json = new JSONObject();

        try (Connection conn = DBConnection.get_connection();
             PreparedStatement ps = conn.prepareStatement(
                     "SELECT quote, movie, type, year FROM quotes ORDER BY RANDOM() LIMIT 1"))
        {
            ResultSet rs = ps.executeQuery();
            if (rs.next())
            {
                json.put("quote", rs.getString("quote"));
                json.put("movie", rs.getString("movie"));
                json.put("type", rs.getString("type"));
                json.put("year", rs.getInt("year"));
            }
        }
        catch (Exception e)
        {
            e.printStackTrace();
            json.put("error", "Database fetch failed");
        }

        PrintWriter out = response.getWriter();
        out.print(json.toString());
        out.flush();
    }
}
