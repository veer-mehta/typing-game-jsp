<%@ page import="java.sql.*, java.util.*, com.typinggame.util.DBConnection" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page session="true" %>
<%
    if (session.getAttribute("username") == null)
    {
        response.sendRedirect("login.jsp");
        return;
    }
    String username = session.getAttribute("username").toString();
%>

<!DOCTYPE html>
<html>
<head>
    <title>Typing Game</title>
    <link rel="stylesheet" type="text/css" href="game.css">
</head>
<body onload="fetch_quote()">

    <div class="navbar">
        <div class="navbar-left">
            <h2>Welcome, <%= username %></h2>
        </div>
        <div>Total Runs: <strong id="totalRuns">--</strong></div>
        <div>Avg WPM: <strong id="avgWpm">--</strong></div>
        <div>Top WPM: <strong id="topWpm">--</strong></div>
        <div>Avg Accuracy: <strong id="avgAcc">--</strong>%</div>
        <div class="navbar-right">
        	<a href="home.jsp">Leaderboard</a>
            <a href="logout.jsp">Logout</a>
        </div>
    </div>
	<br>
    <div id="quote_display"></div>
    <div id="movie"></div>
    <br>

    <textarea id="user_input" oninput="on_type()" placeholder="Start typing here..."></textarea>
    <div id="result" style="margin-top:10px;"></div>
    
    <div>
    
	<label for="quote_type" style="color:#fff;">Text Length:</label>
    <select id="quote_type" onchange="fetch_quote()">
        <option value="short">Short</option>
        <option value="medium" selected>Medium</option>
        <option value="long">Long</option>
    </select>
    <a href="game.jsp">New Quote</a>
    </div>

<script>
    let quote_text = "";
    let quote_id = null;
    let start_time = null;
    let timer_running = false;
    let typed_chars = 0;
    let correct_chars = 0;
    let total_errors = 0;

    async function loadUserStats() {
        try {
            const res = await fetch("<%= request.getContextPath() %>/UserStatsServlet");
            const data = await res.json();
            if (data.error) return;

            document.getElementById("totalRuns").textContent = data.totalRuns || 0;
            document.getElementById("avgWpm").textContent = (data.avgWpm || 0).toFixed(2);
            document.getElementById("topWpm").textContent = (data.topWpm || 0).toFixed(2);
            document.getElementById("avgAcc").textContent = (data.avgAcc || 0).toFixed(2);
        } catch (e) {
            console.error("Failed to load user stats:", e);
        }
    }

    async function fetch_quote()
    {
        const quote_type = document.getElementById("quote_type").value;
        try
        {
            const res = await fetch("QuoteServlet?type=" + encodeURIComponent(quote_type));
            const data = await res.json();

            if (data.error)
            {
                document.getElementById("quote_display").innerText = "Error: " + data.error;
                return;
            }

            quote_text = data.quote.trim();
            quote_id = data.id;
            render_quote(quote_text);

            document.getElementById("movie").innerText =
                "- " + data.movie + " (" + data.year + ")";
            start_typing();
        }
        catch (e)
        {
            console.error(e);
            document.getElementById("quote_display").innerText = "Server error.";
        }
    }

    async function save_score(wpm, accuracy, time_taken)
    {
        try
        {
            const params = new URLSearchParams();
            params.append("quote_id", quote_id);
            params.append("wpm", wpm);
            params.append("accuracy", accuracy);
            params.append("time_taken", time_taken);

            await fetch("ScoreServlet", {
                method: "POST",
                headers: { "Content-Type": "application/x-www-form-urlencoded" },
                body: params.toString()
            });
        }
        catch (e)
        {
            console.error("Score not saved:", e);
        }
    }

    function render_quote(text)
    {
        const container = document.getElementById("quote_display");
        container.innerHTML = "";
        for (let c of text)
        {
            const span = document.createElement("span");
            span.innerText = c;
            container.appendChild(span);
        }
    }

    function start_typing()
    {
        const input = document.getElementById("user_input");
        const result = document.getElementById("result");
        input.value = "";
        result.innerText = "";
        start_time = null;
        timer_running = false;
        typed_chars = 0;
        correct_chars = 0;
        total_errors = 0;
        input.disabled = false;
        input.focus();
    }

    async function on_type()
    {
        const input_val = document.getElementById("user_input").value;
        const spans = document.querySelectorAll("#quote_display span");

        if (!timer_running && input_val.length > 0)
        {
            start_time = new Date();
            timer_running = true;
        }

        typed_chars = input_val.length;
        correct_chars = 0;

        for (let i = 0; i < spans.length; i++)
        {
            const char = input_val[i];
            if (char == null)
            {
                spans[i].className = "";
            }
            else if (char === quote_text[i])
            {
                spans[i].className = "correct";
                correct_chars++;
            }
            else
            {
                spans[i].className = "wrong";
                if (i >= total_errors) total_errors++;
            }
        }

        let accuracy = 0;
        if (typed_chars > 0)
            accuracy = ((typed_chars - total_errors) / typed_chars) * 100;

        let time_taken = 0;
        let wpm = 0;

        if (timer_running)
        {
            const current_time = new Date();
            time_taken = (current_time - start_time) / 1000;
            const minutes = time_taken / 60;
            wpm = minutes > 0 ? ((correct_chars / 5) / minutes) : 0;
        }

        document.getElementById("result").innerText =
            "WPM: " + wpm.toFixed(2) +
            " | Accuracy: " + accuracy.toFixed(2) + "%" +
            " | Time: " + time_taken.toFixed(1) + "s";

        if (input_val === quote_text)
        {
            document.getElementById("user_input").disabled = true;
            await save_score(wpm.toFixed(2), accuracy.toFixed(2), time_taken);
        }
    }

    document.addEventListener("DOMContentLoaded", loadUserStats);
</script>
</body>
</html>
