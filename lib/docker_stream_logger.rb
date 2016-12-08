require "json"
require "log"
require "ruby-progressbar"
require "colorize"

class DockerStreamLogger
  def initialize
    @layers = Layers.new
  end

  attr_reader :layers

  def log(chunk)
    chunk = JSON.parse(chunk)
    log_status(chunk)
    log_out(chunk)
    log_err(chunk)
  end

  private

  def log_out(chunk)
    return unless chunk["stream"]
    Log.out.puts chunk["stream"]
  end

  def log_err(chunk)
    return unless chunk["error"]
    Log.err.puts chunk["error"]
  end

  def log_status(chunk)
    return unless chunk["status"]
    case chunk["status"]
    when /Pulling from .*/
      Log.out.puts "#{chunk["status"]}:#{chunk["id"]}".bold.green
    when /(Status:|Digest:) .*/
      Log.out.puts "#{chunk["status"]}".bold.green
    else
      log_download(chunk)
    end
  end

  def log_download(chunk)
    layers.process(chunk)
    return unless layers.total?
    return if progress_bar.finished?
    progress_bar.progress = layers.progress
  end

  def progress_bar
    @_progress_bar ||= ProgressBar.create(
      title: "Downloading Image",
      total: layers.total,
      output: Log.out,
      format: "%t |%w| %E",
      length: 80,
    )
  end

  class Layers
    def initialize
      @layers = {}
    end

    def process(status)
      return unless status["progressDetail"]
      layer = @layers[status["id"]] || Layer.new
      layer.process(status)
      @layers[status["id"]] = layer
    end

    def progress
      sum(&:progress)
    end

    def total
      sum(&:total) * 2
    end

    def total?
      return unless @layers.any?
      @layers.values.all?(&:total?)
    end

    private

    def sum
      @layers.values.map do |layer|
        yield layer
      end.reduce(:+)
    end
  end

  class Layer
    attr_reader :total

    def initialize
      @downloaded = 0
      @extracted = 0
    end

    def total?
      !@total.nil?
    end

    def progress
      @downloaded + @extracted
    end

    def process(status)
      case status["status"]
      when "Downloading"
        @total = status["progressDetail"]["total"]
        @downloaded = status["progressDetail"]["current"]
      when "Extracting"
        @total = status["progressDetail"]["total"]
        @extracted = status["progressDetail"]["current"]
      end
    end
  end
end
