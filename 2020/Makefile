.PHONY: test rvm
DATENAME=$(shell date +"p%d.rb")
DATEBRANCH=$(shell date +"2020_p%d")

test: rvm
	bundle exec rspec -fd spec/*_spec.rb

rvm:
	bash --login -c "rvm use 2.6"

new:
	cp template.rb ${DATENAME}
	chmod a+x ${DATENAME}
	git checkout -b ${DATEBRANCH}
	git add ${DATENAME}
	git commit -m "${DATEBRANCH} - empty file"

merge: test
	./merge_branch.sh
