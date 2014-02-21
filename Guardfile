require 'chromatic'
require 'command'

rubocop_files = %w{
  **/*.rb
  **/*.rake
  Guardfile
  Gemfile
  **/Capfile
  Rakefile
}
guard :rubocop, all_on_start: true, cli: %w{-D}.concat(rubocop_files) do
  watch(/.+\.rb$/)
  watch(/.+\.rake$/)
  watch(/.*Guardfile$/)
  watch(/.*Gemfile$/)
  watch(/.*Capfile$/)
  watch(/.*Rakefile$/)
  watch(/(?:.+\/)?\.rubocop\.yml$/) { |m| File.dirname(m[0]) }
end

guard :bundler do
  watch('Gemfile')
  # Uncomment next line if your Gemfile contains the `gemspec' command.
  # watch(/^.+\.gemspec/)
end

guard :shell do
  watch(/.+\.rake$/) do |m|
    puts "#{m[0]} changed:".bold.cyan
    command = Command.run 'rake -T'
    if command.success?
      puts %Q|* 'rake -T' (still) works! Good!|.green
    else
      puts %Q|* 'rake -T' does not work anymore! =>|.red
      puts command.stderr.red
    end
  end
end
