# frozen_string_literal: true

FactoryBot.define do
  factory :kitten, class: 'KittensStore::Models::Kitten' do
    name { FFaker::Animal.name }
    price { rand(100..599) }
  end
end
