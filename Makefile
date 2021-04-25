.PHONY: lint hooks

lint:
	swiftlint

hooks:
	rm -rf "$(CURDIR)/.git/hooks" && \
	ln -s "$(CURDIR)/Hooks" "$(CURDIR)/.git/hooks"
