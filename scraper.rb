#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'open-uri'

require 'pry'
require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

class String
  def tidy
    self.gsub(/[[:space:]]+/, ' ').strip
  end
end

def noko_for(url)
  Nokogiri::HTML(open(url).read) 
end

def scrape_list(url)
  noko = noko_for(url)
  noko.css('table tr').drop(1).each do |tr|
    tds = tr.css('td')
    data = { 
      constituency: tds[0].text.tidy,
      name: tds[1].text.tidy,
      party: tds[2].text.tidy,
      term: '10',
      source: url,
    }
    next if data[:name].empty?
    ScraperWiki.save_sqlite([:name, :term], data)
  end
end

scrape_list('http://www.siec.gov.sb/index.php/journalist/127-2014-national-general-election-results')
