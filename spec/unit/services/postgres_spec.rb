require 'services/postgres'
require 'spec_helper'

describe Services::Postgres do
  let(:application) { double(name: 'Foo Bar App') }
  let(:data) { {} }
  let(:container) { double(:container) }

  subject { described_class.new(application: application, data: data) }


  before do
    allow(Docker::Container).to receive(:create).and_return(container)
    allow(container).to receive(:start)
    allow(container).to receive(:exec)
  end

  specify { subject.start }

  describe 'creating the container' do
    it 'defaults to the latest postgres' do
      expect(Docker::Container).to receive(:create)
        .with('Image' => 'postgres:latest')
        .and_return(container)
      subject.start
    end

    context 'when a version is set' do
      let(:data) { { 'version' => '9.4.1' } }

      it 'uses the correct postgres version' do
        expect(Docker::Container).to receive(:create)
          .with('Image' => 'postgres:9.4.1')
          .and_return(container)
        subject.start
      end
    end
  end

  describe 'starting the container' do
    it 'starts the container' do
      expect(container).to receive(:start)
      subject.start
    end
  end

  describe 'creating the database' do
    let(:standard_response) { [["CREATE DATABASE\n"], [], 0] }

    let(:create_database_cmd) do
      [
        'psql',
        '-U',
        'postgres', '-c', 'CREATE DATABASE foo_bar_app_test;',
      ]
    end

    it 'creates a database with a default name' do
      expect(container).to receive(:exec)
        .with(create_database_cmd)
        .and_return(standard_response)
      subject.start
    end

    context 'when the database name is set' do
      let(:data) { { 'database_name' => 'awesome_test' } }

      it 'creates a database with the set name' do
        expect(container).to receive(:exec)
          .with([
            'psql',
            '-U',
            'postgres', '-c', 'CREATE DATABASE awesome_test;'
          ]).and_return(standard_response)
        subject.start
      end
    end

    context 'error creating database' do
      let(:wait_command) { ["bash", "-c", "while [ ! -S /var/run/postgresql/.s.PGSQL.5432 ]; do echo '.'; sleep 0.1; done"] }
      let(:startup_error) { [[], ["psql: FATAL:  the database system is starting up\n"], 2] }
      let(:exists_error) { [[], ["ERROR:  database \"foo_bar_app_test\" already exists\n"], 1] }

      context 'when there is a startup error' do
        it 'retries until the database is created' do
          expect(container).to receive(:exec).with(wait_command)
          expect(container).to receive(:exec).with(create_database_cmd).exactly(3).times.and_return(startup_error, startup_error, standard_response)
          subject.start
        end
      end

      context 'when the database allready exists' do
        it 'does not retry futher' do
          expect(container).to receive(:exec).with(wait_command)
          expect(container).to receive(:exec).with(create_database_cmd).exactly(2).times.and_return(startup_error, exists_error)
          subject.start
        end
      end
    end
  end
end
