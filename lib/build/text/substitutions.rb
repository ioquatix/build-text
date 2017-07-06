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

require_relative 'indentation'

module Build
	module Text
		class Substitutions
			def initialize(ordered = [])
				@ordered = ordered
			end
			
			def freeze
				@ordered.freeze
				
				super
			end
			
			def []= keyword, value
				if Array === value
					open, close = *value.each_slice(value.length / 2)
					@ordered << NestedSubstitution.new(keyword, open, close)
				else
					@ordered << SymbolicSubstitution.new('$' + keyword, value.to_s)
				end
			end

			def << substitution
				@ordered << substition
			end

			def + other
				Substitutions.new(@ordered + other.ordered)
			end

			attr :ordered

			def call(text)
				apply(text)
			end

			def apply(text)
				return text unless @ordered.count > 0
				
				grouped = [[@ordered.first]]
				
				@ordered.drop(1).each do |substitution|
					if grouped.last[0].class == substitution.class
						grouped.last << substitution
					else
						grouped << [substitution]
					end
				end
				
				grouped.each do |group|
					text = group.first.class.apply(text, group)
				end
				
				return text
			end
			
			class SymbolicSubstitution
				def initialize(keyword, value)
					@keyword = keyword
					@value = value
				end

				attr :keyword
				attr :value
				
				def freeze
					@keyword.freeze
					@value.freeze
					
					super
				end

				def apply(text)
					text.gsub(@keyword, @value)
				end

				def self.apply(text, group)
					substitutions = Hash[group.collect{|substitution| [substitution.keyword, substitution.value]}]

					pattern = Regexp.new(substitutions.keys.map{|key| Regexp.escape(key)}.join('|'))

					text.gsub(pattern) {|key| substitutions[key]}
				end
			end

			class NestedSubstitution
				def initialize(keyword, open, close, indent = "\t")
					@keyword = keyword

					@open = open
					@close = close

					@indent = indent
				end

				def freeze
					@keyword.freeze
					@open.freeze
					@close.freeze
					@indent.freeze
					
					super
				end

				def line_pattern(prefix = '')
					tag_pattern = Regexp.escape('<' + prefix + @keyword + '>')
					
					# Line matching pattern:
					Regexp.new('^(.*?)' + tag_pattern + '(.*)$', Regexp::MULTILINE | Regexp::EXTENDED)
				end

				def write_open(prefix, postfix, output, indentation)
					depth = @open.size
					indentation = indentation.with_prefix(prefix)

					#output.write(prefix)
					(0...depth).each do |i|
						chunk = @open[i]
						chunk.chomp! if i == depth-1
						
						output.write(indentation.by(i) << chunk)
					end
					output.write(postfix)
				end

				def write_close(prefix, postfix, output, indentation)
					depth = @close.size
					indentation = indentation.with_prefix(prefix)

					#output.write(prefix)
					(0...depth).reverse_each do |i|
						chunk = @close[-1 - i]
						chunk.chomp! if i == 0
						
						output.write(indentation.by(i) << chunk)
					end
					output.write(postfix)
				end

				def apply(text, level = 0)
					open_pattern = line_pattern
					close_pattern = line_pattern('/')

					lines = text.each_line
					output = StringIO.new

					indent = lambda do |level, indentation|
						while line = lines.next rescue nil
							if line =~ open_pattern
								write_open($1, $2, output, indentation)

								indent[level + @open.count, indentation.by(@open.count)]

								write_close($1, $2, output, indentation)
							elsif line =~ close_pattern
								break
							else
								output.write(indentation + line)
							end
						end
					end

					indent[0, Indentation.none]

					return output.string
				end

				def self.apply(text, group)
					group.each do |substitution|
						text = substitution.apply(text)
					end
					
					return text
				end
			end
		end
	end
end