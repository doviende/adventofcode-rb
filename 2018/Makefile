.PHONY: test rvm merge new

install: rvm
	bundle install --path ../bundle

test: rvm
	bundle exec rspec -fd spec/*_spec.rb

rvm:
	bash --login -c "rvm use 2.7.1"

merge: test
	../lib/merge_branch.sh

new: ../lib/template.rb ../lib/setup_new.sh
	../lib/setup_new.sh
