module Climate
  class Command

    module ClassMethods

      def cli_argument(*args)
        raise DefinitionError, "can not define a required argument after an " +
          "optional one" if cli_arguments.any?(&:optional?)

        cli_arguments << Argument.new(*args)
      end

      def cli_option(*args)
        cli_options << Option.new(*args)
      end

      def trollop_parser
        parser = Trollop::Parser.new

        if cli_arguments.size > 0
          parser.banner ""
          max_length = cli_arguments.map { |h| h.name.to_s.length }.max
          cli_arguments.each do |argument|
            parser.banner("  " + argument.name.to_s.rjust(max_length) + " - #{argument.description}")
          end
        end

        parser.banner ""
        cli_options.each do |option|
          parser.opt(option.name, option.description, option.options)
        end
        parser
      end

      def check_arguments(args)

        if args.size > cli_arguments.size
          raise UnexpectedArgumentError, "#{args.size} for #{cli_arguments.size}"
        end

        cli_arguments.zip(args).map do |argument, arg_value|
          if argument.required? && (arg_value.nil? || arg_value.empty?)
            raise MissingArgumentError, argument.name
          end
          {argument.name => arg_value}
        end.inject {|a,b| a.merge(b) }
      end

      def parse(arguments)
        parser = self.trollop_parser
        options = parser.parse(arguments)
        arguments = self.check_arguments(parser.leftovers)

        [arguments, options]
      end

      private

      # kept private to prevent mutation
      def cli_options   ; @cli_options ||= []   ; end
      def cli_arguments ; @cli_arguments ||= [] ; end

    end

    class << self
      include ClassMethods
    end

    def initialize(arguments)
      @arguments, @options = self.class.parse(arguments)
    end

    attr_accessor :options, :arguments

  end
end
