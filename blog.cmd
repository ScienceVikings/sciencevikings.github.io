echo off
echo Spinning up the blog
docker-compose up -d blog
sleep 10

FOR /F "tokens=* USEBACKQ" %%F IN (`docker-compose ps -q blog`) DO (
SET id=%%F
)

explorer http://localhost:8100/

docker logs -f %id%
