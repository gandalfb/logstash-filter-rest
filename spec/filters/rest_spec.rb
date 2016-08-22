require 'spec_helper'
require 'logstash/filters/rest'

describe LogStash::Filters::Rest do
  describe 'get json' do
    let(:userId) { 10 }
    let(:target) { 'rest' }
    let(:config) do
      <<-CONFIG
        filter {
          rest {
            request => {
              url => "http://jsonplaceholder.typicode.com/users/#{userId}"
            }
            json => true
          }
        }
      CONFIG
    end

    sample('message' => 'some text') do
      expect(subject).to include(target)
      expect(subject[target]).to include('id')
      expect(subject[target]['id']).to eq(userId)
      expect(subject[target]).to_not include('fallback')
    end
  end
  describe 'get json with target' do
    let(:userId) { 10 }
    let(:target) { 'testing' }
    let(:config) do
      <<-CONFIG
        filter {
          rest {
            request => {
              url => "http://jsonplaceholder.typicode.com/users/#{userId}"
            }
            json => true
            target => #{target}
          }
        }
      CONFIG
    end

    sample('message' => 'some text') do
      expect(subject).to include(target)
      expect(subject[target]).to include('id')
      expect(subject[target]['id']).to eq(userId)
      expect(subject[target]).to_not include('fallback')
    end
  end
  describe 'get json sprintf' do
    let(:target) { 'rest' }
    let(:config) do
      <<-CONFIG
        filter {
          rest {
            request => {
              url => 'http://jsonplaceholder.typicode.com/users/%{message}'
            }
            json => true
            sprintf => true
          }
        }
      CONFIG
    end

    sample('message' => '9') do
      expect(subject).to include(target)
      expect(subject[target]).to include('id')
      expect(subject[target]['id']).to eq(event[0]['message'].to_i)
      expect(subject[target]).to_not include('fallback')
    end
  end
  describe 'get json error 404' do
    let(:target) { 'rest' }
    let(:restfailure) { '_restfailure' }
    let(:config) do
      <<-CONFIG
        filter {
          rest {
            request => {
              url => 'http://httpstat.us/404'
            }
            json => true
          }
        }
      CONFIG
    end

    sample('message' => 'some text') do
      expect(subject).to_not include(target)
      expect(subject['tags']).to include(restfailure)
    end
  end
  describe 'get json error 404 with tag' do
    let(:target) { 'rest' }
    let(:restfailure) { '_chimichanga' }
    let(:config) do
      <<-CONFIG
        filter {
          rest {
            request => {
              url => 'http://httpstat.us/404'
            }
            json => true
            tag_on_rest_failure => #{restfailure}
          }
        }
      CONFIG
    end

    sample('message' => 'some text') do
      expect(subject).to_not include(target)
      expect(subject['tags']).to include(restfailure)
    end
  end
  describe 'get json with params' do
    let(:userId) { 10 }
    let(:target) { 'rest' }
    let(:config) do
      <<-CONFIG
        filter {
          rest {
            request => {
              url => 'https://jsonplaceholder.typicode.com/posts'
              params => {
                userId => #{userId}
              }
              headers => {
                'Content-Type' => 'application/json'
              }
            }
            json => true
          }
        }
      CONFIG
    end

    sample('message' => 'some text') do
      expect(subject).to include(target)
      expect(subject[target][0]).to include('userId')
      expect(subject[target][0]['userId']).to eq(userId)
      expect(subject[target]).to_not include('fallback')
    end
  end
  describe 'get json with params sprintf' do
    let(:target) { 'rest' }
    let(:config) do
      <<-CONFIG
        filter {
          rest {
            request => {
              url => 'https://jsonplaceholder.typicode.com/posts'
              params => {
                userId => '%{message}'
              }
              headers => {
                'Content-Type' => 'application/json'
              }
            }
            json => true
            sprintf => true
          }
        }
      CONFIG
    end

    sample('message' => '10') do
      expect(subject).to include(target)
      expect(subject[target][0]).to include('userId')
      expect(subject[target][0]['userId']).to eq(event[0]['message'].to_i)
      expect(subject[target]).to_not include('fallback')
    end
  end
  describe 'post json with params' do
    let(:userId) { 42 }
    let(:target) { 'rest' }
    let(:config) do
      <<-CONFIG
        filter {
          rest {
            request => {
              url => 'https://jsonplaceholder.typicode.com/posts'
              method => 'post'
              params => {
                title => 'foo'
                body => 'bar'
                userId => #{userId}
              }
              headers => {
                'Content-Type' => 'application/json'
              }
            }
            json => true
          }
        }
      CONFIG
    end

    sample('message' => 'some text') do
      expect(subject).to include(target)
      expect(subject[target]).to include('id')
      expect(subject[target]['userId']).to eq(userId)
      expect(subject[target]).to_not include('fallback')
    end
  end
  describe 'post json with params sprintf' do
    let(:target) { 'rest' }
    let(:config) do
      <<-CONFIG
        filter {
          rest {
            request => {
              url => 'https://jsonplaceholder.typicode.com/posts'
              method => 'post'
              params => {
                title => 'foo'
                body => 'bar'
                userId => '%{message}'
              }
              headers => {
                'Content-Type' => 'application/json'
              }
            }
            json => true
            sprintf => true
          }
        }
      CONFIG
    end

    sample('message' => '42') do
      expect(subject).to include(target)
      expect(subject[target]).to include('id')
      expect(subject[target]['userId']).to eq(event[0]['message'].to_i)
      expect(subject[target]).to_not include('fallback')
    end
  end
  describe 'get json fallback' do
    let(:userId) { 0 }
    let(:target) { 'rest' }
    let(:config) do
      <<-CONFIG
        filter {
          rest {
            request => {
              url => "http://jsonplaceholder.typicode.com/users/#{userId}"
            }
            json => true
            fallback => {
              'fallback1' => true
              'fallback2' => true
            }
          }
        }
      CONFIG
    end

    sample('message' => 'some text') do
      expect(subject).to include(target)
      expect(subject[target]).to include('fallback1')
      expect(subject[target]).to include('fallback2')
      expect(subject[target]).to_not include('id')
    end
  end
  describe 'get json fallback with empty target' do
    let(:userId) { 0 }
    let(:target) { 'rest' }
    let(:config) do
      <<-CONFIG
        filter {
          rest {
            request => {
              url => "http://jsonplaceholder.typicode.com/users/#{userId}"
            }
            json => true
            target => ''
            fallback => {
              'fallback1' => true
              'fallback2' => true
            }
          }
        }
      CONFIG
    end

    sample('message' => 'some text') do
      expect(subject).to_not include(target)
      expect(subject).to include('fallback1')
      expect(subject).to include('fallback2')
      expect(subject).to_not include('id')
    end
  end
  describe 'get json empty target' do
    let(:userId) { 1 }
    let(:target) { 'rest' }
    let(:config) do
      <<-CONFIG
        filter {
          rest {
            request => {
              url => "http://jsonplaceholder.typicode.com/users/#{userId}"
            }
            json => true
            target => ''
          }
        }
      CONFIG
    end

    sample('message' => 'some text') do
      expect(subject).to_not include(target)
      expect(subject).to include('id')
      expect(subject['id']).to eq(userId)
      expect(subject).to_not include('fallback')
    end
  end
end
