<?php
echo "<h1>PHP Test Page</h1>";
echo "<p>Current time: " . date('Y-m-d H:i:s') . "</p>";

// サーバー情報の表示
echo "<h2>Server Information:</h2>";
echo "<ul>";
echo "<li>PHP Version: " . phpversion() . "</li>";
echo "<li>Server Software: " . $_SERVER['SERVER_SOFTWARE'] . "</li>";
echo "<li>Server Name: " . $_SERVER['SERVER_NAME'] . "</li>";
echo "</ul>";
