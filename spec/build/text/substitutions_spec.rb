# Copyright, 2012, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

RSpec.describe Build::Text::Substitutions do
	it "should substitute symbolic expressions" do
		input = <<-EOF
		$FOO $BAR
		EOF
	
		output = <<-EOF
		baz bar
		EOF
	
		substitutions = Build::Text::Substitutions.new
		substitutions['FOO'] = 'baz'
		substitutions['BAR'] = 'bar'
	
		expect(substitutions.apply(input)).to be == output
	end
	
	it "should indent nestest expressions" do
		input = <<-EOF
		<FOO>
		$BAR
		</FOO>
		EOF
	
		output = <<-EOF
		enter
		{
			foo
				Hello World
			bar
		}
		exit
		EOF
	
		substitutions = Build::Text::Substitutions.new
		substitutions['FOO'] = ["enter\n{\n", "foo\n", "bar\n", "}\nexit\n"]
		substitutions['BAR'] = 'Hello World'
	
		expect(substitutions.apply(input)).to be == output
	end
end
