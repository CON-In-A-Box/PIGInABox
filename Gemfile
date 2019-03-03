# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

gem 'sinatra'
gem 'sinatra-contrib'
gem 'sinatra-param', require: 'sinatra/param'

gem 'authorizenet'
gem 'dotenv', require: 'dotenv/load'
gem 'slim'

group :development, :test do
  gem 'rack-test'
  gem 'rspec'
end
