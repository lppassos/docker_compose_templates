
require 'asciidoctor'
require 'asciidoctor/extensions'
require 'gruff'
require 'securerandom'

Asciidoctor::Extensions.register do
  block ChartBlockProcessor, :chart
end

# Large chart image width to ensure when scaling in the pdf it works well
CHART_SCALABLE_WIDTH = 2200

# All the information we need for drawing the chart, extracted from the
# contents of the block
class ChartMetadata
  attr_accessor :type, :title, :xFields, :yFields, :yNames, :data

  def initialize()
    @type = "line"
    @xFields = []
    @yFields = []
    @yNames = []
    @data = []
  end

  # Loads the definition from the block reader. The data shows up after the
  # "data:" line in a csv format. The csv starts with a header line specifying
  # the names of the columns in the data set
  #
  # @param reader the reader passed to the BlockProcessor
  def parse_content(reader)
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
          @data << header.zip(row_data).to_h
        end
      else
        key, value = line.strip.split(":").map(&:strip)
        case key
        when "data"
          in_data_mode = true
        when "type"
          @type = value
        when "title"
          @title = value
        when "x-fields"
          @xFields = value
        when "y-fields"
          @yFields = value.split(',').map(&:strip)
        else
          raise "Unknown chart setting #{key}"
        end
      end
    end
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
    parsedContent = ChartMetadata.new
    parsedContent.parse_content reader

    image = generate_chart parent, parsedContent

    image.write(image_gen_dir + "/" + target_image)
    create_image_block parent, img_attrs
  end

  def generate_chart(parent, metadata)
    case metadata.type
    when "line"
      g = generate_line_chart parent, metadata
    when "bar"
      g = generate_bar_chart parent, metadata
    else
      raise "Unsupported chart type #{metadata.type}"
    end

    # set common variables of the chart
    g.title = metadata.title
    g.theme = build_theme parent
    return g
  end

  def generate_line_chart(parent, metadata)
    g = Gruff::Line.new

    g.labels = metadata.data.map { |r| r[metadata.xFields[0]] }
    series = get_series_data metadata

    series.each do |y|
      g.data y[:name], y[:values]
    end
    return g
  end

  def generate_bar_chart(parent, metadata)
    g = Gruff::Bar.new

    g.labels = metadata.data.map { |r| r[metadata.xFields[0]] }
    series = get_series_data metadata

    series.each do |y|
      g.data y[:name], y[:values]
    end
    return g
  end

  # Generate the theme for use in the chart loading it from the theme to use
  # in the document
  #
  # @param document the document currently being generated
  # @return the Gruff theme
  def build_theme(parent)
    colors = parent.document.attr("theme-chart-colors",nil)
    return {
      colors: [ "limegreen", "blue", "purple" ],
      width: CHART_SCALABLE_WIDTH,
      background_colors: nil
    }
  end


  # Builds the series information to send to a chart
  # 
  # @param metadata [ChartMetadata]
  #     The information of the chart after parsing the block
  # @return The series information
  def get_series_data(metadata)
    series = []
    metadata.yFields.each_with_index do |name,index|
      series << {
        name: name,
        values: metadata.data.map { |r| r[name].to_f }
      }
    end
    return series
  end
end
