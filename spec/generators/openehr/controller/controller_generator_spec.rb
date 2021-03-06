require 'spec_helper'
require 'generators/openehr/controller/controller_generator'
require 'generator_helper'

module Openehr
  module Generators
    describe ControllerGenerator do
      destination File.expand_path("../../../../../tmp", __FILE__)
      
      before { prepare_destination }
      
      before(:each) do
        prepare_destination
        run_generator [archetype]
      end
      
      subject { file('app/controllers/open_ehr_ehr_observation_blood_pressure_v1_controller.rb') }
      
      it { should exist }

      it { should contain /^class OpenEhrEhrObservationBloodPressureV1Controller < ApplicationController$/ }
    end
  end
end

