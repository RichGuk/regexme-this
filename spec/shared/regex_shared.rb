shared_examples_for 'match method' do
  it 'should return a hash' do
    @tester.match('[a-z]+', 'aaTa').should be_an_instance_of(Hash)
  end

  it 'should return an array of matches' do
    match = @tester.match('[a-z]+', 'daTa')

    match[:matches].should be_an_instance_of(Array)
  end

  it 'should still return match array even if only one match is found' do
    match = @tester.match('[A-Z]', 'Data more fun')

    match.should have_key(:matches)
    match[:matches].should be_an_instance_of(Array)
  end

  it 'should handle basic regex' do
    match = @tester.match('(.+) - ([0-9]{2})(.+)', 'Some text - 02GO')

    match[:matches].should have_at_least(3).items
    match[:matches].should include 'Some text'
    match[:matches].should include '02'
    match[:matches].should include 'GO'
  end

  it 'should handle more complex regex' do
    match = @tester.match('([\w\s.]+)[\s\.\-]+[sS]?([0-9])[EexX]?([0-9]{2})',
    'Stargate Universe - S1E07.avi')

    match[:matches].should have_at_least(3).items
    match[:matches].should include 'Stargate Universe '
    match[:matches].should include '1'
    match[:matches].should include '07'
  end

  it 'should raise match exception if regex is empty' do
    lambda { match = @tester.match('', 'SHOULD NOT MATCH') }.should
      raise_error(Regex::Errors::MatchException)
  end
end

shared_examples_for 'match_all method' do
  it 'should return a hash' do
    @tester.match_all('[a-z]+', 'aaTa').should be_an_instance_of(Hash)
  end

  it 'should return an array of matches' do
    match = @tester.match_all('[a-z]+', 'DaTa')
    match.should have_key(:matches)
    match[:matches].should be_an_instance_of(Array)
  end

  it 'should still return match array even if only one match is found' do
    match = @tester.match_all('[A-Z]', 'data More fun')

    match[:matches].should be_an_instance_of(Array)
    match[:matches].should have(1).item
  end

  it 'should handle basic regex' do
    match = @tester.match_all('[a-z]{3,6}', 's should match this w0000t')

    match[:matches].should have(3).items
    match[:matches][0].should == 'should'
    match[:matches][1].should == 'match'
    match[:matches][2].should == 'this'
  end

  it 'should handle more complex regex' do
    match = @tester.match_all('[A-Z]{1,2}[0-9]{2}\s[0-9]{1}[A-Z]{2}',
    'should be able to match UK postcode DY23 6RZ, even in the middle')

    match[:matches].should have(1).item
    match[:matches][0].should == 'DY23 6RZ'
  end
end


shared_examples_for 'replace method' do
  it 'should return a hash' do
    search = @tester.replace('[aeiou]', 'Hello Everyone!!!', '-')
    search.should be_an_instance_of(Hash)
  end

  it 'should return replaced data' do
    search = @tester.replace('[aeiou]', 'Hello Everyone!!!', '-')
    search.should have_key(:replaced_data)
    search[:replaced_data].should == 'H-ll- Ev-ry-n-!!!'
  end

  it 'should provide replace variables for matched data' do
    search = @tester.replace('([aeiou])', 'hello', '<\1>')

    search[:replaced_data].should == 'h<e>ll<o>'
  end
end