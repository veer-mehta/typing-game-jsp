<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Typing Game</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        textarea { width: 100%; height: 120px; font-size: 16px; }
        #quote { font-size: 18px; margin-bottom: 10px; }
        #movie { color: gray; font-style: italic; margin-bottom: 15px; }
        #result { margin-top: 15px; font-weight: bold; }
    </style>
    <script>
        let quote_text = "";
        let start_time = null;
        let timer_running = false;
        let typed_chars = 0;
        let correct_chars = 0;
        let timer_interval;
        
        async function fetch_quote()
        {
            try
            {
                const res = await fetch("QuoteServlet");
                const data = await res.json();

                if (data.error)
                {
                    document.getElementById("quote").innerText = "Error fetching quote.";
                    document.getElementById("movie").innerText = "";
                    return;
                }

                document.getElementById("quote").innerText = data.quote;
                document.getElementById("movie").innerText = "- " + data.movie + "  (" + data.year + ")";
                quote_text = data.quote.trim();

                start_typing();
            }
            catch (e)
            {
                console.error(e);
                document.getElementById("quote").innerText = "Server error.";
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

        function on_type()
        {
            let input = document.getElementById("user_input").value;
            let result = document.getElementById("result");

            if (!timer_running && input.length > 0)
            {
                start_time = new Date();
                timer_running = true;
                timer_interval = setInterval(update_stats, 100);
            }

            update_stats();

            if (input === quote_text)
            {
                clearInterval(timer_interval);
                document.getElementById("user_input").disabled = true;
            }
        }

        function update_stats()
        {
            let input = document.getElementById("user_input").value;
            let result = document.getElementById("result");

            let typed_chars = input.length;
            let correct_chars = 0;

            for (let i = 0; i < input.length; i++)
            {
                if (input[i] === quote_text[i])
                {
                    correct_chars++;
                }
            }

            let end_time = new Date();
            let time_taken = (end_time - start_time) / 1000;

            if (typed_chars === 0 || time_taken === 0)
            {
                result.innerHTML = 
                    "WPM: 0<br>" +
                    "Accuracy: 0%<br>" +
                    "Time: 0s";
                return;
            }

            let minutes = time_taken / 60;
            let wpm = ((correct_chars / 5) / minutes).toFixed(2);
            let accuracy = ((correct_chars / typed_chars) * 100).toFixed(2);

            result.innerHTML = 
                "WPM: " + wpm + "<br>" +
                "Accuracy: " + accuracy + "%<br>" +
                "Time: " + time_taken.toFixed(1) + "s";
        }

    </script>
</head>
<body onload="fetch_quote()">
    <h2>Typing Game</h2>
    <div id="quote"></div>
    <div id="movie"></div>

    <textarea id="user_input" oninput="on_type()"></textarea><br>
    <button onclick="fetch_quote()">Start New</button>

    <div id="result"></div>
</body>
</html>
