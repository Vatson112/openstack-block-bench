[Unit]
Description=Fio

[Service]
ExecStart=/bin/fio --server

[Install]
WantedBy=multi-user.target