LOCALE=pt_BR
CURRENCY=BRL
TIMEZONE=America/Sao_Paulo
DB_HOST=localhost
DB_NAME=magento
DB_USER=magento
DB_PASS=magento
SITE_URL=http://127.0.0.1:8888
ADMIN_FIRST_NAME=Guto
ADMIN_LAST_NAME=Maia
ADMIN_EMAIL_ADDRESS=guto@guto.net
ADMIN_USERNAME=admin
ADMIN_PASSWORD=a123456
ENCRYPTION_KEY=secret

ifeq "" "$(shell which composer)"
COMPOSER_BIN=bin/composer.phar
else
COMPOSER_BIN = $(shell which composer)
endif

default: run

bin/.check:
	@mkdir -p bin && touch $@

bin/composer.phar: bin/.check
	@curl -sS https://getcomposer.org/installer | php -- --install-dir=bin

store/.check:
	@mkdir -p store && touch $@

store/install.php: store/.check ${COMPOSER_BIN}
	${COMPOSER_BIN} install -vv && touch $@

store/run.php: store/install.php run.php
	@cp run.php $@ && touch $@

# TODO session_save "db" \

store/.configured: store/install.php
	@cd store && php -f install.php -- \
		--skip_url_validation "yes" \
		--license_agreement_accepted "yes" \
		--locale "${LOCALE}" \
		--timezone "${TIMEZONE}" \
		--default_currency "${CURRENCY}" \
		--db_host "${DB_HOST}" \
		--db_name "${DB_NAME}" \
		--db_user "${DB_USER}" \
		--db_pass "${DB_PASS}" \
		--url "${SITE_URL}" \
		--use_rewrites "yes" \
		--use_secure "no" \
		--secure_base_url "" \
		--use_secure_admin "no" \
		--admin_firstname "${ADMIN_FIRST_NAME}" \
		--admin_lastname "${ADMIN_LAST_NAME}" \
		--admin_email "${ADMIN_EMAIL_ADDRESS}" \
		--admin_username "${ADMIN_USERNAME}" \
		--admin_password "${ADMIN_PASSWORD}" \
		--encryption_key "${ENCRYPTION_KEY}"
	touch $@

run: store/run.php store/.configured
	@cd store && php -S 127.0.0.1:8888 run.php

dist/.check:
	@mkdir -p dist && touch $@

dist: docker

clean:
	@rm -rf dist

purge: clean
	@rm -rf bin
	@rm -rf store
	@rm -rf vendor

.PHONY: docker run dist clean purge
