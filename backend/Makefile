.PHONY: build
build:
	docker-compose run --rm web sh -c "python quizter/manage.py collectstatic"

.PHONY: deploy
deploy: build
	docker-compose -f docker-compose-deploy.yml run --rm gcloud sh -c "gcloud app deploy --project project1-316309"