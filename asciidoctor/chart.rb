
require 'asciidoctor'
require 'asciidoctor/extensions'
require 'gruff'

Asciidoctor::Extensions.register do
  block ChartBlockProcessor, :chart
end

class ChartBlockProcessor < Asciidoctor::Extensions::BlockProcessor
  use_dsl

  named :chart
  on_context :listing
  parse_content_as :raw

  def process(parent, reader, attrs)

    image_gen_dir = parent.document.attr('imagesoutdir', '.')
    FileUtils.mkdir_p(image_gen_dir) unless Dir.exist?(image_gen_dir)

    target_image = attrs[:target] || 'default.png'
    format = attrs[:format] || 'line'
    img_attrs = {
      "alt" => attrs[:caption],
      "width" => "300",
      "target" => image_gen_dir + '/' + target_image
    }
    image = generate_line_chart("example", {0 => "a", 1 => "b", 2 => "c"}, [
      {:name => "series1", :values => [5, 10, 12]},
      {:name => "series2", :values => [8, 5, 6]},
    ])
    image.write(image_gen_dir + "/" + target_image)
    create_image_block parent, img_attrs
  end

  def generate_line_chart(title, x, series)
    g = Gruff::Line.new

    g.title = title
    g.labels = x
    g.theme = {
      background_colors: nil
    }
    series.each do |y|
      g.data y[:name], y[:values]
    end
    return g
  end
end
