#!/bin/sh

echo 'installing viewpoint dependencies'
gem install logging nokogiri rubyntlm httpclient
echo 'installing viewpoint-1.0.0...'
gem install viewpoint-1.0.0.beta.2.gem --local
echo 'installig mongodb driver for ruby'
gem install mongo bson_ext
