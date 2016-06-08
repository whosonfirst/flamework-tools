setup:
	if test -z "$$DBNAME"; then echo "YOU FORGET TO SPECIFY DBNAME"; exit 1; fi
	if test -z "$$DBUSER"; then echo "YOU FORGET TO SPECIFY DBUSER"; exit 1; fi
	ubuntu/setup-ubuntu.sh
	ubuntu/setup-flamework.sh
	ubuntu/setup-certified.sh
	sudo ubuntu/setup-certified-ca.sh
	sudo ubuntu/setup-certified-certs.sh
	bin/configure_secrets.sh .
	ubuntu/setup-db.sh $(DBNAME) $(DBUSER)
