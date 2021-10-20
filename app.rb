require 'roda'
require './models/meme'

class App < Roda
  plugin :render, escape: true, layout: './layout'
  plugin :sessions, secret: ENV.fetch('SESSION_SECRET'), cookie_options: { max_age: 86_400 * 30 }
  plugin :route_csrf
  plugin :forme_route_csrf
  plugin :slash_path_empty
  plugin :disallow_file_uploads
  plugin :precompile_templates
  plugin :path
  plugin :environments
  plugin :delegate
  plugin :enhanced_logger, filter: ->(path) { path.start_with?('/assets') }, trace_missed: true
  plugin :public

  plugin :assets, {
    css: %w[
      colors.css
      typography.css
      layout.css
      ui.css
      reset.css
      app.css
    ],
    js: %w[app.js],
    gzip: true
  }

  plugin :not_found do
    view '404'
  end

  plugin :default_headers,
    'Content-Type'              => 'text/html',
    'Strict-Transport-Security' => 'max-age=16070400;',
    'X-Content-Type-Options'    => 'nosniff',
    'X-Frame-Options'           => 'deny',
    'X-XSS-Protection'          => '1; mode=block'

  #plugin :content_security_policy do |csp|
  #  csp.default_src :none
  #  csp.style_src :self
  #  csp.script_src :self
  #  csp.connect_src :self
  #  csp.img_src :self
  #  csp.font_src :self
  #  csp.form_action :self
  #  csp.base_uri :none
  #  csp.frame_ancestors :none
  #  csp.block_all_mixed_content
  #end

  def development?
    self.class.development?
  end

  def production?
    self.class.production?
  end

  if development?
    plugin :exception_page
    plugin :error_handler do |e|
      next exception_page(e)
    end

    class RodaRequest
      def assets
        exception_page_assets
        super
      end
    end
  end

  compile_assets unless development?

  request_delegate :root, :on, :is, :get, :post, :redirect, :params, :halt, :hash_routes, :assets

  path :home, '/'
  path :meme do |meme|
    "/memes/#{meme.id}"
  end

  route do |r|
    assets if development?
    r.public
    check_csrf!

    @memes = Dir.entries("public").drop(2).sort.each_with_index.map do |url, id|
      m = Meme.new
      m.id = id + 1
      m.url = "/#{url}"
      m
    end

    root do
      view 'home'
    end

    is "memes", Integer do |id|
      @meme = @memes.select { |meme| meme.id == id }.first

      if @meme.nil?
        response.status = 404
        return
      end

      get do
        view 'meme'
      end
    end
  end
end
