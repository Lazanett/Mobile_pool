FROM instrumentisto/flutter:3.32.5

RUN flutter doctor

WORKDIR /home/flutteruser/app

EXPOSE 8080

CMD ["flutter", "run", "-d", "web-server", "--web-hostname=0.0.0.0", "--web-port=8080"]
