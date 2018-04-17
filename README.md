# Rack Domain Filter

## Prerequisites

- Ruby 2.1+

## Installation

Put this into `Gemfile`:

    gem 'rack-domain-filter'

Then run `bundle`.

## Builder API

See Yarddoc for more information.

## Usage

Suppose you have `Company` model. In Rails, you can do
like this:

    Rack::SubdomainCompany.configure do |config|
      config.filter_for /(.+).local.dev/ do |slug|
        Thread.current[:company] = Company.find_by!(slug)
      end

      config.filter_for /(.+).peentar.id/ do |slug|
        Thread.current[:company] = Company.find_by!(slug)
      end

      config.filter_for /tenant-onpremise.ourclients.com/ do
        Thread.current[:company] = Company.find_by!(slug: 'tenant-onpremise.ourclients.com')
      end

      config.catch ActiveRecord::NotFound do
        [404, {}, "Not Found"]
      end

      config.no_match do
        [404, {}, "No slug found"]
      end

      config.after_request do
        Thread.current[:company] = nil
      end
    end

    config.middleware.use Rack::SubdomainCompany

In your controller, you can get your current company with
this syntax:

    class ApplicationController < ActionController::Base
      def current_company
        Thread.current[:company]
      end
    end

    def ApplicationHelper
      def current_company
        Thread.current[:company]
      end
    end
