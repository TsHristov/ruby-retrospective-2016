# => It`s ugly, I know!
# => P.S. Yes I`ve heard about polymorphism! :D
module ParseArguments
  def argument?(arg)
    arg if !(option? arg) && !(option_with_parameter? arg)
  end

  def option?(arg)
    arg.chars.take(1) == ['-'] && arg.length == 2 || \
    arg.chars.take(2) == ['-', '-'] && !(arg.chars.include? '=')
  end

  def option_with_parameter?(arg)
    arg.chars.take(1) == ['-'] && arg.length > 2 || \
    arg.chars.take(2) == ['-', '-'] && (arg.chars.include? '=')
  end

  def get_arguments(argv)
    argv.select { |arg| argument? arg }
  end

  def get_options(argv)
    argv.select { |arg| option? arg }
  end

  def get_options_with_parameter(argv)
    argv.select { |arg| option_with_parameter? arg }
  end
end

class Argument
  attr_accessor :name, :block
  def initialize(name, block)
    @name  = name
    @block = block
  end

  def parse(command_runner, arg)
    @block.call command_runner, arg
  end

  def attributes
    {name: name}
  end
end

class Option
  attr_accessor :short_name, :full_name, :help, :block
  def initialize(short_name, full_name, help, block)
    @short_name = short_name
    @full_name  = full_name
    @help       = help
    @block      = block
  end

  def exists?(options)
    options.one? do |option|
      option.include? ("-#{short_name}" || "--#{full_name}")
    end
  end

  def attributes
    {
      short_name: short_name,
      full_name:  full_name,
      help:       help
    }
  end

  def parse(command_runner, _)
    @block.call command_runner, true
  end
end

class OptionWithParameter
  attr_accessor :short_name, :full_name, :help, :placeholder, :block
  def initialize(short_name, full_name, help, placeholder, block)
    @short_name  = short_name
    @full_name   = full_name
    @help        = help
    @placeholder = placeholder
    @block       = block
  end

  def attributes
    {
      short_name:  short_name,
      full_name:   full_name,
      help:        help,
      placeholder: placeholder,
    }
  end
end

class CommandParser
  include ParseArguments
  def initialize(command_name)
    @command_name = command_name
    @arguments    = []
  end

  def argument(argument_name, &block)
    @arguments << Argument.new(argument_name, block)
  end

  def option(short_name, full_name, help, &block)
    @arguments << Option.new(short_name, full_name, help, block)
  end

  def option_with_parameter(short_name, full_name, help, placeholder, &block)
    @arguments <<
    OptionWithParameter.new(short_name, full_name, help, placeholder, block)
  end

  def parse(command_runner, argv)
    arguments =  get_arguments(argv)
    options   =  get_options(argv)
    @arguments.each.zip(arguments) do |element, arg|
      element.parse(command_runner, arg) if element.instance_of? Argument
    end
    @arguments.each.zip(options) do |option, arg|
      if option.instance_of?(Option) && option.exists?(options)
        option.parse(command_runner, arg)
      end
    end
  end

  def help
    a = argument_attributes
    b = option_attributes
    c = option_with_parameters_attributes
    header = "Usage: #{@command_name} [#{a[:name]}]\n"
    body = "\    -#{b[:short_name]}, --#{b[:full_name]} #{b[:help]}\n"
    footer = "\    -#{c[:short_name]}, --#{c[:full_name]}"\
    +"=#{c[:placeholder]} #{c[:help]}\n"
    header + body + footer
  end

  private

  def argument_attributes
    dict = {}
    @arguments.select { |element| element.instance_of? Argument }
              .each { |arg| dict = arg.attributes }
    dict
  end

  def option_attributes
    dict = {}
    @arguments.select { |element| element.instance_of? Option }
              .each { |opt| dict = opt.attributes }
    dict
  end

  def option_with_parameters_attributes
    dict = {}
    @arguments.select { |element| element.instance_of? OptionWithParameter }
              .each { |opt| dict = opt.attributes }
    dict
  end
end
