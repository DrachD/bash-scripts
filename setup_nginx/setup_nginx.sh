#!/bin/bash
PORT="81"
SERVER_NAME="mysite.com"
INDEX_PATH="/var/www/site/index.html"
CONF_PATH="/etc/nginx/sites-enabled/site.conf"
ROOT_DIR="/var/www/site"
CONF_DIR="/etc/nginx/sites-enabled"

#installing nginx
sudo apt update
sudo apt install -y nginx

sudo mkdir -p "$ROOT_DIR"
sudo mkdir -p "$CONF_DIR"

sudo tee "$INDEX_PATH" <<EOF
<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8">
	<title>Hello DevOps</title>
</head>
<body>
	<h1>Hello DevOps</h1>
</body>
</html>
EOF

sudo tee "$CONF_PATH" <<EOF
server {
	listen $PORT;
	listen [::]:$PORT;

	server_name $SERVER_NAME;
	root $ROOT_DIR;
	index index.html;

	location / {
		try_files \$uri \$uri/ =404;
	}
}
EOF

sudo nginx -t || { echo "Nginx config test failed"; exit 1; }
sudo service nginx restart
sudo curl --version || sudo apt install -y curl
sudo systemctl enable nginx

if ! grep -q "127.0.0.1 $SERVER_NAME" /etc/hosts; then
	echo "127.0.0.1 $SERVER_NAME" | sudo tee -a /etc/hosts
	echo "record added to /etc/hosts"
else
	echo "record is exists"
fi

if ! curl -sSf -max-time 5 "http://$SERVER_NAME:$PORT" > /dev/null; then
	echo "site $SERVER_NAME:$PORT is not responding or ruterned an error"
	exit 1
fi
