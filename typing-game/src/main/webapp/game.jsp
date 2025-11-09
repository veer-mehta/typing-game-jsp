<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Typing Game</title>
<style>
    body
    {
        font-family: Arial, sans-serif;
        margin: 20px;
    }
    #quote_display
    {
        font-size: 18px;
        margin-bottom: 10px;
    }
    #quote_display span.correct { color: green; }
    #quote_display span.wrong { color: red; }
    #movie
    {
        font-style: italic;
        margin-bottom: 10px;
    }
    textarea
    {
        width: 100%;
        height: 80px;
        font-size: 16px;
    }
    #result
    {
        margin-top: 10px;
        font-weight: bold;
    }
    button
    {
        margin-top: 5px;
        padding: 5px 10px;
        font-size: 14px;
    }
</style>

</head>
<body onload="fetch_quote()">
    <h2>Typing Game</h2>

    <div id="quote_display"></div>
    <div id="movie"></div>

    <textarea id="user_input" oninput="on_type()" placeholder="Start typing here..."></textarea><br>
    <button onclick="fetch_quote()">New Quote</button>
    <button onclick="window.location.href='home.jsp'">View Leaderboard</button>

    <div id="result"></div>

    <script>
        let quote_text = "";
        let quote_id = null;
        let start_time = null;
        let timer_running = false;
        let typed_chars = 0;
        let correct_chars = 0;

        async function fetch_quote()
        {
            try
            {
                const res = await fetch("QuoteServlet");
                const data = await res.json();

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
                console.log("HI");
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
            input.disabled = false;
            input.focus();
        }

        async function on_type()
        {
            const input = document.getElementById("user_input").value;
            const spans = document.querySelectorAll("#quote_display span");

            if (!timer_running && input.length > 0)
            {
                start_time = new Date();
                timer_running = true;
            }

            typed_chars = input.length;
            correct_chars = 0;

            for (let i = 0; i < spans.length; i++)
            {
                const char = input[i];
                if (char == null)
                    spans[i].className = "";
                else if (char === quote_text[i])
                {
                    spans[i].className = "correct";
                    correct_chars++;
                }
                else
                    spans[i].className = "wrong";
            }

            if (input === quote_text)
            {
                const end_time = new Date();
                const time_taken = (end_time - start_time) / 1000;
                const minutes = time_taken / 60;
                const wpm = ((correct_chars / 5) / minutes).toFixed(2);
                const accuracy = ((correct_chars / typed_chars) * 100).toFixed(2);

                document.getElementById("result").innerText =
                    "WPM: " + wpm + " | Accuracy: " + accuracy + "% | Time: " + time_taken.toFixed(1) + "s";

                document.getElementById("user_input").disabled = true;

                await save_score(wpm, accuracy, time_taken);
            }
        }
    </script>
</body>
</html>
