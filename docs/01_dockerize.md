docker image build -t kittens-store .

psql --host db -U postgres_user -d kittens_store_dev
bundle exec rake db:create
RACK_ENV=test bundle exec rake db:create

docker login -u vbyno

To serve application:
```bash
RACK_ENV=development DATABASE_NAME=kittens_store_dev docker-compose up
```

To run the specs:
```bash
docker-compose run --rm app bundle
RACK_ENV=test DATABASE_NAME=kittens_store_test docker-compose run --rm app sh scripts/test.sh
```
