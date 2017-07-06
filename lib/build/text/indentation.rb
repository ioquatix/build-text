# Copyright, 2013, by Samuel G. D. Williams. <http://www.codeotaku.com>
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

module Build
	module Text
		class Indentation
			TAB = "\t".freeze
			
			def initialize(prefix, level, indent)
				@prefix = prefix
				@level = level
				@indent = indent
			end

			def freeze
				indentation
				
				@prefix.freeze
				@level.freeze
				@indent.freeze
				
				super
			end

			def indentation
				@indentation ||= @prefix + (@indent * @level)
			end

			def + other
				indentation + other
			end

			def << text
				text.gsub(/^/){|m| m + indentation}
			end

			def by(depth)
				Indentation.new(@prefix, @level + depth, @indent)
			end
			
			def with_prefix(prefix)
				Indentation.new(prefix, @level, @indent)
			end
			
			def self.none
				self.new('', 0, TAB)
			end
		end
	end
end