require "json"
require "erb"

module Chartkick
  module Helper

    def line_chart(data_source, options = {})
      chartkick_chart "LineChart", data_source, options
    end

    def pie_chart(data_source, options = {})
      chartkick_chart "PieChart", data_source, options
    end

    def column_chart(data_source, options = {})
      chartkick_chart "ColumnChart", data_source, options
    end

    def bar_chart(data_source, options = {})
      chartkick_chart "BarChart", data_source, options
    end

    def area_chart(data_source, options = {})
      chartkick_chart "AreaChart", data_source, options
    end

    def geo_chart(data_source, options = {})
      chartkick_chart "GeoChart", data_source, options
    end

    def gauge_chart(data_source, options = {})
      chartkick_chart "GaugeChart", data_source, options
    end

    def stock_chart(data_source, options = {})
      chartkick_chart "StockChart", data_source, options
    end

    private

    def chartkick_chart(klass, data_source, options, &block)
      @chartkick_chart_id ||= 0
      options = chartkick_deep_merge(Chartkick.options, options)
      element_id = options.delete(:id) || "chart-#{@chartkick_chart_id += 1}"
      height = options.delete(:height) || "300px"
      timeout_refresh = options.delete(:timeout_refresh)
      # content_for: nil must override default
      content_for = options.has_key?(:content_for) ? options.delete(:content_for) : Chartkick.content_for

      html = <<HTML
<div id="#{ERB::Util.html_escape(element_id)}" style="height: #{ERB::Util.html_escape(height)}; text-align: center; color: #999; line-height: #{ERB::Util.html_escape(height)}; font-size: 14px; font-family: 'Lucida Grande', 'Lucida Sans Unicode', Verdana, Arial, Helvetica, sans-serif;">
  Loading...
</div>
HTML
      js = <<JS
<script type="text/javascript">
  new Chartkick.#{klass}(#{element_id.to_json}, #{data_source.to_json}, #{options.to_json});
</script>
JS
      js_refresh = <<JS
<script type="text/javascript">
  window.setInterval(function() {
    new Chartkick.#{klass}(#{element_id.to_json}, #{data_source.to_json}, #{options.to_json});
  }, #{timeout_refresh});
</script>
JS
      if content_for
        content_for(content_for) { js.respond_to?(:html_safe) ? js.html_safe : js }
      else
        html += js
        html += js_refresh if timeout_refresh
      end

      html.respond_to?(:html_safe) ? html.html_safe : html
    end

    # https://github.com/rails/rails/blob/master/activesupport/lib/active_support/core_ext/hash/deep_merge.rb
    def chartkick_deep_merge(hash_a, hash_b)
      hash_a = hash_a.dup
      hash_b.each_pair do |k,v|
        tv = hash_a[k]
        hash_a[k] = tv.is_a?(Hash) && v.is_a?(Hash) ? tv.deep_merge(v) : v
      end
      hash_a
    end

  end
end
