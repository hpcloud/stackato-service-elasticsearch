
RSYNC_EXCLUDE=--exclude=/.git* --exclude=/Makefile --exclude=/.stackato-pkg --exclude=/debian

VM=$(VMNAME).local
dev-push:
	rsync -av ./ stackato@$(VM):/s/code/services/elasticsearch $(RSYNC_EXCLUDE)
