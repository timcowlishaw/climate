module Climate
  class Error < ::StandardError ; end

  # Raised when {Command} class methods are used incorrectly
  class DefinitionError < Error ; end

  # Raised by an instance of a {Command} when something went wrong during
  # execution
  class CommandError < Error

    # The command that raised the error
    attr_accessor :command_class

    def initialize(msg=nil, command_or_class=nil)
      @command_class = command_or_class.is_a?(Command) ? command_or_class.class :
        command_or_class
      super(msg)
    end
  end

  # Command instances can raise this error to exit
  class ExitException < CommandError

    attr_reader :exit_code
    # some libraries (popen, process?) refer to this as exitcode without a _
    alias :exitstatus :exit_code

    def initialize(msg, exit_code=1)
      @exit_code = exit_code
      super(msg)
    end
  end

  class HelpNeeded < CommandError
    def initialize(command_class) ; super(nil, command_class) ; end
  end

  # Raised when a {Command} is run with too many arguments
  class UnexpectedArgumentError < CommandError ; end

  # Raised when a {Command} is run with insufficient arguments
  class MissingArgumentError < CommandError ; end

  # Raised when a parent {Command} is asked to run a sub command it does not
  # know about
  class UnknownCommandError < CommandError ; end
end
