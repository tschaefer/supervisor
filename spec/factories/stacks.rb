FactoryBot.define do
  factory :stack do
    name             { Faker::App.name }
    strategy         { 'polling' }
    git_repository   { Faker::Internet.url }
    git_reference    { 'refs/heads/main' }
    compose_file     { 'lib/stack/traefik/docker-compose.yml' }
    polling_interval { 5.minutes.to_i }

    trait :with_credentials do
      git_username { Faker::Internet.username }
      git_token    { Faker::Internet.password }
    end
  end
end
