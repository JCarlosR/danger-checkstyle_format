# frozen_string_literal: true

CheckstyleError = Struct.new(:file_name, :line, :column, :severity, :message, :source) do
  def self.generate(node, parent_node, sub_regex)
    relative_path = parent_node[:name].sub(sub_regex, "")

    CheckstyleError.new(
      relative_path,
      node[:line].to_i,
      node[:column]&.to_i,
      node[:severity],
      node[:message],
      node[:source]
    )
  end
end
