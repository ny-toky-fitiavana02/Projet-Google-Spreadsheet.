#!/usr/bin/env ruby

#Programme pour lancer scrapper.rb
require 'bundler'
require_relative 'lib/scrapper'

Bundler.require
$:.unshift File.expand_path("./lib", __FILE__)

db = Scrapper.new('https://www.annuaire-des-mairies.com/val-d-oise.html')
db.save_as_JSON
db.save_as_spreadsheet
db.save_as_csv
