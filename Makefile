.PHONY: commit

commit:
	git add .
	git commit -m "$(MSG)"
	git push origin master