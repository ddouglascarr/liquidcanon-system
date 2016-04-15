#!/bin/bash

sudo -u www-data /bin/bash <<- EOF
/opt/moonbridge/moonbridge /opt/webmcp/bin/mcp.lua /opt/webmcp/ /opt/liquid_feedback_frontend/ main myconfig
EOF
