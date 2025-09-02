
require 'asciidoctor'
require 'asciidoctor/extensions'
require 'gruff'
require 'securerandom'

Asciidoctor::Extensions.register do
  block ChartBlockProcessor, :chart
end

class ChartMetadata
  attr_accessor :type, :title, :xFields, :yFields, :yNames, :data

  def initialize()
    @type = "line"
    @xFields = []
    @yFields = []
    @yNames = []
    @data = []
  end
end

class ChartBlockProcessor < Asciidoctor::Extensions::BlockProcessor
  use_dsl

  named :chart
  on_context :listing
  parse_content_as :raw

  def process(parent, reader, attrs)

    image_gen_dir = parent.document.attr('imagesoutdir', '.')
    FileUtils.mkdir_p(image_gen_dir) unless Dir.exist?(image_gen_dir)

    # Auxiliary information specific to the document comes from the block options
    target_image = attrs[:target] || SecureRandom.uuid + '.png'
    img_attrs = {
      "alt" => attrs["caption"],
      "title" => attrs["caption"],
      "width" => attrs["width"] || "75%",
      "target" => image_gen_dir + '/' + target_image
    }

    # The chart definition comes from inside the block
    parsedContent = parse_content reader

    image = generate_chart parent, parsedContent

    image.write(image_gen_dir + "/" + target_image)
    create_image_block parent, img_attrs
  end

  def generate_chart(parent, metadata)
    case metadata.type
    when "line"
      return generate_line_chart parent, metadata
    when "bar"
      return generate_bar_chart parent, metadata
    else
      raise "Unsupported chart type #{metadata.type}"
    end
  end

  def generate_line_chart(parent, metadata)
    g = Gruff::Line.new

    g.title = metadata.title
    g.theme = build_theme parent
    g.labels = metadata.data.map { |r| r[metadata.xFields[0]] }
    series = get_series_data metadata

    series.each do |y|
      g.data y[:name], y[:values]
    end
    return g
  end

  def generate_bar_chart(parent, metadata)
    g = Gruff::Bar.new

    g.title = metadata.title
    g.theme = build_theme parent
    g.labels = metadata.data.map { |r| r[metadata.xFields[0]] }
    series = get_series_data metadata

    series.each do |y|
      g.data y[:name], y[:values]
    end
    return g
  end

  def parse_content(reader)
    metadata = ChartMetadata.new
    in_data_mode = false
    first_row = true
    header = []
    reader.lines.each do |line|
      if in_data_mode
        row_data = line.strip.split(",").map(&:strip)
        if first_row
          header = row_data.clone
          first_row = false
        else
          metadata.data << header.zip(row_data).to_h
        end
      else
        setting = line.strip.split(":")
        case setting[0]
        when "data"
          in_data_mode = true
        when "type"
          metadata.type = setting[1].strip
        when "title"
          metadata.title = setting[1].strip
        when "x-fields"
          metadata.xFields = setting[1].strip
        when "y-fields"
          metadata.yFields = setting[1].strip.split(',').map(&:strip)
        else
          raise "Unknown chart setting #{setting[0]}"
        end
      end
    end
    return metadata
  end

  def build_theme(parent)
    colors = parent.document.attr("theme-chart-colors",nil)
    return {
      width: 2200,
      background_colors: nil
    }
  end

  def get_series_data(metadata)
    series = []
    metadata.yFields.each do |name|
      series << {
        name: name,
        values: metadata.data.map { |r| r[name].to_f }
      }
    end
    return series
  end
end
