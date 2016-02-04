require "spec_helper"
require "builder/component/templates"

describe Builder::Component::Templates do
  let(:path) { "spec/fixtures/components/simple_component" }
  subject { described_class.new(path: path, versions: versions) }

  def template(path, output)
    Builder::Component::Template.new(path: path, output: output)
  end

  describe "#for" do
    let(:versions) { [version, double(tag: "0.0.2", template: nil), double(tag: "0.3.0", template: nil)] }
    let(:templates) { subject.for(version) }

    context "there is a version specific template" do
      let(:version) { double(tag: "0.0.1", template: nil) }

      it "uses the version specific template" do
        expect(templates).to include template(
          "#{path}/templates/0.0.1/Dockerfile.erb", "#{path}/Dockerfile"
        )

        expect(templates).to_not include template(
          "#{path}/templates/Dockerfile.erb", "#{path}/Dockerfile"
        )
      end
    end

    context "there is a version specifc folder but no file" do
      let(:version) { double(tag: "0.0.1", template: nil) }

      it "uses the generic template" do
        expect(templates).to include template(
          "#{path}/templates/config.yml.erb", "#{path}/config.yml"
        )
      end
    end

    context "the is a template only in the version folder" do
      context "in that version" do
        let(:version) { double(tag: "0.0.1", template: nil) }

        it "the template is included" do
          expect(templates).to include template(
            "#{path}/templates/0.0.1/ONE.erb", "#{path}/ONE"
          )
        end
      end

      context "in another version" do
        let(:versions) { [version, double(tag: "0.0.1", template: nil), double(tag: "0.0.3", template: nil)] }
        let(:version) { double(tag: "0.0.2", template: nil) }

        it "the template is excluded" do
          expect(templates).to_not include template(
            "#{path}/templates/ONE.erb", "#{path}/ONE"
          )
        end
      end
    end

    context "there is not a version specific template" do
      let(:versions) { [version, double(tag: "0.0.1", template: nil), double(tag: "0.0.3", template: "super-awesome")] }
      let(:version) { double(tag: "0.0.2", template: nil) }

      it "uses the generic template" do
        expect(templates).to include template(
          "#{path}/templates/Dockerfile.erb", "#{path}/Dockerfile"
        )

        expect(templates).to include template(
          "#{path}/templates/config.yml.erb", "#{path}/config.yml"
        )
        expect(templates).to_not include template(
          "#{path}/templates/0.0.1/Dockerfile.erb", "#{path}/Dockerfile"
        )
      end
    end

    context "with a named template" do
      let(:versions) { [double(tag: "0.0.1", template: nil), double(tag: "0.0.2", template: nil), version] }
      let(:version) { double(tag: "0.0.3", template: "super-awesome") }

      it "uses the named template" do
        expect(templates).to include template(
          "#{path}/templates/super-awesome/Dockerfile.erb", "#{path}/Dockerfile"
        )

        expect(templates).to_not include template(
          "#{path}/templates/Dockerfile.erb", "#{path}/Dockerfile"
        )

        expect(templates).to_not include template(
          "#{path}/templates/0.0.1/Dockerfile.erb", "#{path}/Dockerfile"
        )
      end

      context "and a version template" do
        let(:version) { double(tag: "0.0.1", template: "super-awesome") }

        it "uses the version template" do
          expect(templates).to include template(
            "#{path}/templates/0.0.1/Dockerfile.erb", "#{path}/Dockerfile"
          )

          expect(templates).to_not include template(
            "#{path}/templates/Dockerfile.erb", "#{path}/Dockerfile"
          )

          expect(templates).to_not include template(
            "#{path}/templates/super-awesome/Dockerfile.erb", "#{path}/Dockerfile"
          )
        end
      end
    end
  end
end
