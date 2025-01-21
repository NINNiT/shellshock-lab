#!/bin/bash

echo "Content-type: text/html"
echo ""

# Simulate form handling, vulnerable to Shellshock
echo "<html><body>"
echo "<h1>Thank you for your submission $QUERY_STRING</h1>"
echo "</body></html>"
