require File.join(File.dirname(__FILE__), 'spec_helper')

describe Regex::Tester do

  it 'should allow me to choose python as the language of choice' do
    tester = Regex::Tester.new('python')
    tester.language.should == 'python'
  end

  it 'should allow me to choose ruby as the language of choose' do
    tester = Regex::Tester.new('ruby')
    tester.language.should == 'ruby'
  end

  it 'should error if an unsupported language is choosen' do
    lambda {Regex::Tester.new('vb')}.should \
      raise_error(Regex::Errors::UnsupportedLanguage)
  end

  describe 'Required public methods' do
    before do
      @tester = Regex::Tester.new('ruby')
    end

    it 'should have match method' do
      @tester.should respond_to(:match)
    end

    it 'should have match_all method' do
      @tester.should respond_to(:match_all)
    end

    it 'should have replace method' do
      @tester.should respond_to(:replace)
    end
  end # Required public methods.

  describe 'Ruby' do
    before do
      @tester = Regex::Tester.new('ruby')
    end

    describe 'match method' do
      it_should_behave_like 'match method'

      it 'should handle regex case option' do
        match = @tester.match('[a-z\s]+', 'SHOULD IGNORE CASE', 'i')
        match.should have_key(:matches)
        match[:matches][0].should == 'SHOULD IGNORE CASE'
      end
    end # Match method

    describe 'match_all method' do
      it_should_behave_like 'match_all method'

      it 'should handle regex case option' do
        match = @tester.match_all('[a-z\s]+', 'SHOULD IGNORE CASE', 'i')
        match.should have_key(:matches)
        match[:matches][0].should == 'SHOULD IGNORE CASE'
      end
    end

    describe 'replace method' do
      it_should_behave_like 'replace method'
    end
  end # Ruby

  describe 'Python' do
    before do
      @tester = Regex::Tester.new('python')
    end

    describe 'match method' do
      it_should_behave_like 'match method'
    end

    describe 'match_all method' do
      it_should_behave_like 'match_all method'
    end

    describe 'replace method' do
      it_should_behave_like 'replace method'
    end
  end # Python

end # Regex::Tester