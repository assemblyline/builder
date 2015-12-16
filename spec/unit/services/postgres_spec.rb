require 'spec_helper'
require 'services/postgres'

describe Services::Postgres do
  let(:application) { double(name: 'Foo Bar App') }
  let(:data) { {} }
  let(:container) { double(:container) }

  subject { described_class.new(application: application, data: data) }

  before do
    allow(Docker::Container).to receive(:create).and_return(container)
    allow(container).to receive(:start)
    allow(container).to receive(:exec)
    allow(Docker::Image).to receive(:get)
  end

  describe 'pulling the image' do
    it 'does not pull the image if it is found' do
      expect(Docker::Image).to_not receive(:create)
      subject.start
    end

    it 'pulls the image if it is not found' do
      allow(Docker::Image).to receive(:get).and_raise(Docker::Error::NotFoundError)
      expect(Docker::Image).to receive(:create).with('fromImage' => 'postgres:latest')
      subject.start
    end
  end

  describe 'creating the container' do
    it 'defaults to the latest postgres' do
      expect(Docker::Image).to receive(:get).with('postgres:latest')
      expect(Docker::Container).to receive(:create)
        .with('Image' => 'postgres:latest', 'Cmd' => nil, 'Env' => [])
        .and_return(container)
      subject.start
    end

    context 'when a version is set' do
      let(:data) { { 'version' => '9.4.1' } }

      it 'uses the correct postgres version' do
        expect(Docker::Image).to receive(:get).with('postgres:9.4.1')
        expect(Docker::Container).to receive(:create)
          .with('Image' => 'postgres:9.4.1', 'Cmd' => nil, 'Env' => [])
          .and_return(container)
        subject.start
      end
    end
  end

  describe 'starting the service' do
    it 'starts the container' do
      expect(container).to receive(:start)
      subject.start
    end
  end

  describe 'stopping the service' do
    it 'deletes the container' do
      allow(Features).to receive(:kill?).and_return(true)
      subject.start
      expect(container).to receive(:delete).with(force: true)
      subject.stop
    end
  end

  describe 'creating the database' do
    let(:standard_response) { [["CREATE DATABASE\n"], [], 0] }

    let(:create_database_cmd) do
      [
        'psql',
        '-U',
        'postgres', '-c', 'CREATE DATABASE foo_bar_app_test;'
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
      let(:startup_error) { [[], ["psql: FATAL:  the database system is starting up\n"], 2] }
      let(:exists_error) { [[], ["ERROR:  database \"foo_bar_app_test\" already exists\n"], 1] }

      context 'when there is a startup error' do
        it 'retries until the database is created' do
          expect(container).to receive(:exec).with(create_database_cmd).exactly(3).times
            .and_return(startup_error, startup_error, standard_response)
          subject.start
        end
      end

      context 'when the database allready exists' do
        it 'does not retry futher' do
          expect(container).to receive(:exec).with(create_database_cmd).exactly(2).times
            .and_return(startup_error, exists_error)
          subject.start
        end
      end
    end
  end

  describe 'env' do
    before do
      allow(container).to receive(:json).and_return(
        'NetworkSettings' => { 'IPAddress' => '123.456.123.123' },
      )
    end

    it 'returns the correct postgres url' do
      subject.start
      expect(subject.env).to eq(
        'DATABASE_URL' => 'postgres://postgres@123.456.123.123/foo_bar_app_test',
      )
    end
  end
end
