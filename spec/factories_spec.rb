# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FactoryBot do
  it 'has valid factories' do
    described_class.lint
  end
end
