# encoding: UTF-8

require 'spec_helper'

describe 'running a build' do
  let(:commit)    { "3e0c65433b241ff2c59220f80bcdcd2ebb7e4b96" }
  let(:command)   { "rspec test_spec.rb" }
  let(:build)     { Buildbox::Build.new(:project_id => 1, :build_id => 1, :repository => FIXTURES_PATH.join("repo.git").to_s, :commit => commit, :config => { :script => command }) }
  let(:observer)  { double.as_null_object }
  let(:runner)    { Buildbox::Build::Runner.new(build, observer) }

  before do
    Buildbox.stub(:root_path).and_return(TEMP_PATH)
  end

  after do
    TEMP_PATH.rmtree if TEMP_PATH.exist?
  end

  context 'running a working build' do
    it "returns a successfull result" do
      result = runner.run.last

      result.should be_success
      result.output.should =~ /1 example, 0 failures/
    end
  end

  context 'running a working build with a semi colon in the command' do
    let(:command) { "rspec test_spec.rb;" }

    it "returns a successfull result" do
      result = runner.run.last
      p result

      result.should be_success
      result.output.should =~ /1 example, 0 failures/
    end
  end

  context 'running a failing build' do
    let(:commit) { "2d762cdfd781dc4077c9f27a18969efbd186363c" }

    it "returns a unsuccessfull result" do
      result = runner.run.last

      result.should_not be_success
      result.output.should =~ /1 example, 1 failure/
    end
  end

  context 'running a failing build that has commands after the one that failed' do
    let(:command) { [ "bash -c 'echo fail || exit 1'", "echo 'oh no you didnt!'" ] }

    it "returns a unsuccessfull result" do
      result = runner.run.last

      result.should_not be_success
      result.output.should =~ /1 example, 1 failure/
    end
  end

  context 'running a build with a broken command' do
    let(:command) { 'foobar' }

    it "returns a unsuccessfull result" do
      result = runner.run.last

      result.should_not be_success
      # ubuntu: sh: 1: foobar: not found
      # osx: sh: foobar: command not found
      result.output.should =~ /foobar.+not found/
    end
  end

  context 'running multiple builds in a row' do
    it "returns a successfull result when the build passes" do
      first_result  = runner.run.last
      second_result = runner.run.last

      first_result.should be_success
      first_result.output.should =~ /1 example, 0 failures/

      second_result.should be_success
      second_result.output.should =~ /1 example, 0 failures/
    end
  end

  context 'running a working build from a thread' do
    it "returns a successfull result" do
      result = nil
      thread = Thread.new do
        result = runner.run.last
      end
      thread.join

      result.should be_success
      result.output.should =~ /1 example, 0 failures/
    end
  end

  context 'running a failing build from a thread' do
    let(:commit) { "2d762cdfd781dc4077c9f27a18969efbd186363c" }

    it "returns a successfull result" do
      result = nil
      thread = Thread.new do
        result = runner.run.last
      end
      thread.join

      result.should_not be_success
      result.output.should =~ /1 example, 1 failure/
    end
  end
end
