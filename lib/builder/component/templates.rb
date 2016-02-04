require "builder/component/template"

class Builder
  class Component

    class Templates
      def initialize(path:, versions:)
        self.path = path
        self.versions = versions
      end

      def for(version)
        templates = grouped_templates.map do |base_file, candidates|
          template_for(candidates, version.tag) || template_for(candidates, version.template) || base_file
        end
        templates = templates.select do |path|
          File.exist? path
        end
        templates.map { |t| Template.new(path: t, output: template_path(t)) }
      end

      protected

      attr_accessor :path, :versions

      private

      def template_path(template_path)
        tp = template_path.dup
        tp.slice!("/templates")
        strip_version(tp.split(".erb").first)
      end

      def template_for(candidates, tag)
        candidates.detect do |t|
          t.split("/templates/").last.split("/").first == tag
        end
      end

      def grouped_templates
        Dir[path + "/templates/**/**.erb"].group_by do |template|
          strip_version(template)
        end
      end

      def strip_version(template)
        t = template.dup
        versions.each do |v|
          t.slice!("/" + v.tag)
          t.slice!("/" + v.template) if v.template
        end
        t
      end
    end
  end
end
