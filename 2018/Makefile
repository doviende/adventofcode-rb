.PHONY: test rvm

test: rvm
	bundle exec rspec -fd spec/*_spec.rb

rvm:
	bash --login -c "rvm use 2.6"
