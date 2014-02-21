rubocop_files = %w{
  **/*.rb
  **/*.rake
  Guardfile
  Gemfile
  **/Capfile
  Rakefile
}
guard :rubocop, all_on_start: true, cli: ['-D'].concat(rubocop_files) do
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
