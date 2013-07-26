require 'openehr/rm'
require 'openehr/am'
require 'openehr/parser'
require 'generators/openehr'

module OpenEHR
  module Rails
    module Generators
      class ScaffoldGenerator < ArchetypedBase
        source_root File.expand_path("../templates", __FILE__)

        def create_root_folder
          empty_directory File.join("app/views", controller_file_path)
        end

        def generate_index
          generate_view  "index.html.erb"
        end

        def generate_show
          generate_view  "show.html.erb"
        end

        def generate_edit
          generate_view "edit.html.erb"
        end

        def generate_form
          generate_view "_form.html.erb"
        end

        def append_locale_route
          unless File.exist? 'config/routes.rb'
            template 'routes.rb', File.join("config", 'routes.rb')
          end
          inject_into_file 'config/routes.rb', <<LOCALE, :after => "Application.routes.draw do\n"
  scope "/:locale" do
    resources :#{controller_file_path}
  end
LOCALE
        end
        def append_set_locale
          unless File.exist? 'app/controllers/application_controller.rb'
            template 'application_controller.rb', File.join("app/controllers", 'application_controller.rb')
          end
          inject_into_file 'app/controllers/application_controller.rb', <<LOCALE, :after => "class ApplicationController < ActionController::Base\n"
  before_action :set_locale

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end
LOCALE
        end

        protected

        def generate_view(filename)
          template filename, File.join("app/views", controller_file_path, filename)
        end

        def show_format(cobj)
          h = case cobj.rm_type_name
              when 'ELEMENT'
                show_element cobj
              when 'INTERVAL_EVENT'
                show_element cobj
              when 'OBSERVATION'
                show_component cobj
              when 'ACTION'
                show_component cobj
              else
                show_component cobj
              end
          h
        end

        def show_component(cobj)
          html = "<strong>#{cobj.rm_type_name.humanize} t(\".#{cobj.node_id}\")</strong>:<br/>\n"
          unless cobj.respond_to? :attributes
            html += "#{cobj.rm_type_name}\n"
          else
            html += cobj.attributes.inject("") do |form, attr|
              form += "<p><strong>#{attr.rm_attribute_name.humanize}:</strong>"
              form += attr.children.inject("") {|h,c| h += show_format c}
              form += "</p>\n"
            end
          end
          return html
        end

        def show_element(cobj)
          html = "<strong><%= t(\"#.{cobj.node_id}\") %></strong>: "
#          value = cobj.select {|attr| attr.rm_attribute_name == 'value'}
          html += "<%= #{model_name}.#{cobj.node_id} %><br/>\n"
        end
      end
    end
  end
end
