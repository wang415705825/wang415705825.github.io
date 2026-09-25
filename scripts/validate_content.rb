# frozen_string_literal: true

require "date"
require "yaml"

ROOT = File.expand_path("..", __dir__)
ALLOWED_RESEARCH_TYPES = %w[publication working-paper work-in-progress].freeze
MINIMUM_RESEARCH_TOTAL = 32

errors = []

def front_matter(path)
  source = File.read(path, encoding: "UTF-8")
  match = source.match(/\A---\s*\n(.*?)\n---\s*\n/m)
  raise "missing YAML front matter" unless match

  YAML.safe_load(match[1], permitted_classes: [Date, Time], aliases: true) || {}
end

def present?(value)
  !value.nil? && !(value.respond_to?(:empty?) && value.empty?)
end

def check_link(url, context, errors)
  unless present?(url)
    errors << "#{context}: URL is missing"
    return
  end

  value = url.to_s.strip
  errors << "#{context}: links must not use a placeholder #" if value == "#"
  return if value.start_with?("https://", "mailto:", "/")

  errors << "#{context}: link must use HTTPS or a root-relative path (#{value})"
end

def files_in(directory, extension = nil)
  absolute_directory = File.join(ROOT, directory)
  return [] unless Dir.exist?(absolute_directory)

  Dir.children(absolute_directory)
     .map { |name| File.join(absolute_directory, name) }
     .select { |path| File.file?(path) && (!extension || File.extname(path) == extension) }
     .sort
end

all_content_files = %w[_research _news _resources _data].flat_map { |directory| files_in(directory) }

all_content_files.each do |path|
  source = File.read(path, encoding: "UTF-8")
  errors << "#{path.delete_prefix(ROOT + "/")}: contains unfinished placeholder text" if source.match?(/to be added/i)
end

research_records = []
files_in("_research", ".md").each do |path|
  relative = path.delete_prefix(ROOT + "/")
  begin
    data = front_matter(path)
    research_records << [relative, data]
  rescue StandardError => e
    errors << "#{relative}: #{e.message}"
    next
  end

  %w[title slug permalink authors year type status topics featured summary].each do |field|
    errors << "#{relative}: missing #{field}" unless data.key?(field) && present?(data[field])
  end
  errors << "#{relative}: authors must be a non-empty list" unless data["authors"].is_a?(Array) && data["authors"].any?
  errors << "#{relative}: topics must be a non-empty list" unless data["topics"].is_a?(Array) && data["topics"].any?
  errors << "#{relative}: featured must be true or false" unless [true, false].include?(data["featured"])
  errors << "#{relative}: unsupported type #{data['type'].inspect}" unless ALLOWED_RESEARCH_TYPES.include?(data["type"])
  errors << "#{relative}: year must be a four-digit number" unless data["year"].to_s.match?(/\A\d{4}\z/)

  if present?(data["slug"]) && data["permalink"] != "/research/#{data['slug']}/"
    errors << "#{relative}: permalink must match /research/<slug>/"
  end

  Array(data["links"]).each_with_index do |link, index|
    errors << "#{relative}: link #{index + 1} needs a label" unless present?(link["label"])
    check_link(link["url"], "#{relative} link #{index + 1}", errors)
  end
end

research_records.group_by { |_path, data| data["slug"] }.each do |slug, records|
  errors << "duplicate research slug #{slug.inspect}" if present?(slug) && records.length > 1
end

counts = research_records.each_with_object(Hash.new(0)) { |(_path, data), tally| tally[data["type"]] += 1 }
errors << "research inventory has #{research_records.length} items, expected at least #{MINIMUM_RESEARCH_TOTAL}" if research_records.length < MINIMUM_RESEARCH_TOTAL

featured_count = research_records.count { |_path, data| data["featured"] == true }
errors << "featured research count is #{featured_count}, expected exactly 6" unless featured_count == 6

statement_path = File.join(ROOT, "_data", "research_statement.yml")
if File.file?(statement_path)
  begin
    statement = YAML.safe_load(File.read(statement_path, encoding: "UTF-8"), permitted_classes: [Date], aliases: true) || {}
    unless statement.is_a?(Hash)
      errors << "_data/research_statement.yml: expected a mapping"
    else
      errors << "_data/research_statement.yml: missing intro" unless present?(statement["intro"])

      themes = statement["themes"]
      if !themes.is_a?(Array)
        errors << "_data/research_statement.yml: themes must be a list"
      else
        errors << "_data/research_statement.yml: expected exactly 3 themes" unless themes.length == 3
        theme_numbers = themes.map { |theme| theme.is_a?(Hash) ? theme["number"].to_s : nil }
        errors << "_data/research_statement.yml: theme numbers must be 01, 02, 03 in order" unless theme_numbers == %w[01 02 03]

        selected_slugs = []
        themes.each_with_index do |theme, index|
          context = "_data/research_statement.yml theme #{index + 1}"
          unless theme.is_a?(Hash)
            errors << "#{context}: expected a mapping"
            next
          end

          %w[number title core_question paragraphs papers].each do |field|
            errors << "#{context}: missing #{field}" unless present?(theme[field])
          end
          unless theme["paragraphs"].is_a?(Array) && theme["paragraphs"].all? { |paragraph| present?(paragraph) }
            errors << "#{context}: paragraphs must be a non-empty list of text"
          end
          unless theme["papers"].is_a?(Array) && theme["papers"].all? { |slug| present?(slug) }
            errors << "#{context}: papers must be a non-empty list of slugs"
            next
          end
          selected_slugs.concat(theme["papers"])
        end

        errors << "_data/research_statement.yml: expected exactly 9 selected papers" unless selected_slugs.length == 9
        errors << "_data/research_statement.yml: selected paper slugs must be unique" unless selected_slugs.uniq.length == selected_slugs.length
        known_slugs = research_records.map { |_path, data| data["slug"] }
        (selected_slugs - known_slugs).each do |slug|
          errors << "_data/research_statement.yml: unknown selected paper slug #{slug.inspect}"
        end

        future_agenda = statement["future_agenda"]
        if !future_agenda.is_a?(Hash)
          errors << "_data/research_statement.yml: future_agenda must be a mapping"
        else
          %w[title text projects].each do |field|
            errors << "_data/research_statement.yml future_agenda: missing #{field}" unless present?(future_agenda[field])
          end
          projects = future_agenda["projects"]
          unless projects.is_a?(Array) && projects.length == 3 && projects.all? { |slug| present?(slug) }
            errors << "_data/research_statement.yml future_agenda: projects must contain exactly 3 slugs"
          else
            errors << "_data/research_statement.yml future_agenda: project slugs must be unique" unless projects.uniq.length == projects.length
            (projects - known_slugs).each do |slug|
              errors << "_data/research_statement.yml: unknown future project slug #{slug.inspect}"
            end
          end
        end
      end
    end
  rescue StandardError => e
    errors << "_data/research_statement.yml: #{e.message}"
  end
else
  errors << "_data/research_statement.yml: file is missing"
end

files_in("_news", ".md").each do |path|
  relative = path.delete_prefix(ROOT + "/")
  begin
    data = front_matter(path)
  rescue StandardError => e
    errors << "#{relative}: #{e.message}"
    next
  end
  %w[title date display_date summary source_label source_url].each do |field|
    errors << "#{relative}: missing #{field}" unless present?(data[field])
  end
  check_link(data["source_url"], "#{relative} source", errors)
end

resource_orders = []
files_in("_resources", ".md").each do |path|
  relative = path.delete_prefix(ROOT + "/")
  begin
    data = front_matter(path)
  rescue StandardError => e
    errors << "#{relative}: #{e.message}"
    next
  end
  %w[title category summary order].each do |field|
    errors << "#{relative}: missing #{field}" unless present?(data[field])
  end
  resource_orders << data["order"] if present?(data["order"])
  check_link(data["external_url"], "#{relative} external resource", errors) if present?(data["external_url"])
  body = File.read(path, encoding: "UTF-8").sub(/\A---\s*\n.*?\n---\s*\n/m, "").strip
  errors << "#{relative}: needs an external_url or page body" unless present?(data["external_url"]) || present?(body)
end
errors << "resource order values must be unique" unless resource_orders.uniq.length == resource_orders.length

profile_path = File.join(ROOT, "_data", "profile.yml")
if File.file?(profile_path)
  begin
    profile = YAML.safe_load(File.read(profile_path, encoding: "UTF-8"), permitted_classes: [Date], aliases: true) || {}
    %w[name preferred_name title institution email bio research_interests social].each do |field|
      errors << "_data/profile.yml: missing #{field}" unless present?(profile[field])
    end
    Array(profile["social"]).each_with_index do |social, index|
      errors << "_data/profile.yml: social link #{index + 1} needs a label" unless present?(social["label"])
      check_link(social["url"], "_data/profile.yml social link #{index + 1}", errors)
    end
    %w[institution_url college_url department_url].each do |url_key|
      check_link(profile[url_key], "_data/profile.yml #{url_key}", errors) if present?(profile[url_key])
    end
    errors << "_data/profile.yml: phone must not be published" if profile.keys.any? { |key| key.to_s.match?(/phone/i) }
    %w[portrait cv].each do |asset_key|
      next unless present?(profile[asset_key]) && profile[asset_key].start_with?("/")

      asset_path = File.join(ROOT, profile[asset_key].delete_prefix("/"))
      errors << "_data/profile.yml: #{asset_key} asset does not exist" unless File.file?(asset_path)
    end
  rescue StandardError => e
    errors << "_data/profile.yml: #{e.message}"
  end
else
  errors << "_data/profile.yml: file is missing"
end

data_specs = {
  "navigation.yml" => [%w[label url], %w[url]],
  "code.yml" => [%w[name description url], %w[url]],
  "experience.yml" => [%w[role institution location period], %w[institution_url]],
  "education.yml" => [%w[degree institution year], %w[institution_url]],
  "honors.yml" => [%w[date title organization], %w[url]],
  "service.yml" => [%w[role organization period], %w[url]]
}

data_specs.each do |filename, (required_fields, url_fields)|
  path = File.join(ROOT, "_data", filename)
  unless File.file?(path)
    errors << "_data/#{filename}: file is missing"
    next
  end

  begin
    records = YAML.safe_load(File.read(path, encoding: "UTF-8"), permitted_classes: [Date], aliases: true) || []
    unless records.is_a?(Array)
      errors << "_data/#{filename}: expected a list"
      next
    end

    records.each_with_index do |record, index|
      context = "_data/#{filename} item #{index + 1}"
      required_fields.each do |field|
        errors << "#{context}: missing #{field}" unless present?(record[field])
      end
      url_fields.each do |field|
        check_link(record[field], "#{context} #{field}", errors) if present?(record[field]) || required_fields.include?(field)
      end
    end
  rescue StandardError => e
    errors << "_data/#{filename}: #{e.message}"
  end
end

if errors.any?
  warn "Content validation failed:"
  errors.each { |error| warn "- #{error}" }
  exit 1
end

puts "Content validation passed: #{research_records.length} research items " \
     "(#{counts['publication']} publications, #{counts['working-paper']} working papers, " \
     "#{counts['work-in-progress']} works in progress), #{featured_count} featured."
