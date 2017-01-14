# 1. Use Duck Typing!
class Argument
  attr_accessor :name, :block
  def initialize(name, block)
    @name  = name
    @block = block
  end

  def parse(command_runner, arg, _)
    @block.call command_runner, arg
  end

  def help
    "[#{@name}]"
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

  def exists?(arguments)
    option = /(^-#{@short_name}$|^--#{@full_name}$)/
    arguments.one? { |argument| option.match(argument) }
  end

  def parse(command_runner, _, argv)
    @block.call command_runner, exists?(argv)
  end

  def help
    four_spaces = ' ' * 4
    four_spaces + "-#{@short_name}, --#{@full_name} #{@help}"
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

  def exists?(arguments)
    option = /(^-#{@short_name}.+$|^--#{@full_name}=.+$)/
    arguments.one? { |argument| option.match(argument) }
  end

  def parse(command_runner, arg, argv)
    /((?<==).+|(?<=^-#{short_name}).+)/.match arg do |match|
      argument = match[0]
      @block.call command_runner, argument
    end if exists? argv
  end

  def help
    four_spaces = ' ' * 4
    four_spaces + "-#{@short_name}, --#{@full_name}=#{@placeholder} #{@help}"
  end
end

class CommandParser
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
    @arguments.each.zip(argv) do |argument, arg|
      argument.parse(command_runner, arg, argv)
    end
  end

  def help
    help_message = "Usage: #{@command_name}"
    arguments_help(help_message)
    options_help(help_message)
    help_message
  end

  def arguments_help(help_message)
    arguments = @arguments.select { |argument| argument.instance_of? Argument }
    arguments.each do |argument|
      help_message << " " << argument.help
    end
  end

  def options_help(help_message)
    options = @arguments.reject { |argument| argument.instance_of? Argument }
    options.each do |option|
      help_message << "\n" << option.help
    end
  end
end
