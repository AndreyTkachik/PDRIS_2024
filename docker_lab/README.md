Запсукается при помощи docker-compose up -d

Загружал в registry используя следующие комманды:
```
docker build -t tkachikaa/lab3_app .
docker tag tkachikaa/lab3_app:latest tkachikaa/lab3_pdris
docker push tkachikaa/lab3_pdris:latest
```